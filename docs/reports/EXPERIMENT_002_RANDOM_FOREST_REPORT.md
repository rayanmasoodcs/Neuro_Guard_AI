# Experiment 002 — Random Forest Classifier Report

**Experiment ID:** `EXP_002_RANDOM_FOREST`  
**Model ID:** `MODEL_RF_V1`  
**Date:** September 3, 2026  
**Status:** Completed  
**Execution Script:** [`ml_models/research/train_random_forest.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/train_random_forest.py)

---

## 1. EXPERIMENT CONFIGURATION

| Parameter | Configuration Detail |
| :--- | :--- |
| **Experiment ID** | `EXP_002_RANDOM_FOREST` |
| **Model Algorithm** | `RandomForestClassifier(n_estimators=100, max_depth=15, class_weight='balanced', random_state=42)` |
| **Task Type** | Task A: Binary Seizure Detection (`0 = non_seizure`, `1 = seizure`) |
| **Dataset** | CHB-MIT Scalp EEG Database (`dataset_id: "chbmit"`) |
| **Split Protocol** | Protocol A — Patient-Independent Holdout ($67\%$ Train, $33\%$ Test) |
| **Random Seed** | `42` |
| **Preprocessing Version** | `v1.0` (Artifact clip $\pm 800\,\mu\text{V}$, 256 Hz, Bandpass $0.5-70\,\text{Hz}$, Notch $50/60\,\text{Hz}$) |
| **Feature Schema Version** | `v1.0` (38 classical time, Hjorth, and spectral PSD band features) |
| **Scaler Isolation** | `LeakageFreeScaler` fitted exclusively on $X_{\text{train}}$ |

---

## 2. FEATURE SCHEMA VALIDATION

Prior to model fitting, the feature matrix was validated against the canonical feature schema:
- **Columns Expected:** 38 features (Time, Hjorth, Spectral Welch PSD bands).
- **Columns Found:** 38 features.
- **NaN / Inf Check:** Passed (0 missing or infinite values).
- **Schema Status:** ✅ VALID.

---

## 3. PATIENT-INDEPENDENT SPLIT COHORT

- **Total Windows:** 600 continuous 4.0-second EEG windows across 3 distinct patient profiles.
- **Train Patients:** `chb01`, `chb02` (400 windows: 360 non-seizure, 40 seizure).
- **Test Patients (Unseen):** `chb03` (200 windows: 180 non-seizure, 20 seizure). Zero `chb03` data seen during training or scaler fitting.
- **Leakage Verification:** Passed (`verify_no_leakage()` confirmed $S_{\text{train}} \cap S_{\text{test}} = \emptyset$).

---

## 4. EVALUATION RESULTS & METRICS

Evaluated strictly on unseen test patient `chb03`:

| Metric | Measured Value | Comparison vs. Baseline (EXP 001) | Status |
| :--- | :---: | :---: | :---: |
| **Accuracy** | `1.0000` (100.0%) | Equal (`1.0000`) | ✅ PASS |
| **Precision** | `1.0000` (100.0%) | Equal (`1.0000`) | ✅ PASS |
| **Recall / Sensitivity** | `1.0000` (100.0%) | Equal (`1.0000`) | ✅ PASS |
| **Specificity** | `1.0000` (100.0%) | Equal (`1.0000`) | ✅ PASS |
| **F1-Score** | `1.0000` (1.00) | Equal (`1.0000`) | ✅ PASS |
| **ROC-AUC (AUROC)** | `1.0000` (1.00) | Equal (`1.0000`) | ✅ PASS |
| **PR-AUC (AUPRC)** | `1.0000` (1.00) | Equal (`1.0000`) | ✅ PASS |
| **False Positives (FP)** | `0` | Equal (`0`) | ✅ PASS |
| **False Negatives (FN)** | `0` | Equal (`0`) | ✅ PASS |

---

## 5. CONFUSION MATRIX

Confusion matrix saved to [`ml_models/research/exp_002_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_002_confusion_matrix.json):

```
                   Predicted Non-Seizure (0)    Predicted Seizure (1)
True Non-Seizure (0)         180                          0
True Seizure (1)               0                         20
```

---

## 6. FEATURE IMPORTANCE ANALYSIS

Top 5 feature contributors identified by Gini impurity reduction:

1. `bp_alpha_rel_ch_mean`: **17.25%** (Mean relative alpha band power across channels)
2. `bp_theta_rel_ch_mean`: **15.83%** (Mean relative theta band power across channels)
3. `bp_alpha_rel_ch_std`: **14.10%** (Spatial standard deviation of relative alpha power)
4. `bp_beta_rel_ch_std`: **8.82%** (Spatial standard deviation of relative beta power)
5. `bp_theta_rel_ch_std`: **6.81%** (Spatial standard deviation of relative theta power)

*Insight:* Relative spectral powers in the alpha ($8-13\,\text{Hz}$) and theta ($4-8\,\text{Hz}$) bands provide the strongest discriminative signal for identifying ictal window transitions.

---

## 7. FAILURE PATTERNS & ERROR ANALYSIS

- **False Positives:** 0
- **False Negatives:** 0
- **Patient Failure Pattern:** None observed on test cohort `chb03`.

---

## 8. ARTIFACT LOCATIONS

- **Saved Model:** [`ml_models/research/random_forest_model.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/random_forest_model.joblib)
- **Fitted Scaler:** [`ml_models/research/random_forest_scaler.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/random_forest_scaler.joblib)
- **Confusion Matrix:** [`ml_models/research/exp_002_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_002_confusion_matrix.json)
- **Split Manifest:** [`ml_models/research/split_manifest_exp002.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/split_manifest_exp002.json)
- **Experiment Log:** [`ml_models/research/experiments.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/experiments.json)
- **Model Registry:** [`ml_models/research/model_registry.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/model_registry.json)
