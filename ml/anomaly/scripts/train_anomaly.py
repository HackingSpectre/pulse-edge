"""Train the on-device anomaly classifier and export to TFLite int8.

Loads the parquet produced by extract_features.py, runs subject-stratified
group K-fold, trains a small MLP, prints classification metrics, then
exports a quantized TFLite model into exported/anomaly.tflite.

The exported file is consumed by app/lib/core/ml/anomaly_detector.dart.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.metrics import classification_report, roc_auc_score
from sklearn.model_selection import GroupKFold
from sklearn.preprocessing import StandardScaler

FEATURES = [
    "hr_mean", "hr_std", "hr_min", "hr_max", "rmssd", "pnn50",
    "spo2_mean", "temp_mean", "temp_slope", "accel_mean", "accel_std",
    "activity",
]


def build_model(n_in: int) -> tf.keras.Model:
    inp = tf.keras.Input(shape=(n_in,))
    x = tf.keras.layers.Dense(32, activation="relu")(inp)
    x = tf.keras.layers.Dropout(0.2)(x)
    x = tf.keras.layers.Dense(16, activation="relu")(x)
    out = tf.keras.layers.Dense(1, activation="sigmoid")(x)
    model = tf.keras.Model(inp, out)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss="binary_crossentropy",
        metrics=["accuracy", tf.keras.metrics.AUC(name="auc")],
    )
    return model


def export_tflite(model: tf.keras.Model, scaler: StandardScaler, out: Path) -> None:
    # Wrap the model so the exported graph normalizes its own inputs — keeps
    # the Dart side free of feature-scaling logic.
    inp = tf.keras.Input(shape=(len(FEATURES),))
    mean = tf.constant(scaler.mean_, dtype=tf.float32)
    std = tf.constant(scaler.scale_, dtype=tf.float32)
    x = (inp - mean) / std
    x = model(x)
    wrapped = tf.keras.Model(inp, x)

    converter = tf.lite.TFLiteConverter.from_keras_model(wrapped)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite = converter.convert()
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(tflite)
    print(f"[ok] wrote {out} ({len(tflite) / 1024:.1f} KB)")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument(
        "--data",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "exported" / "wesad_features.parquet",
    )
    p.add_argument(
        "--out",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "exported" / "anomaly.tflite",
    )
    p.add_argument("--epochs", type=int, default=40)
    p.add_argument("--seed", type=int, default=42)
    args = p.parse_args()

    if not args.data.exists():
        print(f"[err] features not found: {args.data}", file=sys.stderr)
        print("       run scripts/extract_features.py first", file=sys.stderr)
        return 1

    np.random.seed(args.seed)
    tf.random.set_seed(args.seed)

    df = pd.read_parquet(args.data)
    X = df[FEATURES].values.astype(np.float32)
    y = df["anomaly"].values.astype(np.float32)
    g = df["subject"].values

    # Subject-stratified CV — never let a subject leak across splits.
    gkf = GroupKFold(n_splits=5)
    fold_metrics = []
    for fold, (tr, te) in enumerate(gkf.split(X, y, groups=g)):
        scaler = StandardScaler().fit(X[tr])
        Xtr = scaler.transform(X[tr])
        Xte = scaler.transform(X[te])
        model = build_model(Xtr.shape[1])
        model.fit(
            Xtr,
            y[tr],
            validation_data=(Xte, y[te]),
            epochs=args.epochs,
            batch_size=64,
            verbose=0,
        )
        prob = model.predict(Xte, verbose=0).flatten()
        pred = (prob > 0.5).astype(int)
        auc = roc_auc_score(y[te], prob)
        fold_metrics.append({"fold": fold, "auc": float(auc)})
        print(f"[fold {fold}] AUC={auc:.3f}")
        print(classification_report(y[te], pred, digits=3))

    # Final fit on all data with the median fold's scaler.
    scaler = StandardScaler().fit(X)
    Xs = scaler.transform(X)
    model = build_model(X.shape[1])
    model.fit(Xs, y, epochs=args.epochs, batch_size=64, verbose=0)
    export_tflite(model, scaler, args.out)

    report = {
        "features": FEATURES,
        "n_samples": int(len(df)),
        "n_subjects": int(df["subject"].nunique()),
        "fold_metrics": fold_metrics,
        "mean_auc": float(np.mean([f["auc"] for f in fold_metrics])),
    }
    rep_path = args.out.with_name("eval_report.json")
    rep_path.write_text(json.dumps(report, indent=2))
    print(f"[ok] mean AUC = {report['mean_auc']:.3f} → {rep_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
