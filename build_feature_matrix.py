#!/usr/bin/env python3
"""
build_feature_matrix.py
========================
Runs the NeuroGuard AI research pipeline end-to-end on all EDF files found
in data/chbmit/ and data/siena/ to produce a reproducible feature matrix CSV.

Usage:
    python build_feature_matrix.py [--max-files N]

Outputs (written to ml_models/):
    features_chbmit.csv      — training-ready CSV (no metadata columns)
    features_full.csv        — CSV with patient_id / recording_id / dataset
    feature_schema.json      — canonical feature-column manifest

This script intentionally ignores demo_train.csv entirely.
"""

import sys
import argparse
import json
import numpy as np
import pandas as pd
from pathlib import Path

# ── Path bootstrap ────────────────────────────────────────────────────────────
REPO_ROOT = Path(__file__).resolve().parent
ML_DIR    = REPO_ROOT / "ml_models"
sys.path.insert(0, str(ML_DIR))

from research.eeg_io       import read_eeg_file, EEGIngestionError
from research.segmentation  import segment_recording
from research.feature_extraction import extract_features_classical

# ── Config ────────────────────────────────────────────────────────────────────

CHBMIT_DIR  = REPO_ROOT / "data" / "chbmit"
SIENA_DIR   = REPO_ROOT / "data" / "siena"
OUT_DIR     = ML_DIR

WINDOW_SEC  = 4.0   # seconds per epoch
STEP_SEC    = 2.0   # 50% overlap


# ── Helpers ───────────────────────────────────────────────────────────────────

def iter_edf(base_dir: Path, dataset_id: str):
    """Yield (edf_path_str, dataset_id) for every .edf found recursively."""
    for p in sorted(base_dir.rglob("*.edf")):
        yield str(p), dataset_id


