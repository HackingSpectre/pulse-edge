#pragma once

#include <NimBLEDevice.h>
#include <stdint.h>

#include "ble_uuids.h"

// Forward decl for vibration callback target.
class VibrationActuator;

class PeBleServer : public NimBLEServerCallbacks,
                    public NimBLECharacteristicCallbacks {
public:
    void begin(VibrationActuator *vib);

    // Notify writes — copy a payload and fire if a peer is subscribed.
    void notifyPpg(const uint8_t *bytes, size_t len);
    void notifyTemp(const uint8_t *bytes, size_t len);
    void notifyImu(const uint8_t *bytes, size_t len);
    void notifyStatus(const uint8_t *bytes, size_t len);

    bool isConnected() const { return _connectedCount > 0; }

private:
    // NimBLE callbacks.
    void onConnect(NimBLEServer *s, NimBLEConnInfo &info) override;
    void onDisconnect(NimBLEServer *s, NimBLEConnInfo &info, int reason) override;
    void onWrite(NimBLECharacteristic *c, NimBLEConnInfo &info) override;

    NimBLEServer        *_server = nullptr;
    NimBLECharacteristic *_charPpg     = nullptr;
    NimBLECharacteristic *_charTemp    = nullptr;
    NimBLECharacteristic *_charImu     = nullptr;
    NimBLECharacteristic *_charStatus  = nullptr;
    NimBLECharacteristic *_charVibrate = nullptr;
    NimBLECharacteristic *_charConfig  = nullptr;

    VibrationActuator *_vib = nullptr;
    int _connectedCount = 0;
};
