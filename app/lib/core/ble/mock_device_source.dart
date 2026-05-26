import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'sensor_packet.dart';

/// Realistic synthetic sensor source for development without the wearable.
///
/// Heart rate gently drifts with a circadian baseline + 1/f noise; an
/// activity engine bumps HR + accel magnitude during scripted "walk" and
/// "exercise" phases. Temperature wanders ±0.4°C around 33.8°C (skin temp).
/// SpO₂ stays in a normal 96-99% band.
///
/// Periodically (~every 90 s) injects a brief tachycardia burst so the
/// alert pipeline can be exercised end-to-end during the demo.
class MockDeviceSource {
  MockDeviceSource({this.injectAnomalies = true});

  final bool injectAnomalies;

  Timer? _ppgTimer;
  Timer? _tempTimer;
  Timer? _imuTimer;
  Timer? _statusTimer;
  int _seq = 0;
  final _rng = math.Random(42);

  // Continuous streams. Subscribers receive decoded frames directly so the
  // service layer can treat real BLE and mock identically.
  final _ppg = StreamController<PpgFrame>.broadcast();
  final _temp = StreamController<TempFrame>.broadcast();
  final _imu = StreamController<ImuFrame>.broadcast();
  final _status = StreamController<StatusFrame>.broadcast();

  Stream<PpgFrame> get ppg => _ppg.stream;
  Stream<TempFrame> get temp => _temp.stream;
  Stream<ImuFrame> get imu => _imu.stream;
  Stream<StatusFrame> get status => _status.stream;

  // Internal "virtual user" state.
  final double _baselineHr = 72;
  double _phase = 0;
  int _activityClass = 0; // 0 rest, 1 walk, 2 run
  int _battery = 87;
  int _ticksSinceAnomaly = 0;

  void start() {
    stop();
    _ppgTimer = Timer.periodic(const Duration(milliseconds: 250), _emitPpg);
    _tempTimer = Timer.periodic(const Duration(seconds: 1), _emitTemp);
    _imuTimer = Timer.periodic(const Duration(milliseconds: 250), _emitImu);
    _statusTimer = Timer.periodic(const Duration(seconds: 5), _emitStatus);
  }

  void stop() {
    _ppgTimer?.cancel();
    _tempTimer?.cancel();
    _imuTimer?.cancel();
    _statusTimer?.cancel();
  }

  Future<void> dispose() async {
    stop();
    await _ppg.close();
    await _temp.close();
    await _imu.close();
    await _status.close();
  }

  // ─── emitters ──────────────────────────────────────────────────────────

  void _emitPpg(Timer _) {
    _phase += 0.05;
    _seq = (_seq + 1) & 0xFFFF;
    _ticksSinceAnomaly++;

    // Activity drift.
    if (_ticksSinceAnomaly % 240 == 0) {
      _activityClass = _rng.nextInt(3);
    }
    final activityBump = switch (_activityClass) {
      1 => 18.0,
      2 => 42.0,
      _ => 0.0,
    };

    // Anomaly injection - short tachycardia spike.
    final spike =
        injectAnomalies && _ticksSinceAnomaly > 360 && _ticksSinceAnomaly < 380
        ? 60.0
        : 0.0;
    if (_ticksSinceAnomaly > 380) _ticksSinceAnomaly = 0;

    final hr =
        _baselineHr +
        activityBump +
        spike +
        math.sin(_phase) * 2.5 +
        (_rng.nextDouble() - 0.5) * 4;
    final spo2 = 97.0 + (_rng.nextDouble() - 0.5) * 1.5;

    // Build a fake 25-sample window approximating PPG ringing around hr.
    final samples = Int16List(25);
    final secPerBeat = 60.0 / hr;
    for (var i = 0; i < 25; i++) {
      final t = i * (0.25 / 25);
      final beat = math.sin(2 * math.pi * t / secPerBeat);
      samples[i] = (beat * 8000 + (_rng.nextDouble() - 0.5) * 600).toInt();
    }

    _ppg.add(
      PpgFrame(
        seq: _seq,
        tsMs: DateTime.now().millisecondsSinceEpoch,
        hrBpm: hr,
        spo2: spo2,
        samples: samples,
      ),
    );
  }

  void _emitTemp(Timer _) {
    final t =
        33.8 + math.sin(_phase / 6) * 0.35 + (_rng.nextDouble() - 0.5) * 0.12;
    _temp.add(
      TempFrame(tsMs: DateTime.now().millisecondsSinceEpoch, celsius: t),
    );
  }

  void _emitImu(Timer _) {
    final mag = switch (_activityClass) {
      0 => 1.0 + (_rng.nextDouble() - 0.5) * 0.05,
      1 => 1.4 + math.sin(_phase * 12) * 0.4 + (_rng.nextDouble() - 0.5) * 0.2,
      2 => 2.0 + math.sin(_phase * 18) * 0.8 + (_rng.nextDouble() - 0.5) * 0.4,
      _ => 1.0,
    };
    _imu.add(
      ImuFrame(
        tsMs: DateTime.now().millisecondsSinceEpoch,
        ax: math.sin(_phase * 8) * mag,
        ay: math.cos(_phase * 8) * mag,
        az: 9.81 + math.sin(_phase * 3) * 0.2,
        gx: (_rng.nextDouble() - 0.5) * 30,
        gy: (_rng.nextDouble() - 0.5) * 30,
        gz: (_rng.nextDouble() - 0.5) * 30,
        magnitudeMean: mag,
        magnitudeStd: mag * 0.18,
      ),
    );
  }

  void _emitStatus(Timer _) {
    if (_battery > 12 && _rng.nextDouble() < 0.04) _battery--;
    _status.add(
      StatusFrame(
        batteryPct: _battery,
        flags: 0x06, // sensorOk + demoMode
        fwVersion: '0.1',
      ),
    );
  }
}
