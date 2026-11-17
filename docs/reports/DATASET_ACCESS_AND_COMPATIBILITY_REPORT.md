# NeuroGuard AI — Dataset Access & Compatibility Report

**Mission:** Mission 22 — EEG Dataset Acquisition, Manifest Registration, and Compatibility Analysis  
**Date:** September 3, 2026  
**Status:** Completed — Both datasets verified accessible. Manifest registered. Compatibility analyzed.

---

## 1. DATASET ACCESS VERIFICATION

### CHB-MIT Scalp EEG Database

| Property | Verified Detail |
| :--- | :--- |
| **Access Status** | ✅ OPEN — No account, registration, or credentials required |
| **License** | Open Data Commons Attribution License v1.0 (ODC-By) |
| **Acquisition Method** | Direct HTTPS download from `physionet.org/files/chbmit/1.0.0/` |
| **Authentication Required** | No |
| **Terms Acceptance Required** | ODC-By attribution required in any publication |
| **Programmatic Access** | Yes — `urllib.request` / `wget` / `curl` without authentication |
| **Estimated Full Dataset Size** | ~45 GB (686 EDF files across 23 patients) |
| **Sample Verified** | ✅ `chb01_03.edf` (40.4 MB, 1 hour, 23 channels at 256 Hz) downloaded and parsed successfully |
| **Annotation Verified** | ✅ `chb01-summary.txt` parsed: Seizure window `[2996s–3036s]` confirmed |

### Siena Scalp EEG Dataset

| Property | Verified Detail |
| :--- | :--- |
| **Access Status** | ✅ OPEN — No account, registration, or credentials required |
| **License** | Open Data Commons Attribution License v1.0 (ODC-By) |
| **Acquisition Method** | Direct HTTPS download from `physionet.org/files/siena-scalp-eeg/1.0.0/` |
| **Authentication Required** | No |
| **Terms Acceptance Required** | ODC-By attribution required in any publication |
| **Programmatic Access** | Yes — `urllib.request` / `wget` / `curl` without authentication |
| **Estimated Full Dataset Size** | ~12 GB (41 EDF files across 14 patients) |
| **Sample Verified** | ✅ `RECORDS` file fetched listing all 41 EDF files. `PN00/Seizures-list-PN00.txt` parsed: 29 channels at 512 Hz, clock-time annotations confirmed |

---

## 2. VERIFIED SAMPLE INGESTION RESULTS

```
=== CHB-MIT Sample Verification ===
  File:           data/chbmit/chb01_03.edf
  Size:           42,399,744 bytes (40.4 MB)
  Channels:       23 (Bipolar Montage)
  Sampling Rate:  256 Hz
  Duration:       1 hour (3600 seconds)
  Seizures:       1 (Onset: 2996s, Offset: 3036s = 40 seconds)
  Summary Files:  Metadata for 42 EDF files in chb01 cohort parsed

  Channel Labels: FP1-F7, F7-T7, T7-P7, P7-O1, FP1-F3, F3-C3, C3-P3,
                  P3-O1, FP2-F4, F4-C4, C4-P4, P4-O2, FP2-F8, F8-T8,
                  T8-P8, P8-O2, FZ-CZ, CZ-PZ, P7-T7, T7-FT9,
                  FT9-FT10, FT10-T8, T8-P8

=== Siena Sample Verification ===
  Annotation:     data/siena/PN00-seizures.txt
  Channels:       29 EEG + 2 EKG (Monopolar Montage)
  Sampling Rate:  512 Hz
  Seizures:       2 annotated (clock-time format: HH.MM.SS)
  Patients in RECORDS: PN00–PN17 (14 active patients, 41 EDF files)
```

---

## 3. DATASET MANIFEST

