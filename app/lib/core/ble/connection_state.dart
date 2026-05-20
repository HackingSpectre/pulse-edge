enum BleConnState {
  idle,
  scanning,
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class BleStatus {
  const BleStatus({
    required this.state,
    this.deviceName,
    this.batteryPct,
    this.firmwareVersion,
    this.lastError,
    this.lastSeenMs,
    this.sensorOk,
    this.contactOk,
    this.demo = false,
  });

  final BleConnState state;
  final String? deviceName;
  final int? batteryPct;
  final String? firmwareVersion;
  final String? lastError;
  final int? lastSeenMs;
  final bool? sensorOk;
  final bool? contactOk;
  final bool demo;

  bool get isConnected => state == BleConnState.connected;

  BleStatus copyWith({
    BleConnState? state,
    String? deviceName,
    int? batteryPct,
    String? firmwareVersion,
    String? lastError,
    int? lastSeenMs,
    bool? sensorOk,
    bool? contactOk,
    bool? demo,
  }) {
    return BleStatus(
      state: state ?? this.state,
      deviceName: deviceName ?? this.deviceName,
      batteryPct: batteryPct ?? this.batteryPct,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastError: lastError ?? this.lastError,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
      sensorOk: sensorOk ?? this.sensorOk,
      contactOk: contactOk ?? this.contactOk,
      demo: demo ?? this.demo,
    );
  }

  static const idle = BleStatus(state: BleConnState.idle);
}
