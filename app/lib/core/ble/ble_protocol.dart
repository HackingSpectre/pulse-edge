/// Pulse Edge BLE GATT contract - must stay in sync with the ESP32
/// firmware in /firmware/lib/ble_service.
///
/// All UUIDs are 128-bit, randomly generated for this project. Each value
/// is mirrored in firmware/include/ble_uuids.h.
class BleUuids {
  BleUuids._();

  /// Pulse Edge primary service.
  static const String service = 'b9e3a000-9c5b-4f0e-8b3a-1f6f8c2c8a01';

  /// PPG window notify (HR + SpO₂ + raw ring sample).
  static const String charPpg = 'b9e3a001-9c5b-4f0e-8b3a-1f6f8c2c8a01';

  /// Skin temperature notify (1 Hz).
  static const String charTemp = 'b9e3a002-9c5b-4f0e-8b3a-1f6f8c2c8a01';

  /// IMU window notify (~25 Hz aggregated to 250 ms windows).
  static const String charImu = 'b9e3a003-9c5b-4f0e-8b3a-1f6f8c2c8a01';

  /// Battery + status notify (5 s).
  static const String charStatus = 'b9e3a004-9c5b-4f0e-8b3a-1f6f8c2c8a01';

  /// Vibration / haptic alert write - phone tells the wearable to buzz.
  static const String charVibrate = 'b9e3a005-9c5b-4f0e-8b3a-1f6f8c2c8a01';

  /// Config R/W (sample rate, demo mode).
  static const String charConfig = 'b9e3a006-9c5b-4f0e-8b3a-1f6f8c2c8a01';

  static const String advName = 'PulseEdge';
}

/// Vibration patterns the phone may write to [BleUuids.charVibrate].
class VibratePattern {
  static const int none = 0;
  static const int short = 1;
  static const int doubleBuzz = 2;
  static const int sos = 3;
}
