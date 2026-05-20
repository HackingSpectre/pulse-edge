/*
  PulseEdge ESP32 DevKitV1 firmware

  Upload target:
    - ESP32 DevKitV1 / ESP32-WROOM
    - Arduino IDE or PlatformIO Arduino framework

  Required libraries:
    - OneWire
    - DallasTemperature
    - MPU6050_light
    - SparkFun MAX3010x Sensor Library
    - ESP32 BLE Arduino

  BLE contract:
    This sketch is aligned with app/lib/core/ble/ble_protocol.dart and
    app/lib/core/ble/sensor_packet.dart in the Flutter app.
*/

#include <Arduino.h>
#include <math.h>
#include <string>

#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <MPU6050_light.h>
#include "MAX30105.h"
#include "heartRate.h"
#include "spo2_algorithm.h"

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// ================= Board pins =================
#define ONE_WIRE_BUS 4
#define SDA_PIN 21
#define SCL_PIN 22

// Optional. Set to an ADC pin connected to a battery divider if you add one.
// DevKitV1 USB testing normally has no battery ADC, so keep disabled.
#define BATTERY_ADC_PIN -1
#define BATTERY_DIVIDER_RATIO 2.0f

// Optional vibration motor pin. Keep disabled on a bare DevKitV1.
#define VIBRATE_PIN -1

// ================= PulseEdge BLE UUIDs =================
#define PE_ADV_NAME "PulseEdge"

#define PE_SERVICE_UUID       "b9e3a000-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_PPG_UUID      "b9e3a001-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_TEMP_UUID     "b9e3a002-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_IMU_UUID      "b9e3a003-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_STATUS_UUID   "b9e3a004-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_VIBRATE_UUID  "b9e3a005-9c5b-4f0e-8b3a-1f6f8c2c8a01"
#define PE_CHAR_CONFIG_UUID   "b9e3a006-9c5b-4f0e-8b3a-1f6f8c2c8a01"

// ================= Timing =================
static const uint32_t IMU_SAMPLE_MS = 20;      // 50 Hz internal update
static const uint32_t PPG_NOTIFY_MS = 250;     // 4 Hz BLE PPG window
static const uint32_t IMU_NOTIFY_MS = 250;     // 4 Hz BLE IMU summary
static const uint32_t TEMP_NOTIFY_MS = 1000;   // 1 Hz temp
static const uint32_t STATUS_NOTIFY_MS = 5000; // 0.2 Hz status
static const uint32_t SERIAL_LOG_MS = 2000;

// ================= Sensors =================
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);
MPU6050 mpu(Wire);
MAX30105 maxSensor;

static bool tempOk = false;
static bool imuOk = false;
static bool ppgOk = false;

// ================= BLE =================
BLEServer *bleServer = nullptr;
BLECharacteristic *charPpg = nullptr;
BLECharacteristic *charTemp = nullptr;
BLECharacteristic *charImu = nullptr;
BLECharacteristic *charStatus = nullptr;
BLECharacteristic *charVibrate = nullptr;
BLECharacteristic *charConfig = nullptr;

static volatile bool deviceConnected = false;
static bool oldDeviceConnected = false;

// ================= Sensor state =================
static uint16_t ppgSeq = 0;
static float lastHrBpm = NAN;
static float lastSpo2 = NAN;
static bool contactOk = false;

static float lastTempC = NAN;
static uint32_t lastTempRequestMs = 0;

static float ax = NAN, ay = NAN, az = NAN;
static float gx = NAN, gy = NAN, gz = NAN;
static float magMean = 0.0f, magStd = 0.0f;

static const size_t PPG_WINDOW_N = 25;
static int16_t ppgWindow[PPG_WINDOW_N] = {0};
static size_t ppgWindowIdx = 0;
static float redDc = 0.0f;

static const size_t SPO2_N = 100;
static uint32_t irBuffer[SPO2_N] = {0};
static uint32_t redBuffer[SPO2_N] = {0};
static size_t spo2Idx = 0;
static bool spo2Filled = false;
static bool spo2Ready = false;

static const size_t HR_AVG_N = 6;
static float hrHistory[HR_AVG_N] = {0};
static size_t hrHistoryIdx = 0;
static size_t hrHistoryCount = 0;
static uint32_t lastBeatMs = 0;

static const size_t MAG_N = 32;
static float magRing[MAG_N] = {0};
static size_t magIdx = 0;

// ================= Helpers =================
template <typename T>
static void pack(uint8_t *&p, T value) {
  memcpy(p, &value, sizeof(T));
  p += sizeof(T);
}

static uint8_t crc8(const uint8_t *data, size_t len) {
  uint8_t crc = 0x00;
  for (size_t i = 0; i < len; ++i) {
    crc ^= data[i];
    for (uint8_t bit = 0; bit < 8; ++bit) {
      crc = (crc & 0x80) ? (uint8_t)((crc << 1) ^ 0x07) : (uint8_t)(crc << 1);
    }
  }
  return crc;
}

