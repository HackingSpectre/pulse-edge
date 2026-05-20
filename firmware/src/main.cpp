// ─── Pulse Edge wearable firmware ──────────────────────────────────────────
//
// Three FreeRTOS tasks pinned to the appropriate cores:
//   - sampler  (core 0): PPG @ ~100 Hz, IMU @ ~25 Hz, Temp @ ~1 Hz
//   - notifier (core 1): drains the ring buffers, packs binary frames,
//                        and pushes BLE notifications every 200 ms
//   - status   (core 1): battery + flags every 5 s
//
// Ring buffers are lock-free single-producer / single-consumer.

#include <Arduino.h>
#include <Wire.h>

#include "ble_uuids.h"
#include "imu_sensor.h"
#include "pe_ble_server.h"
#include "pin_map.h"
#include "ppg_sensor.h"
#include "temp_sensor.h"

// ─── globals ───────────────────────────────────────────────────────────────

static PpgSensor  ppg;
static TempSensor temp;
static ImuSensor  imu;
static PeBleServer ble;

class Vibrator final : public VibrationActuator {
public:
    void begin() {
        ledcSetup(VIB_LEDC_CH, VIB_LEDC_HZ, VIB_LEDC_RES);
        ledcAttachPin(PIN_VIBRATE, VIB_LEDC_CH);
        ledcWrite(VIB_LEDC_CH, 0);
    }
    void play(uint8_t pattern) override {
        switch (pattern) {
            case VIB_SHORT:  _pulse(180); break;
            case VIB_DOUBLE: _pulse(120); delay(80); _pulse(120); break;
            case VIB_SOS:    for (int i=0;i<3;++i){_pulse(80); delay(80);}
                             delay(120);
                             for (int i=0;i<3;++i){_pulse(220); delay(120);}
                             delay(120);
                             for (int i=0;i<3;++i){_pulse(80); delay(80);}
                             break;
            default: break;
        }
    }
private:
    void _pulse(uint16_t ms) {
        ledcWrite(VIB_LEDC_CH, 200);
        delay(ms);
        ledcWrite(VIB_LEDC_CH, 0);
    }
} vibrator;

// ─── frame helpers ─────────────────────────────────────────────────────────

static uint16_t ppgSeq = 0;
static uint16_t imuSeq = 0;

template <typename T>
static void pack(uint8_t *&p, T v) {
    memcpy(p, &v, sizeof(T));
    p += sizeof(T);
}

// ─── tasks ─────────────────────────────────────────────────────────────────

static void samplerTask(void *) {
    TickType_t last = xTaskGetTickCount();
    for (;;) {
        ppg.update();
        imu.update();
        temp.update();
        // Run at ~100 Hz; PPG drives the cadence.
        vTaskDelayUntil(&last, pdMS_TO_TICKS(10));
    }
}

static void notifierTask(void *) {
    constexpr size_t kPpgWindow = 25;
    int16_t window[kPpgWindow] = {0};

    for (;;) {
        const uint32_t ts = millis();
        if (ble.isConnected()) {
            // ── PPG frame ──
            ppg.snapshotWindow(window, kPpgWindow);
            const float bpm = ppg.lastBpm();
            const float spo2 = ppg.lastSpo2();
            uint8_t buf[16 + kPpgWindow * 2 + 1];
            uint8_t *p = buf;
            pack<uint16_t>(p, ++ppgSeq);
            pack<uint32_t>(p, ts);
            pack<float>(p, bpm);
            pack<float>(p, spo2);
            pack<uint16_t>(p, kPpgWindow);
            for (size_t i = 0; i < kPpgWindow; ++i) {
                pack<int16_t>(p, window[i]);
            }
            *p++ = 0; // crc8 placeholder
            ble.notifyPpg(buf, p - buf);

            // ── Temp frame ──
            const float tC = temp.celsius();
            uint8_t tbuf[8];
            uint8_t *tp = tbuf;
            pack<uint32_t>(tp, ts);
            pack<float>(tp, tC);
            ble.notifyTemp(tbuf, tp - tbuf);

            // ── IMU frame ──
            float ax, ay, az, gx, gy, gz, magMean, magStd;
            imu.snapshot(ax, ay, az, gx, gy, gz, magMean, magStd);
            uint8_t ibuf[36];
            uint8_t *ip = ibuf;
            pack<uint32_t>(ip, ts);
            pack<float>(ip, ax);
            pack<float>(ip, ay);
            pack<float>(ip, az);
            pack<float>(ip, gx);
            pack<float>(ip, gy);
            pack<float>(ip, gz);
            pack<float>(ip, magMean);
            pack<float>(ip, magStd);
            ble.notifyImu(ibuf, ip - ibuf);

            ++imuSeq;
        }
        vTaskDelay(pdMS_TO_TICKS(200));
    }
}

static void statusTask(void *) {
    for (;;) {
        if (ble.isConnected()) {
            const uint16_t raw = analogRead(PIN_VBAT_SENSE);
            const float volts = (raw / 4095.f) * 3.3f * VBAT_DIV_RATIO;
            const float pct = constrain((volts - 3.3f) / (4.2f - 3.3f) * 100.f,
                                        0.f, 100.f);
            uint8_t flags = 0;
            flags |= 0x02; // sensorOk
            uint8_t buf[4] = {static_cast<uint8_t>(pct), flags, 0, 1};
            ble.notifyStatus(buf, sizeof(buf));
        }
        vTaskDelay(pdMS_TO_TICKS(5000));
    }
}

// ─── setup / loop ──────────────────────────────────────────────────────────

void setup() {
    Serial.begin(115200);
    delay(200);
    Serial.println("\n[Pulse Edge] booting…");

    Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL, I2C_FREQ_HZ);

    pinMode(PIN_STATUS_LED, OUTPUT);
    digitalWrite(PIN_STATUS_LED, HIGH);

    if (!ppg.begin())  Serial.println("[!] PPG init failed");
    if (!temp.begin()) Serial.println("[!] Temp init failed");
    if (!imu.begin())  Serial.println("[!] IMU init failed");

    vibrator.begin();
    ble.begin(&vibrator);

    xTaskCreatePinnedToCore(samplerTask,  "sampler",  4096, nullptr, 3, nullptr, 0);
    xTaskCreatePinnedToCore(notifierTask, "notifier", 4096, nullptr, 2, nullptr, 1);
    xTaskCreatePinnedToCore(statusTask,   "status",   2048, nullptr, 1, nullptr, 1);

    Serial.println("[Pulse Edge] tasks running. Advertising as " PE_ADV_NAME);
}

void loop() {
    // All work happens in tasks. Blink to show life.
    static uint32_t last = 0;
    const uint32_t now = millis();
    if (now - last > 1000) {
        last = now;
        digitalWrite(PIN_STATUS_LED, !digitalRead(PIN_STATUS_LED));
    }
    delay(50);
}
