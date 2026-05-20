#include "temp_sensor.h"

#include <Arduino.h>

#include "pin_map.h"

bool TempSensor::begin() {
    _bus = OneWire(PIN_ONEWIRE);
    _ds.setOneWire(&_bus);
    _ds.begin();
    if (_ds.getDeviceCount() == 0) {
        return false;
    }
    _ds.setResolution(11); // ~375 ms conversion, 0.125°C resolution
    _ds.setWaitForConversion(false); // poll-based; see update()
    _ds.requestTemperatures();
    _lastReadMs = millis();
    return true;
}

void TempSensor::update() {
    const uint32_t now = millis();
    if (now - _lastReadMs >= 800) {
        const float t = _ds.getTempCByIndex(0);
        if (t != DEVICE_DISCONNECTED_C) _last = t;
        _ds.requestTemperatures();
        _lastReadMs = now;
    }
}