static int16_t clampInt16(long v) {
  if (v > 32767) return 32767;
  if (v < -32768) return -32768;
  return (int16_t)v;
}

static uint8_t batteryPercent() {
#if BATTERY_ADC_PIN >= 0
  const int raw = analogRead(BATTERY_ADC_PIN);
  const float volts = (raw / 4095.0f) * 3.3f * BATTERY_DIVIDER_RATIO;
  const float pct = (volts - 3.30f) * 100.0f / (4.20f - 3.30f);
  return (uint8_t)constrain((int)roundf(pct), 0, 100);
#else
  return 100;
#endif
}

static void addNotifyDescriptor(BLECharacteristic *c) {
  c->addDescriptor(new BLE2902());
}

static void startAdvertising() {
  BLEAdvertising *adv = BLEDevice::getAdvertising();
  adv->addServiceUUID(PE_SERVICE_UUID);
  adv->setScanResponse(true);
  adv->setMinPreferred(0x06);
  adv->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *server) override {
    deviceConnected = true;
    Serial.println("[BLE] client connected");
  }

  void onDisconnect(BLEServer *server) override {
    deviceConnected = false;
    Serial.println("[BLE] client disconnected");
  }
};

class VibrateCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *c) override {
    String value = String(c->getValue().c_str());
    if (value.length() == 0) return;

    const uint8_t pattern = (uint8_t)value[0];
    Serial.printf("[BLE] vibrate pattern=%u\n", pattern);

#if VIBRATE_PIN >= 0
    const uint16_t shortMs = 160;
    if (pattern == 1) {
      digitalWrite(VIBRATE_PIN, HIGH);
      delay(shortMs);
      digitalWrite(VIBRATE_PIN, LOW);
    } else if (pattern == 2) {
      for (int i = 0; i < 2; ++i) {
        digitalWrite(VIBRATE_PIN, HIGH);
        delay(120);
        digitalWrite(VIBRATE_PIN, LOW);
        delay(90);
      }
    } else if (pattern == 3) {
      for (int i = 0; i < 3; ++i) {
        digitalWrite(VIBRATE_PIN, HIGH);
        delay(90);
        digitalWrite(VIBRATE_PIN, LOW);
        delay(90);
      }
    }
#endif
  }
};