def process_file(edf_path: str, dataset_id: str, data_root: str) -> list[dict]:
    """
    Read one EDF file -> segment -> extract features.
    Returns list of row dicts, or empty list on error.
    """
    rows = []
    print(f"  [{dataset_id}] {Path(edf_path).name} ...", end=" ", flush=True)
    try:
        record = read_eeg_file(edf_path, dataset_id, data_root)

        for w in record.get("warnings", []):
            print(f"\n    [WARN] {w}", end="")

        ds = segment_recording(
            record,
            window_length_s=WINDOW_SEC,
            window_step_s=STEP_SEC,
        )

        if not ds.windows:
            print("-> 0 windows (no seizure annotations or too short), skipped.")
            return []

        X, y, feat_names, p_ids, r_ids = extract_features_classical(ds)

        n_sz  = int(np.sum(y == 1))
        n_non = int(np.sum(y == 0))
        print(f"-> {len(ds.windows)} windows  (seiz={n_sz}, non-seiz={n_non})")

        for i, (feat_vec, label) in enumerate(zip(X, y)):
            row = dict(zip(feat_names, feat_vec.tolist()))
            row["label"]        = int(label)
            row["patient_id"]   = p_ids[i]
            row["recording_id"] = r_ids[i]
            row["dataset"]      = dataset_id
            rows.append(row)

    except EEGIngestionError as e:
        print(f"-> INGESTION ERROR: {e}")
    except Exception as e:
        print(f"-> ERROR: {type(e).__name__}: {e}")

    return rows


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-files", type=int, default=None,
                        help="Stop after processing this many EDF files (for quick tests)")
    args = parser.parse_args()

    print("=" * 70)
    print("NeuroGuard AI — Feature Matrix Builder")
    print("=" * 70)

    all_rows: list[dict] = []
    files_processed = 0

    # ── CHB-MIT ──────────────────────────────────────────────────────────────
    if CHBMIT_DIR.exists():
        edf_list = list(iter_edf(CHBMIT_DIR, "chbmit"))
        print(f"\n[CHB-MIT] {len(edf_list)} EDF file(s) found in {CHBMIT_DIR}")
        for edf_path, did in edf_list:
            if args.max_files and files_processed >= args.max_files:
                print(f"  [--max-files {args.max_files} reached, stopping]")
                break
            rows = process_file(edf_path, did, str(CHBMIT_DIR))
            all_rows.extend(rows)
            files_processed += 1
    else:
        print(f"\n[CHB-MIT] Directory not found: {CHBMIT_DIR}")

    # ── Siena ─────────────────────────────────────────────────────────────────
    if SIENA_DIR.exists():
        edf_list_s = list(iter_edf(SIENA_DIR, "siena"))
        if edf_list_s:
            print(f"\n[Siena] {len(edf_list_s)} EDF file(s) found in {SIENA_DIR}")
            for edf_path, did in edf_list_s:
                if args.max_files and files_processed >= args.max_files:
                    break
                rows = process_file(edf_path, did, str(SIENA_DIR))
                all_rows.extend(rows)
                files_processed += 1

    # ── Guard ─────────────────────────────────────────────────────────────────
    if not all_rows:
        print("\n[FATAL] No feature rows could be extracted.")
        print("  Ensure EDF files exist under data/chbmit/ and the")
        print("  download is complete (check task-31 log).")
        sys.exit(1)

    # ── Build DataFrame ───────────────────────────────────────────────────────
    df = pd.DataFrame(all_rows)
    meta_cols = ["label", "patient_id", "recording_id", "dataset"]
    feat_cols = [c for c in df.columns if c not in meta_cols]
    df = df[feat_cols + meta_cols]

    df.replace([float("inf"), float("-inf")], np.nan, inplace=True)
    df.fillna(df.median(numeric_only=True), inplace=True)

    n_total = len(df)
    n_seiz  = int(df["label"].sum())
    n_non   = n_total - n_seiz

    print(f"\n{'='*70}")
    print(f"DATASET SUMMARY")
    print(f"{'='*70}")
    print(f"  Total windows : {n_total}")
    print(f"  Seizure (1)   : {n_seiz}  ({n_seiz/n_total*100:.1f}%)")
    print(f"  Normal  (0)   : {n_non}   ({n_non/n_total*100:.1f}%)")
    print(f"  Features      : {len(feat_cols)}")
    print(f"  Patients      : {df['patient_id'].nunique()}")
    print(f"  Recordings    : {df['recording_id'].nunique()}")
    print(f"  Datasets      : {df['dataset'].unique().tolist()}")

    # ── Training CSV (no metadata) ────────────────────────────────────────────
    train_df  = df[feat_cols + ["label"]]
    out_train = OUT_DIR / "features_chbmit.csv"
    train_df.to_csv(out_train, index=False)

    # ── Full CSV (with metadata, useful for LOSO CV) ──────────────────────────
    out_full = OUT_DIR / "features_full.csv"
    df.to_csv(out_full, index=False)

    # ── Feature schema ────────────────────────────────────────────────────────
    schema = {
        "version": "v1.0",
        "features": feat_cols,
        "n_features": len(feat_cols),
        "label_column": "label",
        "label_values": {"0": "non-seizure", "1": "seizure"},
        "window_sec": WINDOW_SEC,
        "step_sec": STEP_SEC,
        "sources": df["dataset"].unique().tolist(),
        "n_patients": int(df["patient_id"].nunique()),
        "n_windows": n_total,
        "seizure_windows": n_seiz,
        "non_seizure_windows": n_non,
    }
    schema_path = OUT_DIR / "feature_schema.json"
    with open(schema_path, "w") as f:
        json.dump(schema, f, indent=2)

    print(f"\n  Training CSV : {out_train}")
    print(f"  Full CSV     : {out_full}")
    print(f"  Schema       : {schema_path}")

    print(f"\n{'='*70}")
    print("NEXT STEP — run training pipeline:")
    print(f"  python ml_models/train_pipeline_v2.py \\")
    print(f"      --data {out_train} \\")
    print(f"      --model_dir ml_models \\")
    print(f"      --target_column label")
    print(f"{'='*70}")


if __name__ == "__main__":
    main()
