"""Convert WESAD subject pickles into a (features, label) table.

Each row corresponds to one 30-second window with a 5-second hop, matching
the on-device FeatureExtractor in app/lib/core/ml/feature_extractor.dart.
"""

from __future__ import annotations

import argparse
import pickle
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.signal import welch

WINDOW_S = 30
HOP_S = 5
WRIST_PPG_FS = 64   # Empatica E4 BVP sample rate
WRIST_TEMP_FS = 4   # Empatica E4 temp
WRIST_ACC_FS = 32

LABELS = {
    1: ("baseline", 0),
    2: ("stress", 1),
    3: ("amusement", 0),
    4: ("meditation", 0),
}


def hr_from_bvp(bvp: np.ndarray, fs: int) -> float:
    if len(bvp) < fs * 4:
        return float("nan")
    f, p = welch(bvp, fs=fs, nperseg=min(len(bvp), fs * 8))
    band = (f >= 0.7) & (f <= 3.5)  # 42–210 bpm
    if not band.any():
        return float("nan")
    peak = f[band][np.argmax(p[band])]
    return float(peak * 60.0)


def rmssd_from_bvp(bvp: np.ndarray, fs: int) -> float:
    # Crude HR proxy → use peak-to-peak intervals.
    diff = np.diff(bvp)
    crossings = np.where(np.diff(np.sign(diff)) > 0)[0]
    if len(crossings) < 4:
        return 0.0
    rr_ms = np.diff(crossings) / fs * 1000.0
    if len(rr_ms) < 2:
        return 0.0
    return float(np.sqrt(np.mean(np.diff(rr_ms) ** 2)))


def process_subject(pickle_path: Path) -> pd.DataFrame:
    with open(pickle_path, "rb") as f:
        data = pickle.load(f, encoding="latin1")

    bvp = np.asarray(data["signal"]["wrist"]["BVP"]).flatten()
    temp = np.asarray(data["signal"]["wrist"]["TEMP"]).flatten()
    acc = np.asarray(data["signal"]["wrist"]["ACC"])  # N×3
    label = np.asarray(data["label"]).flatten()

    # Resample chest-domain label down to wrist BVP timeline.
    chest_fs = 700
    win = WINDOW_S * WRIST_PPG_FS
    hop = HOP_S * WRIST_PPG_FS
    rows = []
    for start in range(0, len(bvp) - win, hop):
        bvp_win = bvp[start : start + win]
        end_idx = start + win
        # Map BVP-time start to chest-fs label index.
        chest_start = int(start * chest_fs / WRIST_PPG_FS)
        chest_end = int(end_idx * chest_fs / WRIST_PPG_FS)
        if chest_end >= len(label):
            break
        labels_in_win = label[chest_start:chest_end]
        # Use majority label and skip if ambiguous (transitions).
        unique, counts = np.unique(labels_in_win, return_counts=True)
        majority = unique[counts.argmax()]
        if majority not in LABELS:
            continue
        lbl_name, anomaly = LABELS[int(majority)]

        # PPG-derived HR.
        hr = hr_from_bvp(bvp_win, WRIST_PPG_FS)
        if np.isnan(hr):
            continue
        rmssd = rmssd_from_bvp(bvp_win, WRIST_PPG_FS)
        # Crude temp slope/mean.
        t_start = int(start * WRIST_TEMP_FS / WRIST_PPG_FS)
        t_end = int(end_idx * WRIST_TEMP_FS / WRIST_PPG_FS)
        temp_win = temp[t_start:t_end] if t_end <= len(temp) else temp[t_start:]
        temp_mean = float(np.mean(temp_win)) if len(temp_win) else float("nan")
        temp_slope = (
            float((temp_win[-1] - temp_win[0]) / WINDOW_S)
            if len(temp_win) >= 2
            else 0.0
        )
        # Accel.
        a_start = int(start * WRIST_ACC_FS / WRIST_PPG_FS)
        a_end = int(end_idx * WRIST_ACC_FS / WRIST_PPG_FS)
        acc_win = acc[a_start:a_end]
        if len(acc_win) == 0:
            continue
        mag = np.linalg.norm(acc_win, axis=1) / 64.0  # normalize to ~g
        acc_mean = float(mag.mean())
        acc_std = float(mag.std())
        activity = 0 if acc_std < 0.4 else (1 if acc_std < 1.5 else 2)

        rows.append({
            "hr_mean": hr,
            "hr_std": float(np.std(bvp_win) / 50.0),  # surrogate
            "hr_min": float(hr * 0.95),
            "hr_max": float(hr * 1.05),
            "rmssd": rmssd,
            "pnn50": 0.0,
            "spo2_mean": float("nan"),
            "temp_mean": temp_mean,
            "temp_slope": temp_slope,
            "accel_mean": acc_mean,
            "accel_std": acc_std,
            "activity": activity,
            "anomaly": int(anomaly),
            "subject": pickle_path.stem,
        })
    return pd.DataFrame(rows)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--data", type=Path, default=Path(__file__).resolve().parents[1] / "data" / "WESAD")
    p.add_argument("--out", type=Path, default=Path(__file__).resolve().parents[1] / "exported" / "wesad_features.parquet")
    args = p.parse_args()

    pickles = sorted(args.data.glob("S*/S*.pkl"))
    if not pickles:
        print(f"[err] no .pkl found under {args.data}", file=sys.stderr)
        return 1

    frames = []
    for pkl in pickles:
        print(f"[parse] {pkl.name}")
        try:
            frames.append(process_subject(pkl))
        except Exception as e:
            print(f"  [skip] {pkl.name}: {e}", file=sys.stderr)

    df = pd.concat(frames, ignore_index=True).dropna()
    df["spo2_mean"] = df["spo2_mean"].fillna(df["hr_mean"])  # mirror Dart fallback

    args.out.parent.mkdir(parents=True, exist_ok=True)
    df.to_parquet(args.out)
    print(f"[ok] wrote {len(df)} rows → {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
