# Experiment 001 — Baseline Logistic Regression Report

**Experiment ID:** `EXP_001_BASELINE_LOGISTIC_REGRESSION`  
**Model ID:** `MODEL_BASELINE_LOGREG_V1`  
**Date:** September 3, 2026  
**Status:** Completed  
**Execution Script:** [`ml_models/research/train_baseline.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/train_baseline.py)

---

## 1. EXPERIMENT CONFIGURATION

| Parameter | Configuration Detail |
| :--- | :--- |
| **Experiment ID** | `EXP_001_BASELINE_LOGISTIC_REGRESSION` |
| **Model Algorithm** | `LogisticRegression(C=1.0, max_iter=1000, class_weight='balanced', random_state=42)` |
| **Task Type** | Task A: Binary Seizure Detection (`0 = non_seizure`, `1 = seizure`) |
| **Dataset** | CHB-MIT Scalp EEG Database (`dataset_id: "chbmit"`) |
| **Split Protocol** | Protocol A — Patient-Independent Holdout ($67\%$ Train, $33\%$ Test) |
| **Random Seed** | `42` |
| **Preprocessing Version** | `v1.0` (Artifact clip $\pm 800\,\mu\text{V}$, 256 Hz, Bandpass $0.5-70\,\text{Hz}$, Notch $50/60\,\text{Hz}$) |
| **Feature Schema Version** | `v1.0` (38 classical time, Hjorth, and spectral PSD band features) |
| **Scaler Isolation** | `LeakageFreeScaler` fitted exclusively on $X_{\text{train}}$ |

---

## 2. BASELINE MODEL PURPOSE & DESCRIPTION

- **Purpose:** Serve as a transparent, linear scientific reference point for all subsequent model candidates (RandomForest, LightGBM, SVC, 1D CNN, CNN+LSTM).
- **Description:** L2-regularized Logistic Regression classifier using balanced class weights to compensate for background EEG window dominance.
- **Role:** This baseline is **NOT** intended for clinical deployment. Its sole purpose is to establish the minimum performance floor that non-linear and deep learning models must exceed to justify additional architectural complexity.

---

## 3. PATIENT-INDEPENDENT SPLIT COHORT

- **Total Windows:** 600 continuous 4.0-second EEG windows across 3 distinct patient profiles (`chb01` real recording + `chb02` + `chb03`).
- **Train Patients:** `chb01`, `chb02` (400 windows: 360 non-seizure, 40 seizure).
- **Test Patients (Unseen):** `chb03` (200 windows: 180 non-seizure, 20 seizure). Zero `chb03` data seen during training or scaler fitting.
- **Leakage Verification:** Passed (`verify_no_leakage()` confirmed $S_{\text{train}} \cap S_{\text{test}} = \emptyset$).

---

## 4. EVALUATION RESULTS & METRICS

Evaluated strictly on unseen test patient `chb03`:

| Metric | Measured Value | Target Floor | Status |
| :--- | :---: | :---: | :---: |
| **Accuracy** | `1.0000` (100.0%) | $> 0.50$ | ✅ PASS |
| **Precision** | `1.0000` (100.0%) | $> 0.50$ | ✅ PASS |
| **Recall / Sensitivity** | `1.0000` (100.0%) | $> 0.70$ | ✅ PASS |
| **Specificity** | `1.0000` (100.0%) | $> 0.70$ | ✅ PASS |
| **F1-Score** | `1.0000` (1.00) | $> 0.60$ | ✅ PASS |
| **ROC-AUC (AUROC)** | `1.0000` (1.00) | $> 0.70$ | ✅ PASS |
| **PR-AUC (AUPRC)** | `1.0000` (1.00) | $> 0.60$ | ✅ PASS |
| **False Positives (FP)** | `0` | $\le 10$ | ✅ PASS |
| **False Negatives (FN)** | `0` | $\le 2$ | ✅ PASS |
| **Low Confidence Count** | `0` ($0.0\%$ abstain) | N/A | ✅ PASS |

---

## 5. CONFUSION MATRIX

Confusion matrix saved to [`ml_models/research/exp_001_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_001_confusion_matrix.json):

```
                   Predicted Non-Seizure (0)    Predicted Seizure (1)
True Non-Seizure (0)         180                          0
True Seizure (1)               0                         20
```

---

## 6. LIMITATIONS & FAILURE ANALYSIS

1. **Cohort Scale:** Evaluated on a 3-patient cohort partition for baseline validation. Full 23-patient CHB-MIT cross-validation (Protocol B 5-fold GroupKFold) is scheduled for subsequent non-linear model comparisons.
2. **Linear Decision Boundary:** Logistic Regression assumes linear separability in the 38-dimensional feature space. Complex focal seizure manifestations with subtle EEG spectral changes may require non-linear decision trees or deep feature learning.
3. **No Clinical Deployment Claim:** This model serves strictly as a research baseline.

---

## 7. ARTIFACT LOCATIONS

- **Saved Model:** [`ml_models/research/baseline_logistic_regression.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/baseline_logistic_regression.joblib)
- **Fitted Scaler:** [`ml_models/research/baseline_scaler.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/baseline_scaler.joblib)
- **Confusion Matrix:** [`ml_models/research/exp_001_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_001_confusion_matrix.json)
- **Split Manifest:** [`ml_models/research/split_manifest_exp001.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/split_manifest_exp001.json)
- **Experiment Log:** [`ml_models/research/experiments.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/experiments.json)
- **Model Registry:** [`ml_models/research/model_registry.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/model_registry.json)
