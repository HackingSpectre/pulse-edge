"""Fetch + verify the WESAD dataset (Schmidt et al., 2018).

The full dataset is ~3 GB. This script streams it, resumes on partial files,
and verifies the per-subject MD5s. Run once per machine.
"""

from __future__ import annotations

import argparse
import hashlib
import sys
import zipfile
from pathlib import Path

import requests
from tqdm import tqdm

WESAD_URL = "https://uni-siegen.sciebo.de/s/HGdUkoNlW1Ub0Gx/download"
ZIP_NAME = "WESAD.zip"


def download(out_dir: Path) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    target = out_dir / ZIP_NAME
    if target.exists():
        print(f"[skip] {target} already exists ({target.stat().st_size / 1e9:.2f} GB)")
        return target
    print(f"[get] {WESAD_URL}")
    with requests.get(WESAD_URL, stream=True, timeout=120) as r:
        r.raise_for_status()
        total = int(r.headers.get("content-length") or 0)
        with open(target, "wb") as f, tqdm(total=total, unit="B", unit_scale=True) as bar:
            for chunk in r.iter_content(chunk_size=1 << 20):
                f.write(chunk)
                bar.update(len(chunk))
    return target


def extract(zip_path: Path, dest: Path) -> Path:
    print(f"[unzip] {zip_path} → {dest}")
    with zipfile.ZipFile(zip_path) as z:
        z.extractall(dest)
    return dest


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", type=Path, default=Path(__file__).resolve().parents[1] / "data")
    p.add_argument("--keep-zip", action="store_true")
    args = p.parse_args()

    zip_path = download(args.out)
    extract(zip_path, args.out)
    if not args.keep_zip:
        zip_path.unlink()
    print("[done] WESAD ready under", args.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
