import 'dart:async';
import 'dart:math' as math;

import 'package:rxdart/rxdart.dart';

import '../ble/ble_service.dart';
import '../db/repositories.dart';
import 'scripted_assistant.dart';

enum LlmStatus { ready }

/// Lightweight local assistant service.
///
/// Despite the historical name, this no longer loads a language model. The
/// assistant is intentionally deterministic: every answer is grounded in recent
/// wearable readings, hard safety thresholds, and conservative wellness rules.
class LlmService {
  LlmService({
    required this.ble,
    required this.sensorRepo,
    required this.anomalyRepo,
    required this.profileRepo,
  });

  final BleService ble;
  final SensorRepo sensorRepo;
  final AnomalyRepo anomalyRepo;
  final ProfileRepo profileRepo;

  final _status = BehaviorSubject<LlmStatus>.seeded(LlmStatus.ready);
  Stream<LlmStatus> get status$ => _status.stream;
  LlmStatus get status => _status.value;

  Future<void> ensureLoaded() async {}

  Stream<String> chat(String userMessage) async* {
    final context = await _recentContext();
    yield ScriptedAssistant.reply(userMessage, context: context);
    yield ScriptedAssistant.disclaimer;
  }

  Future<String> explainAnomaly({
    required String type,
    required String metricsJson,
  }) async {
    return '${ScriptedAssistant.explainAnomaly(type: type, metricsJson: metricsJson)}'
        '${ScriptedAssistant.disclaimer}';
  }

  Future<String> dailySummary() async {
    final context = await _recentContext();
    return '${ScriptedAssistant.dailySummary(context)}'
        '${ScriptedAssistant.disclaimer}';
  }

  Future<HealthChatContext> _recentContext() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final yesterday = now - 24 * 60 * 60 * 1000;
    final ppg = await sensorRepo.ppgInRange(yesterday, now);
    final temps = await sensorRepo.tempInRange(yesterday, now);
    final imu = await sensorRepo.imuInRange(yesterday, now);
    final anomalies = await anomalyRepo.recentSince(yesterday);

    final hrs = ppg.map((s) => s.hrBpm).where((v) => v.isFinite).toList();
    final spo2 = ppg
        .map((s) => s.spo2)
        .whereType<double>()
        .where((v) => v.isFinite)
        .toList();
    final tempVals = temps
        .map((s) => s.celsius)
        .where((v) => v.isFinite)
        .toList();
    final motion = imu
        .map((s) {
          final mag = (s.ax * s.ax + s.ay * s.ay + s.az * s.az);
          return mag <= 0 ? null : math.sqrt(mag) / 9.80665;
        })
        .whereType<double>()
        .where((v) => v.isFinite)
        .toList();

    final profile = await profileRepo.get();
    return HealthChatContext(
      profileName: profile?.name,
      username: profile?.username,
      liveHr: ble.latestHr,
      liveSpo2: ble.latestSpo2,
      liveTemp: ble.latestTemp,
      liveActivity: ble.latestActivity,
      liveMotion: ble.latestImu?.magnitudeMean,
      deviceState: ble.status.state.name,
      deviceName: ble.status.deviceName,
      contactOk: ble.status.contactOk,
      sensorOk: ble.status.sensorOk,
      sampleCount: ppg.length,
      hrMin: ScriptedAssistant.minOrNull(hrs),
      hrMedian: ScriptedAssistant.median(hrs),
      hrMax: ScriptedAssistant.maxOrNull(hrs),
      spo2Min: ScriptedAssistant.minOrNull(spo2),
      spo2Mean: ScriptedAssistant.mean(spo2),
      tempMean: ScriptedAssistant.mean(tempVals),
      tempMin: ScriptedAssistant.minOrNull(tempVals),
      tempMax: ScriptedAssistant.maxOrNull(tempVals),
      motionMean: ScriptedAssistant.mean(motion),
      recentHighAlerts: anomalies.where((a) => a.severity == 2).length,
      recentMediumAlerts: anomalies.where((a) => a.severity == 1).length,
      recentLowAlerts: anomalies.where((a) => a.severity == 0).length,
    );
  }

  Future<void> dispose() async {
    await _status.close();
  }
}
