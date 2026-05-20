#pragma once

#include <MAX30105.h>
#include <heartRate.h>

class PpgSensor {
public:
    bool begin();
    // Pulls samples from the FIFO and pushes them into the running ring.
    void update();

    float lastBpm() const { return _bpm; }
    float lastSpo2() const { return _spo2; }

    // Snapshot the last N raw red-channel samples for transmission.
    void snapshotWindow(int16_t *out, size_t n);

private:
    MAX30105 _max;
    float    _bpm  = 0.f;
    float    _spo2 = NAN;

    static constexpr size_t kRingSize = 256;
    int16_t  _ring[kRingSize] = {0};
    size_t   _writeIdx = 0;

    // Beat detector state.
    static constexpr uint8_t kRateSize = 4;
    uint8_t  _rateIdx = 0;
    uint16_t _rates[kRateSize] = {0};
    uint32_t _lastBeatMs = 0;
};
