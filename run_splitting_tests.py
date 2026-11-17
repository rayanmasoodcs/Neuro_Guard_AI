"""
NeuroGuard AI — Mission 24: Patient-Independent Splitting & Leakage Verification Suite
=======================================================================================
Tests all patient-independent protocols, automated leakage detectors, scaler isolation,
and manifest export functionality.
No model training occurs.
"""

import sys
import os
import numpy as np

sys.path.insert(0, os.path.abspath("."))

from ml_models.research.eeg_io import CHBMITReader
from ml_models.research.preprocessing import preprocess_recording
from ml_models.research.segmentation import segment_recording, SegmentedDataset, EEGWindow
from ml_models.research.feature_extraction import extract_features_classical
from ml_models.research.splitting import (
    DataLeakageError,
    get_patient_inventory,
    verify_no_leakage,
    split_patient_independent_holdout,
    get_group_kfold_splits,
    get_loso_splits,
    LeakageFreeScaler,
    export_split_manifest,
)

results = []

def record(name, passed, detail=""):
    mark = "[PASS]" if passed else "[FAIL]"
    print(f"  {mark} {name} {detail}")
    results.append((name, passed, detail))

print("=" * 65)
print("NEUROGUARD AI — MISSION 24 PATIENT-INDEPENDENT SPLITTING TEST SUITE")
print("=" * 65)

# --- Construct Synthetic Multi-Patient SegmentedDataset for Multi-Patient Testing ---
print("\n--- CREATING SYNTHETIC MULTI-PATIENT DATASET (5 Patients) ---")
ds = SegmentedDataset()
patients = ["chb01", "chb02", "chb03", "chb04", "chb05"]
for idx, pid in enumerate(patients):
    for w_i in range(40):
        # Even patients have some seizure windows
        is_sz = (w_i >= 30) if idx % 2 == 0 else False
        lbl = 1 if is_sz else 0
        w = EEGWindow(
            signals=np.random.randn(23, 1024).astype(np.float32),
            dataset_id="chbmit",
            patient_id=pid,
            recording_id=f"{pid}_0{w_i // 20 + 1}",
            window_index=w_i,
            onset_s=w_i * 2.0,
            offset_s=w_i * 2.0 + 4.0,
            label=lbl,
            label_str="seizure" if lbl == 1 else "non_seizure",
            seizure_overlap_frac=1.0 if lbl == 1 else 0.0,
            sfreq=256.0,
            ch_names=[f"CH{k}" for k in range(23)],
            preprocessing_version="v1.0"
        )
        ds.append(w)

print(f"   INFO  Synthetic dataset created: {len(ds)} total windows across {len(patients)} patients.")

# ---------------------------------------------------------------
# TEST 1: Patient Inventory Mapping
# ---------------------------------------------------------------
print("\n--- TEST 1: Patient Inventory Mapping ---")
try:
    inv = get_patient_inventory(ds)
    record("Inventory contains all 5 patients", len(inv) == 5, f"patients={list(inv.keys())}")
    record("Patient chb01 has 40 windows", inv["chb01"].total_windows == 40)
    record("Patient chb01 has 10 seizure windows", inv["chb01"].seizure_windows == 10)
    record("Patient chb02 has 0 seizure windows", inv["chb02"].seizure_windows == 0)
    record("Patient chb01 recordings list correct", len(inv["chb01"].recordings) == 2)
except Exception as e:
    record("Patient inventory mapping", False, str(e))

# ---------------------------------------------------------------
# TEST 2: Automated Leakage Verification — Trap Positive Overlap
# ---------------------------------------------------------------
print("\n--- TEST 2: Automated Leakage Detector (Trap Overlap) ---")
try:
    # Clean check should pass
    clean_res = verify_no_leakage({"chb01", "chb02"}, {"chb03"}, {"chb04", "chb05"})
    record("Clean patient sets pass verification", clean_res["train_val_patient_overlap"] is False)

    # Contaminated check must raise DataLeakageError
    leakage_caught = False
    try:
        verify_no_leakage({"chb01", "chb02"}, {"chb02", "chb03"}, {"chb04"})
    except DataLeakageError as e:
        leakage_caught = True
        record("Detector catches train/val patient overlap", True, str(e)[:60])
    if not leakage_caught:
        record("Detector catches train/val patient overlap", False, "No error raised!")

    # Recording level contamination check
    rec_leakage_caught = False
    try:
        verify_no_leakage({"chb01"}, {"chb02"}, {"chb03"},
                          train_recordings={"chb01_01"}, val_recordings={"chb01_01"})
    except DataLeakageError as e:
        rec_leakage_caught = True
        record("Detector catches recording overlap", True, str(e)[:60])
    if not rec_leakage_caught:
        record("Detector catches recording overlap", False, "No error raised!")

except Exception as e:
    record("Automated leakage verification", False, str(e))

