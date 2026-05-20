#include "imu_sensor.h"

#include <Arduino.h>
#include <Wire.h>
#include <math.h>

bool ImuSensor::begin() {
    _mpu.initialize();
    if (!_mpu.testConnection()) return false;
    _mpu.setFullScaleAccelRange(MPU6050_ACCEL_FS_4);
    _mpu.setFullScaleGyroRange(MPU6050_GYRO_FS_500);
    _mpu.setDLPFMode(MPU6050_DLPF_BW_42);
    return true;
}

void ImuSensor::update() {
    int16_t ax, ay, az, gx, gy, gz;
    _mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

    // Accel range ±4g → 8192 LSB/g; convert to m/s².
    constexpr float kAccelScale = 9.80665f / 8192.f;
    _ax = ax * kAccelScale;
    _ay = ay * kAccelScale;
    _az = az * kAccelScale;

    // Gyro ±500°/s → 65.5 LSB/(°/s).
    constexpr float kGyroScale = 1.f / 65.5f;
    _gx = gx * kGyroScale;
    _gy = gy * kGyroScale;
    _gz = gz * kGyroScale;

    const float mag = sqrtf(_ax * _ax + _ay * _ay + _az * _az) / 9.80665f;
    _mag[_magIdx++ % kMagN] = mag;
}

void ImuSensor::snapshot(float &ax, float &ay, float &az,
                         float &gx, float &gy, float &gz,
                         float &magMean, float &magStd) {
    ax = _ax; ay = _ay; az = _az;
    gx = _gx; gy = _gy; gz = _gz;

    float sum = 0, sumSq = 0;
    for (size_t i = 0; i < kMagN; ++i) {
        sum += _mag[i];
        sumSq += _mag[i] * _mag[i];
    }
    magMean = sum / kMagN;
    const float var = sumSq / kMagN - magMean * magMean;
    magStd = sqrtf(var > 0 ? var : 0);
}
