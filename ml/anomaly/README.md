# Anomaly model

WESAD-trained binary anomaly classifier exported as int8 TFLite for the
Pulse Edge mobile app.

## Pipeline

```bash
cd ml/anomaly
pip install -r requirements.txt

# 1. Fetch the dataset (~3 GB, one-time)
python scripts/fetch_wesad.py

# 2. Extract 30 s / 5 s feature windows
python scripts/extract_features.py

# 3. Train + export the on-device model
python scripts/train_anomaly.py
```

The exported `exported/anomaly.tflite` is what the app loads at runtime.
Drop the file under `app/assets/models/anomaly.tflite` (and add it to
`pubspec.yaml > flutter > assets:`) to bundle, OR copy it into the app's
documents directory at `pulse_edge/anomaly.tflite` to side-load without
rebuilding the APK — `AnomalyDetector` looks in both.

## Feature spec

`feature_spec.json` is the single source of truth for the input ordering.
The Dart implementation in `app/lib/core/ml/feature_window.dart` mirrors
this and the test suite (TODO) verifies the parity.

## Splits

Always **subject-stratified** group K-fold (`scripts/train_anomaly.py`
uses `sklearn.model_selection.GroupKFold`). Random shuffles inflate
metrics by 10–20 percentage points because of within-subject correlation.
