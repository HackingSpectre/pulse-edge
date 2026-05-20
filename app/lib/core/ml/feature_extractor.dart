import 'dart:async';
import 'dart:math' as math;

import '../ble/sensor_packet.dart';
import 'feature_window.dart';

/// Aggregates streaming sensor frames into 30-second feature windows with a
/// 5-second hop (matches the WESAD training pipeline in /ml/anomaly).
///
/// Holds a small in-memory ring per metric. No drift writes here — the
/// service layer above persists raw samples; this class is purely numeric.
class FeatureExtractor {
  FeatureExtractor({
    this.windowSeconds = 30,
    this.hopSeconds = 5,
  });

  final int windowSeconds;
  final int hopSeconds;

  final _hrTs = <int>[];
  final _hr = <double>[];
  final _spo2 = <double>[];
  final _temp = <_TimedDouble>[];
  final _imuMag = <double>[];
  final _imuStd = <double>[];

  int _lastEmitMs = 0;

  final _windows = StreamController<FeatureWindow>.broadcast();
  Stream<FeatureWindow> get windowStream => _windows.stream;

  void addPpg(PpgFrame f) {
    _hrTs.add(f.tsMs);
    _hr.add(f.hrBpm);
    if (f.spo2 != null) _spo2.add(f.spo2!);
    _maybeEmit(f.tsMs);
  }

  void addTemp(TempFrame f) {
    _temp.add(_TimedDouble(f.tsMs, f.celsius));
    _trimTemp(f.tsMs);
  }

  void addImu(ImuFrame f) {
    _imuMag.add(f.magnitudeMean);
    _imuStd.add(f.magnitudeStd);
    if (_imuMag.length > 240) {
      _imuMag.removeAt(0);
      _imuStd.removeAt(0);
    }
  }

  void _trimTemp(int nowMs) {
    final cutoff = nowMs - windowSeconds * 1000;
    _temp.removeWhere((t) => t.tsMs < cutoff);
  }

  void _maybeEmit(int nowMs) {
    // Trim HR buffers to window.
    final cutoff = nowMs - windowSeconds * 1000;
    while (_hrTs.isNotEmpty && _hrTs.first < cutoff) {
      _hrTs.removeAt(0);
      _hr.removeAt(0);
    }
    if (_spo2.length > 200) _spo2.removeRange(0, _spo2.length - 200);

    if (nowMs - _lastEmitMs < hopSeconds * 1000) return;
    if (_hr.length < 4) return;
    _lastEmitMs = nowMs;

    final hrMean = _hr.reduce((a, b) => a + b) / _hr.length;
    final hrStd = _stddev(_hr, hrMean);
    final hrMin = _hr.reduce(math.min);
    final hrMax = _hr.reduce(math.max);

    // RR-interval proxy from HR samples — RMSSD + pNN50 are HRV staples.
    // We approximate from successive HR estimates rather than full RR.
    final rr = <double>[for (final h in _hr) if (h > 0) 60000.0 / h];
    final rrDiffs = <double>[for (var i = 1; i < rr.length; i++) (rr[i] - rr[i - 1]).abs()];
    final rmssd = rrDiffs.isEmpty
        ? 0.0
        : math.sqrt(rrDiffs.map((d) => d * d).reduce((a, b) => a + b) / rrDiffs.length);
    final pnn50 = rrDiffs.isEmpty
        ? 0.0
        : rrDiffs.where((d) => d > 50).length / rrDiffs.length;

    final spo2Mean = _spo2.isEmpty ? null : _spo2.reduce((a, b) => a + b) / _spo2.length;

    // Temperature mean + linear slope (°C / s).
    final tempVals = _temp.map((t) => t.value).toList();
    final tempMean = tempVals.isEmpty
        ? 33.5
        : tempVals.reduce((a, b) => a + b) / tempVals.length;
    final tempSlope = _temp.length < 2
        ? 0.0
        : (_temp.last.value - _temp.first.value) /
            ((_temp.last.tsMs - _temp.first.tsMs) / 1000.0);

    final accelMean = _imuMag.isEmpty
        ? 1.0
        : _imuMag.reduce((a, b) => a + b) / _imuMag.length;
    final accelStd = _imuStd.isEmpty
        ? 0.0
        : _imuStd.reduce((a, b) => a + b) / _imuStd.length;

    final activity = _classifyActivity(accelMean, accelStd);

    _windows.add(FeatureWindow(
      tsMs: nowMs,
      windowS: windowSeconds,
      hrMean: hrMean,
      hrStd: hrStd,
      hrMin: hrMin,
      hrMax: hrMax,
      rmssd: rmssd,
      pnn50: pnn50,
      spo2Mean: spo2Mean,
      tempMean: tempMean,
      tempSlope: tempSlope,
      accelMean: accelMean,
      accelStd: accelStd,
      activity: activity,
    ));
  }

  /// Conservative thresholding — replaced by a tiny TFLite classifier in v2.
  int _classifyActivity(double accelMean, double accelStd) {
    if (accelStd > 1.5 || accelMean > 1.8) return 2; // running
    if (accelStd > 0.4 || accelMean > 1.2) return 1; // walking
    return 0; // resting
  }

  double _stddev(List<double> xs, double mean) {
    if (xs.length < 2) return 0;
    final v = xs.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
        (xs.length - 1);
    return math.sqrt(v);
  }

  Future<void> dispose() async => _windows.close();
}

class _TimedDouble {
  _TimedDouble(this.tsMs, this.value);
  final int tsMs;
  final double value;
}
