#pragma once

#include <DallasTemperature.h>
#include <OneWire.h>

class TempSensor {
public:
    bool begin();
    void update();
    float celsius() const { return _last; }

private:
    OneWire _bus = OneWire(0);
    DallasTemperature _ds = DallasTemperature(&_bus);
    float _last = NAN;
    uint32_t _lastReadMs = 0;
};
