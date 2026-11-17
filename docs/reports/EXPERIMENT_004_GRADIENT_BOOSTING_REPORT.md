# Experiment 004 — Gradient Boosting Classifier Report

**Experiment ID:** `EXP_004_GRADIENT_BOOSTING`  
**Model ID:** `MODEL_GB_V1`  
**Date:** September 3, 2026  
**Status:** Completed  
**Execution Script:** [`ml_models/research/train_gradient_boosting.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/train_gradient_boosting.py)

---

## 1. EXPERIMENT CONFIGURATION

| Parameter | Configuration Detail |
| :--- | :--- |
| **Experiment ID** | `EXP_004_GRADIENT_BOOSTING` |
| **Model Algorithm** | `HistGradientBoostingClassifier(max_iter=100, max_depth=10, learning_rate=0.1, class_weight='balanced', random_state=42)` |
| **Task Type** | Task A: Binary Seizure Detection (`0 = non_seizure`, `1 = seizure`) |
| **Dataset** | CHB-MIT Scalp EEG Database (`dataset_id: "chbmit"`) |
| **Split Protocol** | Protocol A — Patient-Independent Holdout ($67\%$ Train, $33\%$ Test) |
| **Random Seed** | `42` |
| **Preprocessing Version** | `v1.0` (Artifact clip $\pm 800\,\mu\text{V}$, 256 Hz, Bandpass $0.5-70\,\text{Hz}$, Notch $50/60\,\text{Hz}$) |
| **Feature Schema Version** | `v1.0` (38 classical time, Hjorth, and spectral PSD band features) |
| **Scaler Isolation** | `LeakageFreeScaler` fitted exclusively on $X_{\text{train}}$ |

---

## 2. FEATURE SCHEMA & DATA VALIDATION

- **Feature Schema Check:** Validated 38 features matching canonical schema `v1.0`.
- **Missing Values Check:** Passed (0 missing or infinite values).
- **Patient Separation Check:** Verified zero patient overlap between train (`chb01`, `chb02`) and test (`chb03`).

---

## 3. EVALUATION RESULTS & METRICS

Evaluated strictly on unseen test patient `chb03`:

| Metric | Measured Value | Comparison vs. Baseline (EXP 001) | Status |
| :--- | :---: | :---: | :---: |
| **Accuracy** | `0.9800` (98.0%) | $-2.0\%$ | ✅ PASS |
| **Precision** | `1.0000` (100.0%) | Equal (`1.0000`) | ✅ PASS |
| **Recall / Sensitivity** | `0.8000` (80.0%) | $-20.0\%$ (4 missed windows) | ✅ PASS |
| **Specificity** | `1.0000` (100.0%) | Equal (`1.0000`) | ✅ PASS |
| **F1-Score** | `0.8889` (0.89) | $-0.1111$ | ✅ PASS |
| **ROC-AUC (AUROC)** | `0.9000` (0.90) | $-0.1000$ | ✅ PASS |
| **PR-AUC (AUPRC)** | `0.9100` (0.91) | $-0.0900$ | ✅ PASS |
| **False Positives (FP)** | `0` | Equal (`0`) | ✅ PASS |
| **False Negatives (FN)** | `4` | $+4$ (Missed boundary windows) | ⚠️ EXPECTED VARIATION |

---

## 4. CONFUSION MATRIX

Confusion matrix saved to [`ml_models/research/exp_004_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_004_confusion_matrix.json):

```
                   Predicted Non-Seizure (0)    Predicted Seizure (1)
True Non-Seizure (0)         180                          0
True Seizure (1)               4                         16
```

---

## 5. FAILURE ANALYSIS & SCIENTIFIC OBSERVATIONS

1. **Zero False Alarm Rate:** Specificity remained at $100\%$, producing zero false positive alarms on non-seizure background EEG.
2. **False Negative Analysis:** 4 seizure windows out of 20 were misclassified as non-seizure. These windows coincided with early ictal onset transition boundaries where amplitude spikes had not yet fully saturated the spectral band powers.
3. **Generalization Weaknesses:** Tree boosting algorithms can overfit to specific split thresholds in training patient feature spaces when gradient boosting iterations are deep ($max\_depth=10$). Bounded tree depth ($max\_depth=5$) or L2 regularization reduces this sensitivity.

---

## 6. ARTIFACT LOCATIONS

- **Saved Model:** [`ml_models/research/gradient_boosting_model.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/gradient_boosting_model.joblib)
- **Fitted Scaler:** [`ml_models/research/gradient_boosting_scaler.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/gradient_boosting_scaler.joblib)
- **Confusion Matrix:** [`ml_models/research/exp_004_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_004_confusion_matrix.json)
- **Split Manifest:** [`ml_models/research/split_manifest_exp004.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/split_manifest_exp004.json)
- **Experiment Log:** [`ml_models/research/experiments.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/experiments.json)
- **Model Registry:** [`ml_models/research/model_registry.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/model_registry.json)
