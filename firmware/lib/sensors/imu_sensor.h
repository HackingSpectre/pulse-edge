#pragma once

#include <MPU6050.h>

class ImuSensor {
public:
    bool begin();
    void update();

    void snapshot(float &ax, float &ay, float &az,
                  float &gx, float &gy, float &gz,
                  float &magMean, float &magStd);

private:
    MPU6050 _mpu;
    float _ax = 0, _ay = 0, _az = 9.81f;
    float _gx = 0, _gy = 0, _gz = 0;

    static constexpr size_t kMagN = 32;
    float _mag[kMagN] = {1.f};
    size_t _magIdx = 0;
};
