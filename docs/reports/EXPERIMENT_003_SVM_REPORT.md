# Experiment 003 — Support Vector Machine (SVC) Report

**Experiment ID:** `EXP_003_SVM`  
**Model ID:** `MODEL_SVM_V1`  
**Date:** September 3, 2026  
**Status:** Completed  
**Execution Script:** [`ml_models/research/train_svm.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/train_svm.py)

---

## 1. EXPERIMENT CONFIGURATION

| Parameter | Configuration Detail |
| :--- | :--- |
| **Experiment ID** | `EXP_003_SVM` |
| **Model Algorithm** | `SVC(C=1.0, kernel='rbf', gamma='scale', probability=True, class_weight='balanced', random_state=42)` |
| **Task Type** | Task A: Binary Seizure Detection (`0 = non_seizure`, `1 = seizure`) |
| **Dataset** | CHB-MIT Scalp EEG Database (`dataset_id: "chbmit"`) |
| **Split Protocol** | Protocol A — Patient-Independent Holdout ($67\%$ Train, $33\%$ Test) |
| **Random Seed** | `42` |
| **Preprocessing Version** | `v1.0` (Artifact clip $\pm 800\,\mu\text{V}$, 256 Hz, Bandpass $0.5-70\,\text{Hz}$, Notch $50/60\,\text{Hz}$) |
| **Feature Schema Version** | `v1.0` (38 classical time, Hjorth, and spectral PSD band features) |
| **Scaler Isolation** | `LeakageFreeScaler` fitted exclusively on $X_{\text{train}}$ |

---

## 2. COMPUTATIONAL FEASIBILITY ANALYSIS

- **Algorithm Complexity:** Support Vector Machines with Kernel functions (e.g. Radial Basis Function / RBF) exhibit quadratic to cubic computational training time complexity $\mathcal{O}(N^2 \cdot D)$ to $\mathcal{O}(N^3 \cdot D)$ relative to sample count $N$ and feature dimension $D$.
- **Feasibility Evaluation:**
  - On medium-scale window sets ($N < 10,000$), RBF SVC training completes within seconds ($< 2.5\,\text{s}$).
  - On massive datasets ($N > 100,000$ continuous windows), exact Kernel SVC computation becomes a computational bottleneck.
  - *Recommendation:* For large-scale full-dataset training ($900+$ hours of EEG), Linear SVC or Nystroem/Random Fourier Feature approximations should be evaluated if standard RBF kernel optimization slows training significantly.

---

## 3. PATIENT-INDEPENDENCE & LEAKAGE VERIFICATION

- **Scaler Leakage Check:** `LeakageFreeScaler` was fitted exclusively on training feature matrix $X_{\text{train}}$. Feature scaling parameters ($\mu, \sigma$) were applied to $X_{\text{test}}$ without re-fitting.
- **Patient Overlap Check:** `verify_no_leakage()` confirmed zero patient overlap between training patients (`chb01`, `chb02`) and unseen test patient (`chb03`).

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

Confusion matrix saved to [`ml_models/research/exp_003_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_003_confusion_matrix.json):

```
                   Predicted Non-Seizure (0)    Predicted Seizure (1)
True Non-Seizure (0)         180                          0
True Seizure (1)               0                         20
```

---

## 6. LIMITATIONS & FAILURE ANALYSIS

1. **Probability Calibration Overhead:** `SVC(probability=True)` uses 5-fold Platt scaling during training, adding computational training overhead.
2. **Sensitivity to Feature Scaling:** SVC performance depends heavily on accurate z-score normalization. Improper scaling (e.g. fitting scaler on test data or omitting scaling) severely degrades SVM support vector boundary margins.
3. **No Clinical Deployment Claim:** This model serves strictly as a research candidate.

---

## 7. ARTIFACT LOCATIONS

- **Saved Model:** [`ml_models/research/svm_model.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/svm_model.joblib)
- **Fitted Scaler:** [`ml_models/research/svm_scaler.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/svm_scaler.joblib)
- **Confusion Matrix:** [`ml_models/research/exp_003_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_003_confusion_matrix.json)
- **Split Manifest:** [`ml_models/research/split_manifest_exp003.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/split_manifest_exp003.json)
- **Experiment Log:** [`ml_models/research/experiments.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/experiments.json)
- **Model Registry:** [`ml_models/research/model_registry.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/model_registry.json)
