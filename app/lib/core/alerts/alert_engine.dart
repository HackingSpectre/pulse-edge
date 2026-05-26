import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../db/repositories.dart';
import '../ml/baseline_service.dart';
import '../ml/feature_window.dart';
import '../notifications/notifications_service.dart';
import 'alert_severity.dart';

/// Decision logic that converts a feature window + model probability into
/// zero or more persisted alerts.
///
/// Pipeline:
///   1. Hardcoded safety rules (always-on, bypass everything else).
///   2. Combination of model probability + per-user baseline z-score.
///   3. Persist + (for HIGH) push a notification.
///
/// This is the *only* place in the app that decides "is this an anomaly?".
/// Keep new logic here so it's easy to audit and unit-test.
class AlertEngine {
  AlertEngine(this._anomalyRepo, this._baseline, this._notifications);

  final AnomalyRepo _anomalyRepo;
  final BaselineService _baseline;
  final NotificationsService _notifications;
  final _uuid = const Uuid();

  // Hardcoded safety thresholds - never trip on a single sample, only on
  // sustained 30-s windows. See PLAN.md §6.3 / §7.5.
  static const double _hrHighBpm = 180;
  static const double _hrLowBpm = 35;
  static const double _spo2LowPct = 90;
  static const double _tempHighC = 39.5;
  static const double _tempLowC = 34.0;

  // Anomaly thresholds.
  static const double _modelHigh = 0.80;
  static const double _modelMedium = 0.55;
  static const double _baselineSigma = 3.0;
  static const int _duplicateWindowMs = 30 * 60 * 1000;

  Future<void> evaluate(FeatureWindow w, {required double modelP}) async {
    // 1. Hardcoded safety rules (HIGH severity, always notify).
    if (w.hrMean >= _hrHighBpm) {
      await _fire(
        w,
        AlertType.tachycardia,
        AlertSeverity.high,
        modelP,
        _explainTachy(w),
      );
      return;
    }
    if (w.hrMean <= _hrLowBpm) {
      await _fire(
        w,
        AlertType.bradycardia,
        AlertSeverity.high,
        modelP,
        _explainBrady(w),
      );
      return;
    }
    if (w.spo2Mean != null && w.spo2Mean! <= _spo2LowPct) {
      await _fire(
        w,
        AlertType.hypoxia,
        AlertSeverity.high,
        modelP,
        _explainHypoxia(w),
      );
      return;
    }
    if (w.tempMean >= _tempHighC) {
      await _fire(
        w,
        AlertType.hyperthermia,
        AlertSeverity.high,
        modelP,
        _explainHyper(w),
      );
      return;
    }
    if (w.tempMean <= _tempLowC) {
      await _fire(
        w,
        AlertType.hypothermia,
        AlertSeverity.high,
        modelP,
        _explainHypo(w),
      );
      return;
    }

    // 2. Model + baseline combination.
    final baselineZ = await _baseline.zScore(
      metric: 'hr',
      tod: TimeBuckets.forHour(
        DateTime.fromMillisecondsSinceEpoch(w.tsMs).hour,
      ),
      activity: w.activity,
      value: w.hrMean,
    );
    final baselineFlag = baselineZ != null && baselineZ.abs() > _baselineSigma;
    final modelFlag = modelP >= _modelMedium;

    if (modelP >= _modelHigh && baselineFlag) {
      await _fire(
        w,
        AlertType.modelAnomaly,
        AlertSeverity.high,
        modelP,
        _explainPattern(w, baselineZ),
      );
    } else if (modelFlag || baselineFlag) {
      await _fire(
        w,
        AlertType.modelAnomaly,
        AlertSeverity.medium,
        modelP,
        _explainPattern(w, baselineZ),
      );
    }
    // else: log only - no row inserted.
  }

  Future<void> _fire(
    FeatureWindow w,
    AlertType type,
    AlertSeverity sev,
    double modelP,
    String explanation,
  ) async {
    final duplicate = await _anomalyRepo.latestByTypeSince(
      type.id,
      w.tsMs - _duplicateWindowMs,
    );
    if (duplicate != null) return;

    final id = _uuid.v4();
    final metrics = {
      'hrMean': w.hrMean,
      'hrMin': w.hrMin,
      'hrMax': w.hrMax,
      'rmssd': w.rmssd,
      'spo2': w.spo2Mean,
      'tempMean': w.tempMean,
      'activity': w.activity,
      'modelP': modelP,
    };
    await _anomalyRepo.upsert(
      AnomaliesCompanion(
        id: Value(id),
        tsMs: Value(w.tsMs),
        severity: Value(sev.code),
        type: Value(type.id),
        explanation: Value(explanation),
        guidance: Value(_guidance(type, sev)),
        metricsJson: Value(jsonEncode(metrics)),
      ),
    );
    if (sev == AlertSeverity.high) {
      await _notifications.showHighAlert(
        title: '${type.label} detected',
        body: explanation,
        anomalyId: id,
      );
    } else if (sev == AlertSeverity.medium) {
      await _notifications.showMediumAlert(
        title: type.label,
        body: explanation,
        anomalyId: id,
      );
    }
  }

  // Canned explanations used until the LLM rewrites them on read.

  String _explainTachy(FeatureWindow w) =>
      'Heart rate held above 180 bpm for 30 s while activity was '
      '${_activityLabel(w.activity)}. This is well above safe sustained levels.';

  String _explainBrady(FeatureWindow w) =>
      'Heart rate dropped below 35 bpm for 30 s. This is unusually low and '
      'should be reviewed.';

  String _explainHypoxia(FeatureWindow w) =>
      'Blood oxygen averaged ${w.spo2Mean?.toStringAsFixed(0) ?? '--'}%, below '
      'the safe threshold of 90%.';

  String _explainHyper(FeatureWindow w) =>
      'Skin temperature held above 39.5°C. Remove tight clothing, cool down, '
      'and rehydrate.';

  String _explainHypo(FeatureWindow w) =>
      'Skin temperature dropped below 34°C. Move somewhere warmer and check '
      'the watch is in good contact with your wrist.';

  String _explainPattern(FeatureWindow w, double? z) {
    final zPart = z == null
        ? ''
        : ' (${z.abs().toStringAsFixed(1)}σ from your usual)';
    return 'Heart-rate pattern looks unusual for this time of day '
        'while ${_activityLabel(w.activity)}$zPart.';
  }

  String _guidance(AlertType t, AlertSeverity sev) {
    if (sev == AlertSeverity.high) {
      return 'If you feel unwell, contact a healthcare professional.';
    }
    return 'Sit, breathe slowly for a minute, and re-check. If it persists, '
        'consider mentioning to your doctor at your next visit.';
  }

  String _activityLabel(int a) => switch (a) {
    0 => 'resting',
    1 => 'walking',
    2 => 'running',
    _ => 'active',
  };
}
