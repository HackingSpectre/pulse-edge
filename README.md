# Pulse Edge

> **Edge AI Wearable Health Monitoring System with Real-Time Anomaly Detection and Decision Support**
>
> Final-year project. A wrist-worn sensor + an Android app whose anomaly
> detection model AND language assistant both run **fully on the user's
> phone** — no cloud, no backend, no external storage.

---

## Repository layout

```
final-year-project/
├── PLAN.md                 # full implementation plan (the spec)
├── app/                    # Flutter mobile app (Android primary)
├── firmware/               # ESP32-WROOM PlatformIO project
├── ml/
│   ├── anomaly/            # WESAD → TFLite anomaly classifier pipeline
│   └── llm-finetune/       # Optional Unsloth LoRA on Gemma 3 1B
└── hardware/               # KiCad schematic + PCB (TODO)
```

Each subproject has its own README.

## Quick start

### 1. Run the app on a phone or emulator

```bash
cd app
flutter pub get
dart run build_runner build       # one-time, generates drift code
flutter run                       # connects to the first attached device
```

The app starts in **demo mode** — a built-in synthetic device feeds the
dashboard so you can explore the UI without hardware. To use the real
wearable, complete onboarding then tap **Pair** in Settings → Wearable.

### 2. Build & flash the wearable

```bash
pip install -U platformio
cd firmware
pio run -e devboard -t upload
pio device monitor
```

UUIDs in `firmware/include/ble_uuids.h` match
`app/lib/core/ble/ble_protocol.dart`.

### 3. Train the anomaly model (optional — a heuristic ships out of the box)

```bash
cd ml/anomaly
pip install -r requirements.txt
python scripts/fetch_wesad.py
python scripts/extract_features.py
python scripts/train_anomaly.py    # produces exported/anomaly.tflite
```

Drop the exported `.tflite` into `app/assets/models/anomaly.tflite` (and
add it to `pubspec.yaml` assets) before rebuilding the APK.

### 4. Fine-tune the on-device LLM (optional, ~30 min on Colab T4)

```
ml/llm-finetune/notebooks/01_unsloth_lora_gemma3.ipynb
```

Outputs a Q4_K_M GGUF the app can side-load via Settings → AI assistant →
custom URL.

## What's implemented

- **Mobile app** (Flutter, Android): neumorphic design system, full
  onboarding flow, biometric/PIN lock, drift-backed local time-series DB,
  BLE service with auto-reconnect, mock device source, on-device feature
  extractor, per-user Welford baseline, alert engine with hardcoded safety
  rules, LLM chat UI with streaming + scripted fallback, model download
  manager, background BLE keepalive, local notifications, dashboard with
  live HR ring + sparkline, history with date scrubber + charts, alert
  feed + detail with LLM explanations, comprehensive settings (profile,
  device, model, calibration, privacy, about), data wipe.
- **Firmware** (ESP32-WROOM, PlatformIO + NimBLE-Arduino): MAX30102 +
  DS18B20 + MPU6050 drivers, FreeRTOS task layout, BLE GATT server,
  vibration motor control.
- **ML pipeline** (Python): WESAD downloader, feature extractor (mirrors
  the Dart implementation), subject-stratified group K-fold training,
  TFLite int8 export with embedded normalization.
- **LLM fine-tuning** (Colab): Unsloth + LoRA notebook for Gemma 3 1B
  with persona examples + medical Q&A datasets, GGUF export.

## What's NOT in this repo (yet)

- KiCad schematic + PCB gerbers (`hardware/`)
- IEEE-style dissertation chapters 2–5 (`docs/report/`)
- 3D-printed enclosure files
- Trained `anomaly.tflite` and fine-tuned GGUF (run the pipelines)

## Architecture

See `PLAN.md` for the full system architecture, data-flow diagram, and
risk register.

```
ESP32 wearable
  │  (BLE GATT notifications, ~5 Hz)
  ▼
Flutter app (Android, fully offline)
  ├─ Drift (SQLite)              — sensor history
  ├─ FeatureExtractor            — 30 s / 5 s windows
  ├─ AnomalyDetector (TFLite)    — model probability
  ├─ BaselineService (Welford)   — per-user z-score
  ├─ AlertEngine                 — hardcoded rules + model + baseline
  ├─ LlmService (flutter_gemma)  — explanations, chat, summaries
  └─ NotificationsService        — push alerts
```

## License

Project source code is MIT. The neumorphism design system skill is © its
authors. Datasets carry their own licenses (WESAD: research-use; MedQuAD:
CC0; HealthSearchQA: Apache 2.0).

> **Pulse Edge is not a medical device.** It does not diagnose, treat, or
> prevent any condition. If you feel unwell, contact a healthcare
> professional.
