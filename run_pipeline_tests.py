"""
NeuroGuard AI — Mission 23: EEG Pipeline Verification Test Suite
================================================================
Tests all pipeline components against the verified CHB-MIT sample file
(data/chbmit/chb01_03.edf) and edge-case scenarios.
No model training occurs.
"""

import sys
import os
import numpy as np

# Ensure project root is on path
sys.path.insert(0, os.path.abspath("."))

from ml_models.research.eeg_io import (
    CHBMITReader, EEGIngestionError, _parse_chbmit_summary
)
from ml_models.research.preprocessing import preprocess_recording
from ml_models.research.segmentation import segment_recording, WINDOW_LENGTH_S, WINDOW_STEP_S
from ml_models.research.feature_extraction import (
    extract_features_classical, build_raw_windows
)

CHBMIT_ROOT = "data/chbmit"
SAMPLE_EDF  = os.path.join(CHBMIT_ROOT, "chb01_03.edf")

results = []

def record(name, passed, detail=""):
    mark = "[PASS]" if passed else "[FAIL]"
    print(f"  {mark} {name} {detail}")
    results.append((name, passed, detail))

print("=" * 65)
print("NEUROGUARD AI — MISSION 23 EEG PIPELINE TEST SUITE")
print("=" * 65)

# ---------------------------------------------------------------
# TEST 1: Valid Recording — End-to-End Read
# ---------------------------------------------------------------
print("\n--- TEST 1: Valid Recording Ingestion (CHB-MIT chb01_03.edf) ---")
cer = None
try:
    reader = CHBMITReader(CHBMIT_ROOT)
    cer = reader.read(SAMPLE_EDF)
    record("CER dataset_id == 'chbmit'",   cer["dataset_id"] == "chbmit")
    record("CER patient_id == 'chb01'",    cer["patient_id"] == "chb01")
    record("CER recording_id correct",     cer["recording_id"] == "chb01_03")
    record("CER sfreq == 256.0 Hz",        abs(cer["sfreq"] - 256.0) < 1.0, f"sfreq={cer['sfreq']}")
    record("CER n_channels >= 20",         cer["n_channels"] >= 20, f"n_channels={cer['n_channels']}")
    record("CER signals shape correct",    cer["signals"].ndim == 2 and cer["signals"].shape[0] >= 20)
    record("CER duration_s >= 3500s",      cer["duration_s"] >= 3500.0, f"duration={cer['duration_s']:.1f}s")
    record("CER has exactly 1 seizure",    len(cer["seizures"]) == 1, f"seizures={cer['seizures']}")
    sz = cer["seizures"][0]
    record("CER seizure onset ~2996s",     abs(sz["onset_s"] - 2996) < 5, f"onset={sz['onset_s']}s")
    record("CER seizure offset ~3036s",    abs(sz["offset_s"] - 3036) < 5, f"offset={sz['offset_s']}s")
    record("CER label_type == 'binary'",   cer["label_type"] == "binary")
    record("CER signals dtype float32",    cer["signals"].dtype == np.float32)
    record("CER no NaN in signals",        not np.any(np.isnan(cer["signals"])))
    print(f"   INFO  ch_names sample: {cer['ch_names'][:5]}")
    if cer["warnings"]:
        print(f"   WARN  {cer['warnings']}")
except Exception as e:
    record("Valid recording ingestion", False, str(e))

# ---------------------------------------------------------------
# TEST 2: Missing Metadata — Missing Summary File
# ---------------------------------------------------------------
print("\n--- TEST 2: Missing Annotation File (graceful handling) ---")
try:
    import tempfile, shutil
    tmp_dir = tempfile.mkdtemp()
    tmp_edf = os.path.join(tmp_dir, "chb99_01.edf")
    shutil.copy(SAMPLE_EDF, tmp_edf)
    reader99 = CHBMITReader(tmp_dir)
    cer99 = reader99.read(tmp_edf)
    has_warn = any("Summary file" in w or "not found" in w for w in cer99["warnings"])
    record("Missing summary triggers warning (not crash)", has_warn,
           f"warnings={cer99['warnings']}")
    record("Seizure list defaults to empty", cer99["seizures"] == [])
    shutil.rmtree(tmp_dir)
except Exception as e:
    record("Missing annotation file handling", False, str(e))

# ---------------------------------------------------------------
# TEST 3: Corrupt File — File Too Small
# ---------------------------------------------------------------
print("\n--- TEST 3: Corrupt/Empty File Detection ---")
try:
    import tempfile
    with tempfile.NamedTemporaryFile(delete=False, suffix=".edf") as f:
        f.write(b"\x00" * 100)   # only 100 bytes — invalid EDF
        bad_path = f.name
    reader_bad = CHBMITReader(CHBMIT_ROOT)
    try:
        reader_bad.read(bad_path)
        record("Corrupt file raises EEGIngestionError", False, "No exception raised")
    except EEGIngestionError as e:
        record("Corrupt file raises EEGIngestionError", True, str(e)[:60])
    except Exception as e:
        record("Corrupt file raises EEGIngestionError", False, f"Wrong exception: {e}")
    os.unlink(bad_path)
except Exception as e:
    record("Corrupt file detection", False, str(e))

# ---------------------------------------------------------------
# TEST 4: Unsupported Format
# ---------------------------------------------------------------
print("\n--- TEST 4: Unsupported Format Detection ---")
try:
    from ml_models.research.eeg_io import read_eeg_file
    try:
        read_eeg_file("/fake/path.edf", dataset_id="unknown_dataset", data_root=".")
        record("Unknown dataset_id raises EEGIngestionError", False, "No exception raised")
    except EEGIngestionError as e:
        record("Unknown dataset_id raises EEGIngestionError", True, str(e)[:60])
