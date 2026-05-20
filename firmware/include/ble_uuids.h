// ─── Pulse Edge BLE GATT UUIDs ──────────────────────────────────────────────
//
// THIS FILE MUST STAY IN SYNC with the Flutter app:
//   app/lib/core/ble/ble_protocol.dart
//
// Any UUID change must be reflected in both.

#pragma once

#define PE_ADV_NAME            "PulseEdge"

#define PE_SERVICE_UUID        "b9e3a000-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_PPG_UUID       "b9e3a001-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_TEMP_UUID      "b9e3a002-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_IMU_UUID       "b9e3a003-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_STATUS_UUID    "b9e3a004-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_VIBRATE_UUID   "b9e3a005-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_CONFIG_UUID    "b9e3a006-9c5b-4f0e-8b3a-1f6f8c2c8a01"

// Vibration patterns acknowledged by the firmware on writes to charVibrate.
enum VibratePattern : uint8_t {
    VIB_NONE   = 0,
    VIB_SHORT  = 1,
    VIB_DOUBLE = 2,
    VIB_SOS    = 3,
};