# ---------------------------------------------------------------
# TEST 3: Protocol A — Patient-Independent Holdout Split
# ---------------------------------------------------------------
print("\n--- TEST 3: Protocol A — Patient-Independent Holdout Split ---")
try:
    split_res = split_patient_independent_holdout(ds, val_ratio=0.2, test_ratio=0.2, seed=42)
    tr_pats = set(split_res["train_patients"])
    val_pats = set(split_res["val_patients"])
    ts_pats = set(split_res["test_patients"])

    record("Train patients non-empty", len(tr_pats) > 0, f"train={tr_pats}")
    record("Val patients non-empty", len(val_pats) > 0, f"val={val_pats}")
    record("Test patients non-empty", len(ts_pats) > 0, f"test={ts_pats}")
    record("Total unique patients preserved", len(tr_pats | val_pats | ts_pats) == 5)
    record("Zero patient overlap in Holdout split", len(tr_pats & val_pats) == 0 and len(tr_pats & ts_pats) == 0 and len(val_pats & ts_pats) == 0)
    record("Manifest protocol label present", "Protocol A" in split_res["manifest"]["protocol"])
except Exception as e:
    record("Protocol A holdout split", False, str(e))

# ---------------------------------------------------------------
# TEST 4: Protocol B — Patient-Grouped K-Fold Cross-Validation
# ---------------------------------------------------------------
print("\n--- TEST 4: Protocol B — GroupKFold Cross-Validation ---")
try:
    folds = get_group_kfold_splits(ds, n_splits=5, seed=42)
    record("Generated exactly 5 folds", len(folds) == 5)
    all_fold_clean = True
    for f in folds:
        tr_p = set(f["train_patients"])
        v_p = set(f["val_patients"])
        if len(tr_p & v_p) > 0:
            all_fold_clean = False
    record("Zero patient overlap across all 5 GroupKFold folds", all_fold_clean)
    print(f"   INFO  Fold 1 Val Patients: {folds[0]['val_patients']} | Train Patients: {folds[0]['train_patients']}")
except Exception as e:
    record("Protocol B GroupKFold split", False, str(e))

# ---------------------------------------------------------------
# TEST 5: Protocol C — Leave-One-Subject-Out (LOSO)
# ---------------------------------------------------------------
print("\n--- TEST 5: Protocol C — Leave-One-Subject-Out (LOSO) ---")
try:
    loso_folds = get_loso_splits(ds)
    record("LOSO fold count equals patient count (5)", len(loso_folds) == 5)
    loso_clean = True
    for f in loso_folds:
        test_p = f["test_patient"]
        tr_p = set(f["train_patients"])
        if test_p in tr_p:
            loso_clean = False
    record("Zero patient overlap across all LOSO folds", loso_clean)
    print(f"   INFO  LOSO Fold 1 Test Subject: {loso_folds[0]['test_patient']}")
except Exception as e:
    record("Protocol C LOSO split", False, str(e))

# ---------------------------------------------------------------
# TEST 6: Preprocessing Isolation (LeakageFreeScaler)
# ---------------------------------------------------------------
print("\n--- TEST 6: Preprocessing Isolation (LeakageFreeScaler) ---")
try:
    scaler = LeakageFreeScaler()
    X_fake_tr = np.array([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]], dtype=np.float32)
    X_fake_val = np.array([[2.0, 3.0]], dtype=np.float32)

    # Calling transform before fit must fail
    unfitted_caught = False
    try:
        scaler.transform(X_fake_val)
    except RuntimeError:
        unfitted_caught = True
        record("Unfitted scaler transform raises RuntimeError", True)
    if not unfitted_caught:
        record("Unfitted scaler transform raises RuntimeError", False, "No error raised")

    X_tr_scaled = scaler.fit_transform(X_fake_tr)
    record("Scaler fits on X_train", scaler.is_fitted is True)
    record("Scaled X_train mean ~ 0", np.allclose(np.mean(X_tr_scaled, axis=0), 0.0, atol=1e-5))

    X_val_scaled = scaler.transform(X_fake_val)
    record("Scaled X_val transformed using train params", X_val_scaled.shape == (1, 2))
except Exception as e:
    record("LeakageFreeScaler isolation", False, str(e))

# ---------------------------------------------------------------
# TEST 7: Export Reproducible Split Manifest JSON
# ---------------------------------------------------------------
print("\n--- TEST 7: Split Manifest Export ---")
try:
    manifest_path = "ml_models/research/split_manifest_test.json"
    export_split_manifest(split_res["manifest"], manifest_path)
    record("Manifest file created on disk", os.path.exists(manifest_path))
    if os.path.exists(manifest_path):
        os.unlink(manifest_path)
except Exception as e:
    record("Split manifest export", False, str(e))

# ---------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------
print("\n" + "=" * 65)
total = len(results)
passed = sum(1 for _, p, _ in results if p)
failed = total - passed
print(f"TOTAL: {total}  PASSED: {passed}  FAILED: {failed}")
print("=" * 65)

if failed > 0:
    print("\nFAILED TESTS:")
    for name, p, detail in results:
        if not p:
            print(f"  FAIL: {name}: {detail}")
    sys.exit(1)
else:
    print("\n>>> ALL SPLITTING & LEAKAGE TESTS PASSED. MISSION 24 COMPLETE. <<<")
