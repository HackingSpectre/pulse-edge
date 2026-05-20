#include "ppg_sensor.h"

#include <Arduino.h>
#include <Wire.h>

bool PpgSensor::begin() {
    if (!_max.begin(Wire, I2C_SPEED_FAST)) {
        return false;
    }
    // Standard SpO₂-friendly config: red + IR LED, 411-µs pulse width,
    // 100 Hz sample rate, 32-sample averaging.
    _max.setup(0x1F, 4, 2, 100, 411, 4096);
    _max.setPulseAmplitudeRed(0x1F);
    _max.setPulseAmplitudeIR(0x1F);
    return true;
}

void PpgSensor::update() {
    while (_max.available()) {
        const long red = _max.getRed();
        _max.nextSample();

        _ring[_writeIdx] = static_cast<int16_t>(red - 32768);
        _writeIdx = (_writeIdx + 1) % kRingSize;

        if (checkForBeat(red)) {
            const uint32_t now = millis();
            const uint32_t dt = now - _lastBeatMs;
            _lastBeatMs = now;
            const float bpm = 60000.f / static_cast<float>(dt);
            if (bpm > 30 && bpm < 220) {
                _rates[_rateIdx++ % kRateSize] = bpm;
                uint32_t sum = 0;
                for (uint8_t i = 0; i < kRateSize; ++i) sum += _rates[i];
                _bpm = static_cast<float>(sum) / kRateSize;
            }
        }
    }
    // SpO₂ is computed externally on the phone from the raw window in v1.
    // Leave as NaN here.
    _spo2 = NAN;
}

void PpgSensor::snapshotWindow(int16_t *out, size_t n) {
    if (n > kRingSize) n = kRingSize;
    // Copy the most recent n samples in chronological order.
    for (size_t i = 0; i < n; ++i) {
        const size_t idx = (_writeIdx + kRingSize - n + i) % kRingSize;
        out[i] = _ring[idx];
    }
}
