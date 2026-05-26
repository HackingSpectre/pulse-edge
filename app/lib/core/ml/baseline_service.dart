import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'feature_window.dart';

/// Per-user statistical baseline using Welford's online algorithm.
///
/// Stats are bucketed by metric × time-of-day × activity. Each new feature
/// window updates the relevant buckets in O(1). Anomaly checks pull the
/// matching bucket and compare against |x - μ| > k·σ.
class BaselineService {
  BaselineService(this._db);
  final AppDb _db;

  /// Days of data required before baseline checks are trusted.
  static const int warmupDays = 7;

  Future<void> update(FeatureWindow w) async {
    final tod = TimeBuckets.forHour(
      DateTime.fromMillisecondsSinceEpoch(w.tsMs).hour,
    );
    final act = w.activity;
    await _updateOne('hr', tod, act, w.hrMean, w.tsMs);
    await _updateOne('rmssd', tod, act, w.rmssd, w.tsMs);
    await _updateOne('temp', tod, act, w.tempMean, w.tsMs);
    if (w.spo2Mean != null) {
      await _updateOne('spo2', tod, act, w.spo2Mean!, w.tsMs);
    }
  }

  Future<void> _updateOne(
    String metric,
    int tod,
    int act,
    double x,
    int nowMs,
  ) async {
    final existing =
        await (_db.select(_db.baselineStats)..where(
              (t) =>
                  t.metric.equals(metric) &
                  t.bucketTod.equals(tod) &
                  t.bucketActivity.equals(act),
            ))
            .getSingleOrNull();

    final n = (existing?.n ?? 0) + 1;
    final prevMean = existing?.mean ?? 0.0;
    final prevM2 = existing?.m2 ?? 0.0;
    final delta = x - prevMean;
    final mean = prevMean + delta / n;
    final delta2 = x - mean;
    final m2 = prevM2 + delta * delta2;
    final minV = math.min(existing?.minVal ?? double.infinity, x);
    final maxV = math.max(existing?.maxVal ?? double.negativeInfinity, x);

    await _db
        .into(_db.baselineStats)
        .insertOnConflictUpdate(
          BaselineStatsCompanion(
            metric: Value(metric),
            bucketTod: Value(tod),
            bucketActivity: Value(act),
            n: Value(n),
            mean: Value(mean),
            m2: Value(m2),
            minVal: Value(minV),
            maxVal: Value(maxV),
            updatedAtMs: Value(nowMs),
          ),
        );
  }

  /// Returns z-score (number of σ from μ) for the current bucket. Returns
  /// null if there isn't enough data yet (n < 30 in that bucket).
  Future<double?> zScore({
    required String metric,
    required int tod,
    required int activity,
    required double value,
  }) async {
    final row =
        await (_db.select(_db.baselineStats)..where(
              (t) =>
                  t.metric.equals(metric) &
                  t.bucketTod.equals(tod) &
                  t.bucketActivity.equals(activity),
            ))
            .getSingleOrNull();
    if (row == null || row.n < 30) return null;
    final variance = row.m2 / (row.n - 1);
    if (variance <= 0) return null;
    final sd = math.sqrt(variance);
    return (value - row.mean) / sd;
  }

  Future<void> reset() async {
    await _db.delete(_db.baselineStats).go();
  }

  /// True if the user has enough data for baseline-aware anomaly checks.
  Future<bool> warmedUp() async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c, MIN(updated_at_ms) AS firstMs FROM baseline_stats',
        )
        .getSingle();
    final n = row.read<int>('c');
    final firstMs = row.readNullable<int>('firstMs');
    if (n < 4 || firstMs == null) return false;
    final ageDays =
        (DateTime.now().millisecondsSinceEpoch - firstMs) /
        (1000 * 60 * 60 * 24);
    return ageDays >= warmupDays;
  }
}