// ================= BLE setup =================
static void setupBle() {
  BLEDevice::init(PE_ADV_NAME);
  BLEDevice::setMTU(247);

  bleServer = BLEDevice::createServer();
  bleServer->setCallbacks(new ServerCallbacks());

  BLEService *service = bleServer->createService(PE_SERVICE_UUID);

  charPpg = service->createCharacteristic(
      PE_CHAR_PPG_UUID,
      BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ);
  charTemp = service->createCharacteristic(
      PE_CHAR_TEMP_UUID,
      BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ);
  charImu = service->createCharacteristic(
      PE_CHAR_IMU_UUID,
      BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ);
  charStatus = service->createCharacteristic(
      PE_CHAR_STATUS_UUID,
      BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ);
  charVibrate = service->createCharacteristic(
      PE_CHAR_VIBRATE_UUID,
      BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
  charConfig = service->createCharacteristic(
      PE_CHAR_CONFIG_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

  addNotifyDescriptor(charPpg);
  addNotifyDescriptor(charTemp);
  addNotifyDescriptor(charImu);
  addNotifyDescriptor(charStatus);

  charVibrate->setCallbacks(new VibrateCallbacks());
  charConfig->setValue("PulseEdge DevKitV1 FW 0.1");

  service->start();
  startAdvertising();

  Serial.println("[BLE] advertising as PulseEdge");
}

// ================= Sensor setup =================
static void setupSensors() {
  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(400000);

  Serial.println("[TEMP] starting DS18B20");
  tempSensor.begin();
  tempOk = tempSensor.getDeviceCount() > 0;
  if (tempOk) {
    tempSensor.setResolution(11);
    tempSensor.setWaitForConversion(false);
    tempSensor.requestTemperatures();
    lastTempRequestMs = millis();
    Serial.println("[TEMP] connected");
  } else {
    Serial.println("[TEMP] not found; continuing without temperature");
  }

  Serial.println("[IMU] starting MPU6050");
  const byte mpuStatus = mpu.begin();
  imuOk = (mpuStatus == 0);
  if (imuOk) {
    delay(500);
    mpu.calcOffsets();
    Serial.println("[IMU] connected");
  } else {
    Serial.printf("[IMU] not found status=%u; continuing without motion\n", mpuStatus);
  }

  Serial.println("[PPG] starting MAX30102/MAX30105");
  ppgOk = maxSensor.begin(Wire, I2C_SPEED_FAST);
  if (ppgOk) {
    // ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange
    // ledMode 2 = red + IR. This supports HR and SpO2 estimation.
    maxSensor.setup(0x3F, 4, 2, 100, 411, 4096);
    maxSensor.setPulseAmplitudeIR(0x3F);
    maxSensor.setPulseAmplitudeRed(0x1F);
    maxSensor.setPulseAmplitudeGreen(0);
    Serial.println("[PPG] connected");
  } else {
    Serial.println("[PPG] not found; continuing without PPG");
  }
}

// ================= Sensor updates =================
static void updateTemperature(uint32_t now) {
  if (!tempOk) return;
  if (now - lastTempRequestMs < 1000) return;

  const float t = tempSensor.getTempCByIndex(0);
  if (t != DEVICE_DISCONNECTED_C && t > -20.0f && t < 80.0f) {
    lastTempC = t;
  } else {
    Serial.println("[TEMP] invalid read");
  }

  tempSensor.requestTemperatures();
  lastTempRequestMs = now;
}

static void updateImu() {
  if (!imuOk) return;

  mpu.update();
  ax = mpu.getAccX() * 9.80665f;
  ay = mpu.getAccY() * 9.80665f;
  az = mpu.getAccZ() * 9.80665f;
  gx = mpu.getGyroX();
  gy = mpu.getGyroY();
  gz = mpu.getGyroZ();

  const float magG = sqrtf(ax * ax + ay * ay + az * az) / 9.80665f;
  magRing[magIdx++ % MAG_N] = magG;

  float sum = 0.0f;
  float sumSq = 0.0f;
  for (size_t i = 0; i < MAG_N; ++i) {
    sum += magRing[i];
    sumSq += magRing[i] * magRing[i];
  }
  magMean = sum / MAG_N;
  const float var = max(0.0f, (sumSq / MAG_N) - (magMean * magMean));
  magStd = sqrtf(var);
}

static void updatePpg() {
  if (!ppgOk) return;

  maxSensor.check();
  while (maxSensor.available()) {
    const uint32_t red = maxSensor.getRed();
    const uint32_t ir = maxSensor.getIR();
    maxSensor.nextSample();

    contactOk = ir > 50000;

    if (redDc == 0.0f) redDc = (float)red;
    redDc = 0.98f * redDc + 0.02f * (float)red;
    const long acRed = (long)((float)red - redDc);
    ppgWindow[ppgWindowIdx++ % PPG_WINDOW_N] = clampInt16(acRed);

    irBuffer[spo2Idx] = ir;
    redBuffer[spo2Idx] = red;
    spo2Idx++;
    if (spo2Idx >= SPO2_N) {
      spo2Idx = 0;
      spo2Filled = true;
      spo2Ready = true;
    }

    if (contactOk && checkForBeat(ir)) {
      const uint32_t now = millis();
      if (lastBeatMs > 0) {
        const uint32_t dt = now - lastBeatMs;
        const float bpm = 60000.0f / (float)dt;
        if (bpm >= 35.0f && bpm <= 220.0f) {
          hrHistory[hrHistoryIdx++ % HR_AVG_N] = bpm;
          if (hrHistoryCount < HR_AVG_N) hrHistoryCount++;

          float sum = 0.0f;
          for (size_t i = 0; i < hrHistoryCount; ++i) sum += hrHistory[i];
          lastHrBpm = sum / (float)hrHistoryCount;
        }
      }
      lastBeatMs = now;
    }
  }

  if (spo2Filled && spo2Ready) {
    spo2Ready = false;
    int32_t spo2 = 0;
    int8_t validSpo2 = 0;
    int32_t hr = 0;
    int8_t validHr = 0;

    maxim_heart_rate_and_oxygen_saturation(
        irBuffer,
        SPO2_N,
        redBuffer,
        &spo2,
        &validSpo2,
        &hr,
        &validHr);

    if (validSpo2 && spo2 >= 70 && spo2 <= 100) {
      lastSpo2 = (float)spo2;
    } else {
      lastSpo2 = NAN;
    }

    if ((!isfinite(lastHrBpm) || lastHrBpm <= 0) &&
        validHr && hr >= 35 && hr <= 220) {
      lastHrBpm = (float)hr;
    }
  }
}

// ================= Notifications =================
static void notifyPpg(uint32_t now) {
  if (!deviceConnected || charPpg == nullptr) return;

  uint8_t buf[16 + PPG_WINDOW_N * 2 + 1];
  uint8_t *p = buf;

  pack<uint16_t>(p, ++ppgSeq);
  pack<uint32_t>(p, now);
  pack<float>(p, lastHrBpm);
  pack<float>(p, lastSpo2);
  pack<uint16_t>(p, (uint16_t)PPG_WINDOW_N);

  const size_t start = ppgWindowIdx % PPG_WINDOW_N;
  for (size_t i = 0; i < PPG_WINDOW_N; ++i) {
    const int16_t sample = ppgWindow[(start + i) % PPG_WINDOW_N];
    pack<int16_t>(p, sample);
  }

  *p = crc8(buf, (size_t)(p - buf));
  p++;

  charPpg->setValue(buf, (size_t)(p - buf));
  charPpg->notify();
}

static void notifyTemp(uint32_t now) {
  if (!deviceConnected || charTemp == nullptr) return;

  uint8_t buf[8];
  uint8_t *p = buf;
  pack<uint32_t>(p, now);
  pack<float>(p, lastTempC);

  charTemp->setValue(buf, sizeof(buf));
  charTemp->notify();
}

static void notifyImu(uint32_t now) {
  if (!deviceConnected || charImu == nullptr) return;

  uint8_t buf[36];
  uint8_t *p = buf;
  pack<uint32_t>(p, now);
  pack<float>(p, ax);
  pack<float>(p, ay);
  pack<float>(p, az);
  pack<float>(p, gx);
  pack<float>(p, gy);
  pack<float>(p, gz);
  pack<float>(p, magMean);
  pack<float>(p, magStd);

  charImu->setValue(buf, sizeof(buf));
  charImu->notify();
}

static void notifyStatus() {
  if (!deviceConnected || charStatus == nullptr) return;

  uint8_t flags = 0;
  const bool allSensorsOk = tempOk && imuOk && ppgOk;
  if (allSensorsOk) flags |= 0x02;
  if (ppgOk) flags |= 0x08;
  if (tempOk) flags |= 0x10;
  if (imuOk) flags |= 0x20;
  if (contactOk) flags |= 0x40;

  uint8_t buf[4] = {
      batteryPercent(),
      flags,
      0, // firmware major
      1  // firmware minor
  };

  charStatus->setValue(buf, sizeof(buf));
  charStatus->notify();
}

static void logStatus(uint32_t now) {
  Serial.println();
  Serial.println("========== PulseEdge ==========");
  Serial.printf("uptime=%lu ms connected=%s\n", (unsigned long)now, deviceConnected ? "yes" : "no");
  Serial.printf("sensors: ppg=%s temp=%s imu=%s contact=%s\n",
                ppgOk ? "ok" : "missing",
                tempOk ? "ok" : "missing",
                imuOk ? "ok" : "missing",
                contactOk ? "yes" : "no");
  Serial.printf("hr=%.1f bpm spo2=%.1f temp=%.2f C\n", lastHrBpm, lastSpo2, lastTempC);
  Serial.printf("accel=%.2f %.2f %.2f m/s2 gyro=%.2f %.2f %.2f dps\n",
                ax, ay, az, gx, gy, gz);
}

// ================= Arduino lifecycle =================
void setup() {
  Serial.begin(115200);
  delay(300);
  Serial.println();
  Serial.println("[PulseEdge] booting DevKitV1 firmware");

#if VIBRATE_PIN >= 0
  pinMode(VIBRATE_PIN, OUTPUT);
  digitalWrite(VIBRATE_PIN, LOW);
#endif

  setupSensors();
  setupBle();

  Serial.println("[PulseEdge] setup complete");
}

void loop() {
  const uint32_t now = millis();

  static uint32_t lastImuMs = 0;
  static uint32_t lastPpgNotifyMs = 0;
  static uint32_t lastImuNotifyMs = 0;
  static uint32_t lastTempNotifyMs = 0;
  static uint32_t lastStatusNotifyMs = 0;
  static uint32_t lastSerialLogMs = 0;

  if (!deviceConnected && oldDeviceConnected) {
    delay(300);
    startAdvertising();
    oldDeviceConnected = deviceConnected;
    Serial.println("[BLE] advertising restarted");
  }
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }

  updatePpg();
  updateTemperature(now);

  if (now - lastImuMs >= IMU_SAMPLE_MS) {
    lastImuMs = now;
    updateImu();
  }

  if (now - lastPpgNotifyMs >= PPG_NOTIFY_MS) {
    lastPpgNotifyMs = now;
    notifyPpg(now);
  }

  if (now - lastImuNotifyMs >= IMU_NOTIFY_MS) {
    lastImuNotifyMs = now;
    notifyImu(now);
  }

  if (now - lastTempNotifyMs >= TEMP_NOTIFY_MS) {
    lastTempNotifyMs = now;
    notifyTemp(now);
  }

  if (now - lastStatusNotifyMs >= STATUS_NOTIFY_MS) {
    lastStatusNotifyMs = now;
    notifyStatus();
  }

  if (now - lastSerialLogMs >= SERIAL_LOG_MS) {
    lastSerialLogMs = now;
    logStatus(now);
  }

  delay(2);
}
