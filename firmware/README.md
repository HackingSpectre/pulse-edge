# Pulse Edge — Wearable firmware

ESP32-WROOM-32E firmware for the Pulse Edge wrist-worn sensor.

## Hardware

| Sensor | Bus | Address |
|---|---|---|
| MAX30102 (PPG) | I²C | 0x57 |
| MPU6050 (IMU) | I²C | 0x68 |
| DS18B20 (temp) | 1-Wire | — |
| Vibration motor | GPIO 25 (PWM) | — |
| Battery sense | ADC1_CH6 (GPIO 34) | — |

See `include/pin_map.h` for the full mapping.

## Build & flash

```bash
# install PlatformIO Core if you don't have it:
pip install -U platformio

cd firmware
pio run -e devboard            # build
pio run -e devboard -t upload  # flash via USB
pio device monitor             # serial logs at 115200
```

The `wearable` env is for the bare WROOM module on the custom PCB.

## BLE contract

UUIDs live in `include/ble_uuids.h` and are **mirrored byte-for-byte** in
`app/lib/core/ble/ble_protocol.dart`. Any change must be made in both places.

| Characteristic | Property | Payload |
|---|---|---|
| PPG | Notify | `seq u16 + ts u32 + hr f32 + spo2 f32 + n u16 + samples i16[n] + crc u8` |
| Temp | Notify | `ts u32 + celsius f32` |
| IMU | Notify | `ts u32 + ax/ay/az/gx/gy/gz/magMean/magStd f32 × 8` |
| Status | Notify | `batteryPct u8 + flags u8 + fwMajor u8 + fwMinor u8` |
| Vibrate | Write | `pattern u8` (`0` none, `1` short, `2` double, `3` SOS) |
| Config | R/W | small JSON |

## Architecture

Three FreeRTOS tasks pinned across the two cores:

```
core 0:  samplerTask  → reads PPG / IMU / temp at ~100 Hz
core 1:  notifierTask → drains ring buffers and emits BLE notifies @ 5 Hz
core 1:  statusTask   → battery + flags every 5 s
```
