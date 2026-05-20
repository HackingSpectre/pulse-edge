#include "pe_ble_server.h"

#include <Arduino.h>

// VibrationActuator is implemented in main.cpp; we only need its forward decl
// + a minimal interface for the write callback.
class VibrationActuator {
public:
    virtual void play(uint8_t pattern) = 0;
};

void PeBleServer::begin(VibrationActuator *vib) {
    _vib = vib;

    NimBLEDevice::init(PE_ADV_NAME);
    NimBLEDevice::setMTU(247);
    NimBLEDevice::setPower(ESP_PWR_LVL_P9);

    _server = NimBLEDevice::createServer();
    _server->setCallbacks(this);

    auto *svc = _server->createService(PE_SERVICE_UUID);

    _charPpg = svc->createCharacteristic(
        PE_CHAR_PPG_UUID, NIMBLE_PROPERTY::NOTIFY);
    _charTemp = svc->createCharacteristic(
        PE_CHAR_TEMP_UUID, NIMBLE_PROPERTY::NOTIFY);
    _charImu = svc->createCharacteristic(
        PE_CHAR_IMU_UUID, NIMBLE_PROPERTY::NOTIFY);
    _charStatus = svc->createCharacteristic(
        PE_CHAR_STATUS_UUID, NIMBLE_PROPERTY::NOTIFY);
    _charVibrate = svc->createCharacteristic(
        PE_CHAR_VIBRATE_UUID, NIMBLE_PROPERTY::WRITE);
    _charConfig = svc->createCharacteristic(
        PE_CHAR_CONFIG_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE);

    _charVibrate->setCallbacks(this);

    svc->start();

    auto *adv = NimBLEDevice::getAdvertising();
    adv->addServiceUUID(svc->getUUID());
    adv->setName(PE_ADV_NAME);
    adv->enableScanResponse(true);
    adv->start();
}

void PeBleServer::notifyPpg(const uint8_t *bytes, size_t len) {
    if (_charPpg && isConnected()) _charPpg->notify(bytes, len);
}
void PeBleServer::notifyTemp(const uint8_t *bytes, size_t len) {
    if (_charTemp && isConnected()) _charTemp->notify(bytes, len);
}
void PeBleServer::notifyImu(const uint8_t *bytes, size_t len) {
    if (_charImu && isConnected()) _charImu->notify(bytes, len);
}
void PeBleServer::notifyStatus(const uint8_t *bytes, size_t len) {
    if (_charStatus && isConnected()) _charStatus->notify(bytes, len);
}

void PeBleServer::onConnect(NimBLEServer *s, NimBLEConnInfo &info) {
    _connectedCount++;
    Serial.printf("[BLE] connected (n=%d)\n", _connectedCount);
}

void PeBleServer::onDisconnect(NimBLEServer *s, NimBLEConnInfo &info, int reason) {
    _connectedCount = max(0, _connectedCount - 1);
    Serial.printf("[BLE] disconnected reason=%d (n=%d)\n", reason, _connectedCount);
    NimBLEDevice::startAdvertising();
}

void PeBleServer::onWrite(NimBLECharacteristic *c, NimBLEConnInfo &info) {
    if (c == _charVibrate && _vib) {
        const auto v = c->getValue();
        if (!v.empty()) _vib->play(v[0]);
    }
}
