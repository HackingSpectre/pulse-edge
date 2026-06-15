# Training the Anomaly Model on Lightning AI

This guide explains how to train the Pulse Edge anomaly detector on Lightning
AI Studio instead of your local VS Code machine.

The goal is simple:

1. Download the real WESAD dataset in the cloud.
2. Extract the wrist-sensor features used by the Flutter app.
3. Train a small TensorFlow Lite classifier.
4. Download only the final lightweight files back to your project.

The final `anomaly.tflite` should be tiny compared with the dataset. The WESAD
zip is about 2.25 GB, but the trained model is expected to be in the KB range
for the lightweight MLP pipeline.

## Why Use Lightning AI?

Use Lightning AI because the heavy work is the dataset download, Python
scientific packages, and training environment setup. Your local PC only needs
the final exported model.

Official references:

- Lightning AI Studio: https://lightning.ai/docs/overview/ai-studio/
- Upload data: https://lightning.ai/docs/overview/upload-data
- Import datasets: https://lightning.ai/docs/overview/datasets/import-dataset

## What You Need

- A Lightning AI account.
- This project pushed to GitHub, or uploaded manually into a Studio.
- A Studio with enough disk space for WESAD. Use at least 10 GB free space.
- Python 3.10 or 3.11 is recommended for TensorFlow compatibility.

## Recommended Workflow

### 1. Open a Lightning AI Studio

Create a new Studio from the Lightning AI dashboard.

Inside the Studio terminal, clone your repo:

```bash
git clone <your-repo-url> pulse-edge
cd pulse-edge
```

If you do not use GitHub yet, upload the project folder through the Studio file
browser or Lightning Drive.

### 2. Set Up the Python Environment

From the repo root:

```bash
cd ml/anomaly
python --version
pip install -r requirements.txt
```

If TensorFlow refuses to install, check the Python version. TensorFlow usually
does not support very new Python versions immediately, so use Python 3.10 or
3.11 in the Studio.

### 3. Download the Real WESAD Dataset

Run:

```bash
python scripts/fetch_wesad.py --keep-zip
```

This downloads the official WESAD zip and extracts it under:

```text
ml/anomaly/data/
```

Keep the zip in the Studio so you do not need to download it again if you
restart feature extraction.

Verify that subject pickle files exist:

```bash
find data -name "S*.pkl" | head
```

You should see paths for subjects such as `S2.pkl`, `S3.pkl`, and so on.

## Can We Download Only the Wrist Data?

Not cleanly from the official source.

The official WESAD release is provided as one large zip archive. The wrist and
chest streams are stored inside subject pickle files in that archive. Because
the server provides the dataset as a zip, the practical workflow is:

```text
download full WESAD zip
extract subject pickle files
read only wrist BVP, TEMP, and ACC streams
discard everything else during feature extraction
```

So we still download the full archive, but our scripts only use the wrist
signals needed by Pulse Edge:

- BVP/PPG
- temperature
- accelerometer
- labels

The extracted feature table is much smaller than the raw dataset.

## Optional Fast Test With Fewer Subjects

For a quick cloud test, you can make a small copy with only a few subject
folders after the full dataset has been downloaded.

Example:

```bash
mkdir -p data/WESAD_SMALL
cp -r data/WESAD/S2 data/WESAD_SMALL/
cp -r data/WESAD/S3 data/WESAD_SMALL/
cp -r data/WESAD/S4 data/WESAD_SMALL/
```

Then extract features from only that small subset:

```bash
python scripts/extract_features.py \
  --data data/WESAD_SMALL \
  --out exported/wesad_features_small.parquet
```

Train from the small feature table:

```bash
python scripts/train_anomaly.py \
  --data exported/wesad_features_small.parquet \
  --out exported/anomaly_small.tflite \
  --epochs 20
```

Use this only for a quick prototype. For the final model and report, train on
all available WESAD subjects.

## Full Training Run

Extract features:

```bash
python scripts/extract_features.py
```

Train and export the lightweight TFLite model:

```bash
python scripts/train_anomaly.py
```

Expected outputs:

```text
ml/anomaly/exported/anomaly.tflite
ml/anomaly/exported/eval_report.json
ml/anomaly/exported/wesad_features.parquet
```

The important file for Flutter is:

```text
ml/anomaly/exported/anomaly.tflite
```

The important file for your report/evaluation is:

```text
ml/anomaly/exported/eval_report.json
```

## Bring the Model Back to Flutter

Download `exported/anomaly.tflite` from Lightning AI.

Place it here in your local project:

```text
app/assets/models/anomaly.tflite
```

The app already lists `assets/models/` in `pubspec.yaml`, so the model can be
bundled with the Flutter build.

## How the Model Fits the App

The training script produces a model that accepts the same 12-feature vector
that Flutter creates at runtime:

```text
hr_mean
hr_std
hr_min
hr_max
rmssd
pnn50
spo2_mean
temp_mean
temp_slope
accel_mean
accel_std
activity
```

In Flutter, this order is defined in:

```text
app/lib/core/ml/feature_window.dart
```

The model outputs one value:

```text
0.0 = normal
1.0 = anomalous
```

The app then combines that model score with:

- hard safety rules
- the user's personal baseline
- alert thresholds

So the model stays lightweight while the final decision remains personalized.

## Recommended Final Report Wording

Use wording like this:

> The anomaly detector was trained on WESAD wrist-device streams and exported
> as a lightweight TensorFlow Lite classifier. The Flutter application computes
> matching 30-second feature windows locally and runs the model on-device. The
> model output is combined with a personalized baseline engine and hard safety
> rules to generate real-time anomaly alerts without cloud inference.

Avoid saying the app trains the model on the phone. The phone performs
inference only.

## Troubleshooting

### TensorFlow will not install

Use Python 3.10 or 3.11. Very new Python versions may not have TensorFlow
wheels yet.

### The WESAD download is slow

That is normal. The official archive is large. Let Lightning AI handle it
rather than your local PC.

### The final model feels too big

Use the lightweight MLP path and avoid raw waveform models such as LSTM or
CNN-LSTM for v1. The current app is designed around compact feature vectors.

### The app uses the fallback instead of the model

Check that the file exists locally at:

```text
app/assets/models/anomaly.tflite
```

Then rebuild the Flutter app.