Machine-readable manifest registered at [`ml_models/research/dataset_manifest.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/dataset_manifest.json).

| Field | CHB-MIT | Siena Scalp EEG |
| :--- | :--- | :--- |
| **Patients** | 23 pediatric | 14 adult |
| **EDF Files** | ~686 | 41 |
| **Total Duration** | ~984 hours | ~128 hours |
| **Seizure Events** | 198 | ~47 |
| **Sampling Rate** | 256 Hz | 512 Hz |
| **Channels** | 23 bipolar | 29 monopolar + 2 EKG |
| **Montage** | Bipolar (10-20 pairs) | Monopolar average-referenced |
| **Annotation Format** | Text summary files (seconds offset) | Per-patient text files (clock-time) |
| **Seizure Subtype Labels** | Binary only | Binary only |

---

## 4. COMPATIBILITY MATRIX

| Dimension | CHB-MIT | Siena | Compatibility Verdict |
| :--- | :--- | :--- | :--- |
| **EDF File Format** | EDF | EDF | ✅ Compatible |
| **Sampling Rate** | 256 Hz | 512 Hz | ⚠️ Requires anti-aliased downsampling of Siena to 256 Hz |
| **Channel Count** | 23 | 29 (+ 2 EKG) | ⚠️ Must extract 10-20 common subset only |
| **Montage Type** | Bipolar | Monopolar | ⚠️ Requires re-referencing before comparison |
| **Patient Population** | Pediatric (1.5–22 y) | Adult (20–71 y) | ❌ Significant demographic domain shift |
| **Seizure Labeling** | Binary (seconds offset) | Binary (clock-time) | ⚠️ Clock-time must be converted to seconds relative to EDF start |
| **Seizure Subtypes** | Not systematically annotated | Not systematically annotated | ✅ Both binary-only for Task A |
| **Dataset Size** | ~45 GB / 984h | ~12 GB / 128h | ⚠️ Large size difference; CHB-MIT dominates |

**Overall Compatibility Classification:**

> **COMPATIBLE AFTER DOCUMENTED HARMONIZATION** for Task A (Binary Seizure Detection) only.
>
> Harmonization steps required: (1) Siena resampling to 256 Hz with anti-aliased low-pass filter, (2) common 10-20 electrode subset extraction, (3) Siena clock-time annotation conversion to seconds offset, (4) per-dataset z-score normalization computed independently per training fold.

---

## 5. HARMONIZATION REQUIREMENTS

To safely combine or compare the two datasets (Mode B or Mode C):

1. **Resampling:** Apply a low-pass anti-aliasing filter at 128 Hz to Siena signals, then downsample from 512 Hz to 256 Hz using `scipy.signal.resample_poly(up=1, down=2)`.
2. **Channel Subset:** Extract only the EEG channels that form a common interpretable subset of the 10-20 International System present in both datasets. Exclude EKG channels from Siena.
3. **Re-referencing:** Convert Siena monopolar signals to bipolar pairs matching CHB-MIT's bipolar montage where anatomically valid, OR convert both to a common average reference for feature-level comparison.
4. **Annotation Parsing:** Convert Siena clock-time annotations (e.g. `19.58.36`) to absolute second offsets relative to each recording's EDF start time.
5. **Normalization Isolation:** Fit all normalization parameters (mean, std) on the training partition only. Apply to validation/test partitions. Never fit across the entire pooled dataset.

---

## 6. DATASET USAGE MODES

### MODE A — Within-Dataset Patient-Independent Testing
- **Dataset:** CHB-MIT (primary, 23 patients) or Siena (secondary, 14 patients) independently.
- **Split:** `GroupKFold(n_splits=5, groups=patient_id)` or `LeaveOneGroupOut`.
- **Task:** Task A (Binary Seizure Detection).
- **Status:** Ready to implement once full dataset is downloaded.

### MODE B — Cross-Dataset Generalization
- **Train:** CHB-MIT (pediatric, 23 patients).
- **Test:** Siena (adult, 14 patients) — zero Siena patients seen during training.
- **Task:** Task A (Binary Seizure Detection) only after harmonization.
- **Scientific Note:** Expected performance drop due to pediatric→adult domain shift is scientifically meaningful and must be documented, not hidden.
- **Status:** Feasible after harmonization pipeline is implemented.

### MODE C — Combined Training
- **Status:** NOT RECOMMENDED at this stage. The sampling rate, montage, and demographic differences create uncontrolled confounders. If attempted later, it must be preceded by full harmonization and ablation studies showing combined training genuinely improves patient-independent generalization.

---

## 7. MANUAL ACTION REQUIRED

### ⚠️ Full Dataset Download — Manual or Scripted Action Required

The full CHB-MIT dataset (~45 GB) and Siena dataset (~12 GB) require a user-initiated download. The environment cannot autonomously download ~57 GB of binary data in a single mission.

**Recommended acquisition procedure:**

```bash
# Install wget (or use the provided Python downloader script)

# CHB-MIT — Full Dataset
wget -r -N -c -np --user-agent="NeuroGuardAI-Research/1.0" \
  https://physionet.org/files/chbmit/1.0.0/ \
  -P data/chbmit/

# Siena Scalp EEG — Full Dataset
wget -r -N -c -np --user-agent="NeuroGuardAI-Research/1.0" \
  https://physionet.org/files/siena-scalp-eeg/1.0.0/ \
  -P data/siena/
```

The resumable Python acquisition script is at [`ml_models/research/download_sample_dataset.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/download_sample_dataset.py) and can be extended with full patient/file lists from `dataset_manifest.json`.

---

## 8. FALLBACK STRATEGY

If the complete dataset cannot be downloaded into the local environment before Mission 23:

1. **Pipeline architecture is dataset-location-agnostic.** The ingestion loader will accept a root path configured via `CHBMIT_ROOT` and `SIENA_ROOT` environment variables.
2. **All code is written to operate against the expected directory structure.** Placing authorized EDF files in `data/chbmit/<patientid>/` will immediately enable full pipeline execution.
3. **Unit tests for the ingestion pipeline** use the already-downloaded `chb01_03.edf` sample only — no fabricated data.

---

## 9. CROSS-DATASET RISKS

| Risk | Severity | Mitigation |
| :--- | :---: | :--- |
| Demographic domain shift (Pediatric→Adult) inflates perceived poor cross-dataset performance | Medium | Document explicitly as a scientific finding, not a bug |
| Montage mismatch causing channel feature misalignment | High | Strictly enforce common channel subset extraction before any feature computation |
| Siena clock-time annotation parsing errors causing label offset | High | Validate seizure windows against recording duration bounds |
| Imbalanced class distribution (seizure windows << non-seizure windows) | High | Use AUROC / AUPRC as primary metrics; apply class-weighted loss or SMOTE only within training fold |

---

## 10. GO/NO-GO STATUS

- **CHB-MIT Access:** ✅ Open access confirmed. Sample file verified.
- **Siena Access:** ✅ Open access confirmed. Annotation file verified.
- **Dataset Manifest:** ✅ Created at `ml_models/research/dataset_manifest.json`.
- **Compatibility Analysis:** ✅ Completed. Harmonization requirements documented.
- **Usage Modes:** ✅ Defined (Mode A, B, C).
- **Data Combined:** ❌ NO — Not combined. Compatibility analysis required first.
- **Models Trained:** ❌ NO — Strictly audit-only phase.

**Recommended Next Mission:** Mission 23 — Implement Patient-Independent EEG Windowing & Feature Extraction Pipeline (CHB-MIT Mode A) using the verified `chb01_03.edf` sample file.
