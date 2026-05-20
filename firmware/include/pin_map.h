// ─── ESP32-WROOM ↔ sensor pin map ───────────────────────────────────────────
//
// Mirror this layout in the KiCad schematic (hardware/kicad/).
// Only safe input/output pins are used; flash/strapping pins are avoided.

#pragma once

// I²C bus (shared by MAX30102 + MPU6050)
#define PIN_I2C_SDA   21
#define PIN_I2C_SCL   22
#define I2C_FREQ_HZ   400000

// 1-Wire bus (DS18B20)
#define PIN_ONEWIRE   4

// Vibration motor (PWM via LEDC)
#define PIN_VIBRATE   25
#define VIB_LEDC_CH   0
#define VIB_LEDC_HZ   1000
#define VIB_LEDC_RES  8

// Battery sense (voltage divider into ADC)
#define PIN_VBAT_SENSE 34   // ADC1_CH6
#define VBAT_DIV_RATIO 2.0f // 1:1 divider doubles the reading

// Status LED (optional, on dev boards usually GPIO 2)
#define PIN_STATUS_LED 2