except Exception as e:
    record("Unknown dataset_id detection", False, str(e))

# ---------------------------------------------------------------
# TEST 5: Preprocessing
# ---------------------------------------------------------------
print("\n--- TEST 5: Preprocessing Pipeline ---")
try:
    pp_cer = preprocess_recording(cer, target_sfreq=256.0, normalize=False)
    record("Preprocessing returns dict",       isinstance(pp_cer, dict))
    record("sfreq unchanged (256 to 256)",     abs(pp_cer["sfreq"] - 256.0) < 1.0)
    record("signals shape preserved",          pp_cer["signals"].shape == cer["signals"].shape)
    record("preprocessing block present",      "preprocessing" in pp_cer)
    record("pipeline_version recorded",        pp_cer["preprocessing"]["pipeline_version"] == "v1.0")
    ops = pp_cer["preprocessing"]["operations_applied"]
    record("bandpass op logged",               any("bandpass" in op for op in ops))
    record("notch op logged",                  any("notch" in op for op in ops))
    record("no resampling op (256 to 256)",    not any("resample" in op for op in ops))
    record("No NaN after preprocessing",       not np.any(np.isnan(pp_cer["signals"])))
    print(f"   INFO  ops={ops}")
except Exception as e:
    record("Preprocessing pipeline", False, str(e))

# ---------------------------------------------------------------
# TEST 6: Segmentation
# ---------------------------------------------------------------
print("\n--- TEST 6: Segmentation & Label Assignment ---")
try:
    seg_ds = segment_recording(pp_cer)
    n_windows    = len(seg_ds)
    n_seizure    = seg_ds.n_seizure
    n_non_seizure= seg_ds.n_non_seizure
    expected_min_windows = int(pp_cer["duration_s"] / WINDOW_STEP_S) - 5
    record("Segmentation produces windows",     n_windows > 0, f"n_windows={n_windows}")
    record("Window count reasonable",           n_windows >= expected_min_windows,
           f"got={n_windows} expected>={expected_min_windows}")
    record("Has seizure-labelled windows",      n_seizure > 0, f"n_seizure={n_seizure}")
    record("Has non-seizure windows",           n_non_seizure > 0, f"n_non_seizure={n_non_seizure}")
    record("Patient ID preserved in windows",   all(w.patient_id == "chb01" for w in seg_ds.windows))
    record("Recording ID preserved",            all(w.recording_id == "chb01_03" for w in seg_ds.windows))
    record("Dataset ID preserved",              all(w.dataset_id == "chbmit" for w in seg_ds.windows))
    # Check window signal shape
    w0 = seg_ds.windows[0]
    expected_samples = int(round(WINDOW_LENGTH_S * 256.0))
    record("Window signal shape correct",
           w0.signals.shape == (pp_cer["n_channels"], expected_samples),
           f"shape={w0.signals.shape} expected=({pp_cer['n_channels']},{expected_samples})")
    record("All window labels 0 or 1",          all(w.label in (0, 1) for w in seg_ds.windows))
    print(f"   INFO  {seg_ds.summary()}")
except Exception as e:
    record("Segmentation", False, str(e))

# ---------------------------------------------------------------
# TEST 7: Feature Extraction — Classical ML
# ---------------------------------------------------------------
print("\n--- TEST 7: Classical ML Feature Extraction ---")
try:
    # Use subset of windows for speed
    from ml_models.research.segmentation import SegmentedDataset
    sub_ds = SegmentedDataset()
    sub_ds.windows = seg_ds.windows[:50]  # first 50 windows
    X, y, feat_names, pat_ids, rec_ids = extract_features_classical(sub_ds)
    record("X shape (n_windows, n_features)",   X.ndim == 2 and X.shape[0] == 50)
    record("Feature count >= 30",               X.shape[1] >= 30, f"n_features={X.shape[1]}")
    record("y length matches n_windows",        len(y) == 50)
    record("patient_ids preserved",             all(pid == "chb01" for pid in pat_ids))
    record("No NaN in feature matrix",          not np.any(np.isnan(X)))
    record("No Inf in feature matrix",          not np.any(np.isinf(X)))
    record("feature_names list non-empty",      len(feat_names) > 0)
    print(f"   INFO  Feature shape: {X.shape} | Sample features: {feat_names[:4]}")
except Exception as e:
    record("Classical ML feature extraction", False, str(e))

# ---------------------------------------------------------------
# TEST 8: Raw Window Array (Deep Learning)
# ---------------------------------------------------------------
print("\n--- TEST 8: Raw Window Array (DL Input) ---")
try:
    sub_ds2 = SegmentedDataset()
    sub_ds2.windows = seg_ds.windows[:50]
    X_raw, y_raw, pat_ids_r, rec_ids_r = build_raw_windows(sub_ds2)
    record("X_raw ndim == 3",                  X_raw.ndim == 3)
    record("X_raw shape[0] == n_windows",       X_raw.shape[0] == 50)
    record("X_raw shape[1] == n_channels",      X_raw.shape[1] == pp_cer["n_channels"],
           f"shape={X_raw.shape}")
    record("X_raw dtype float32",              X_raw.dtype == np.float32)
    record("No NaN in X_raw",                  not np.any(np.isnan(X_raw)))
    print(f"   INFO  X_raw shape: {X_raw.shape}")
except Exception as e:
    record("Raw DL window array", False, str(e))

# ---------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------
print("\n" + "=" * 65)
total  = len(results)
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
    print("\n>>> ALL PIPELINE TESTS PASSED. MISSION 23 COMPLETE. <<<")
