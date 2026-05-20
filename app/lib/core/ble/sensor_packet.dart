import 'dart:typed_data';

/// Decoded sensor packet payloads. Each notify characteristic on the wearable
/// writes one of these binary frames. All multi-byte fields are little-endian.
class SensorFrame {
  SensorFrame._();
}

/// PPG window — N samples + the firmware-derived HR + SpO₂.
///
/// Layout (little-endian):
///   uint16 seq
///   uint32 tsMs       (ms since epoch on the wearable wall clock)
///   float32 hrBpm
///   float32 spo2      (NaN if not available)
///   uint16 nSamples
///   int16  samples[nSamples] (raw red-channel)
///   uint8  crc8       (computed over [seq..samples] inclusive)
class PpgFrame {
  PpgFrame({
    required this.seq,
    required this.tsMs,
    required this.hrBpm,
    required this.spo2,
    required this.samples,
  });

  final int seq;
  final int tsMs;
  final double hrBpm;
  final double? spo2;
  final Int16List samples;

  static PpgFrame? tryParse(Uint8List bytes) {
    if (bytes.length < 17) return null;
    final bd = ByteData.sublistView(bytes);
    final seq = bd.getUint16(0, Endian.little);
    final tsMs = bd.getUint32(2, Endian.little);
    final hrBpm = bd.getFloat32(6, Endian.little);
    final spo2 = bd.getFloat32(10, Endian.little);
    final n = bd.getUint16(14, Endian.little);
    final expected = 16 + n * 2 + 1;
    if (bytes.length != expected) return null;
    final crc = bytes[expected - 1];
    if (_crc8(bytes.sublist(0, expected - 1)) != crc) return null;
    final samples = Int16List(n);
    for (var i = 0; i < n; i++) {
      samples[i] = bd.getInt16(16 + i * 2, Endian.little);
    }
    return PpgFrame(
      seq: seq,
      tsMs: tsMs,
      hrBpm: hrBpm,
      spo2: spo2.isNaN ? null : spo2,
      samples: samples,
    );
  }
}

Uint8List int16ListToBytes(Int16List values) {
  final out = Uint8List(values.length * 2);
  final bd = ByteData.sublistView(out);
  for (var i = 0; i < values.length; i++) {
    bd.setInt16(i * 2, values[i], Endian.little);
  }
  return out;
}

int _crc8(Uint8List data) {
  var crc = 0;
  for (final byte in data) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 0x80) != 0 ? ((crc << 1) ^ 0x07) & 0xFF : (crc << 1) & 0xFF;
    }
  }
  return crc;
}

/// Temperature frame — single Celsius sample.
class TempFrame {
  TempFrame({required this.tsMs, required this.celsius});
  final int tsMs;
  final double celsius;

  static TempFrame? tryParse(Uint8List bytes) {
    if (bytes.length < 8) return null;
    final bd = ByteData.sublistView(bytes);
    final tsMs = bd.getUint32(0, Endian.little);
    final c = bd.getFloat32(4, Endian.little);
    return TempFrame(tsMs: tsMs, celsius: c);
  }
}

/// IMU frame — last sample + window aggregates.
class ImuFrame {
  ImuFrame({
    required this.tsMs,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.magnitudeMean,
    required this.magnitudeStd,
  });

  final int tsMs;
  final double ax, ay, az, gx, gy, gz, magnitudeMean, magnitudeStd;

  static ImuFrame? tryParse(Uint8List bytes) {
    if (bytes.length < 36) return null;
    final bd = ByteData.sublistView(bytes);
    final tsMs = bd.getUint32(0, Endian.little);
    return ImuFrame(
      tsMs: tsMs,
      ax: bd.getFloat32(4, Endian.little),
      ay: bd.getFloat32(8, Endian.little),
      az: bd.getFloat32(12, Endian.little),
      gx: bd.getFloat32(16, Endian.little),
      gy: bd.getFloat32(20, Endian.little),
      gz: bd.getFloat32(24, Endian.little),
      magnitudeMean: bd.getFloat32(28, Endian.little),
      magnitudeStd: bd.getFloat32(32, Endian.little),
    );
  }
}

/// Status frame — battery + flags.
class StatusFrame {
  StatusFrame({
    required this.batteryPct,
    required this.flags,
    required this.fwVersion,
  });

  final int batteryPct;
  final int flags;
  final String fwVersion;

  bool get charging => (flags & 0x01) != 0;
  bool get sensorOk => (flags & 0x02) != 0;
  bool get demoMode => (flags & 0x04) != 0;
  bool get ppgOk => (flags & 0x08) != 0;
  bool get tempOk => (flags & 0x10) != 0;
  bool get imuOk => (flags & 0x20) != 0;
  bool get contactOk => (flags & 0x40) != 0;

  static StatusFrame? tryParse(Uint8List bytes) {
    if (bytes.length < 4) return null;
    final bd = ByteData.sublistView(bytes);
    final pct = bd.getUint8(0);
    final flags = bd.getUint8(1);
    final major = bd.getUint8(2);
    final minor = bd.getUint8(3);
    return StatusFrame(
      batteryPct: pct,
      flags: flags,
      fwVersion: '$major.$minor',
    );
  }
}
