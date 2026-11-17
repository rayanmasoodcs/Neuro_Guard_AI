# Experiment 005 — 1D Convolutional Neural Network (1D CNN) Report

**Experiment ID:** `EXP_005_1D_CNN`  
**Model ID:** `MODEL_1D_CNN_V1`  
**Date:** September 3, 2026  
**Status:** Completed  
**Execution Script:** [`ml_models/research/train_1d_cnn.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/train_1d_cnn.py)

---

## 1. EXPERIMENT CONFIGURATION

| Parameter | Configuration Detail |
| :--- | :--- |
| **Experiment ID** | `EXP_005_1D_CNN` |
| **Model Architecture** | 1D CNN (`Conv1D(23->32)` $\rightarrow$ `Conv1D(32->64)` $\rightarrow$ `FC(64->32->2)`) |
| **Input Shape** | 3D Raw Signal Tensor $(N \times 23 \times 1024)$ — 23 EEG channels, 1024 samples ($4.0\,\text{s}$ at $256\,\text{Hz}$) |
| **Task Type** | Task A: Binary Seizure Detection (`0 = non_seizure`, `1 = seizure`) |
| **Dataset** | CHB-MIT Scalp EEG Database (`dataset_id: "chbmit"`) |
| **Split Protocol** | Protocol A — Patient-Independent Holdout ($67\%$ Train, $33\%$ Test) |
| **Random Seed** | `42` |
| **Preprocessing Version** | `v1.0` (Artifact clip $\pm 800\,\mu\text{V}$, 256 Hz, Bandpass $0.5-70\,\text{Hz}$, Notch $50/60\,\text{Hz}$) |
| **Feature Schema Version** | `raw_signal_tensor_23x1024` (No handcrafted classical features) |
| **Normalization Isolation** | Channel mean/std normalization fitted exclusively on $X_{\text{train}}$ |

---

## 2. ARCHITECTURE & OVERFITTING CONTROL

```
RAW 3D TENSOR (23, 1024)
        │
        ▼
 ┌─────────────────────────────┐
 │ Conv1D (23 -> 32, k=7, s=2) │
 │ BatchNorm1d(32) + ReLU      │
 │ MaxPool1d(2) + Dropout(0.3) │
 └──────────────┬──────────────┘
                │
                ▼
 ┌─────────────────────────────┐
 │ Conv1D (32 -> 64, k=5, s=2) │
 │ BatchNorm1d(64) + ReLU      │
 │ AdaptiveAvgPool1d(1) + 0.3  │
 └──────────────┬──────────────┘
                │
                ▼
 ┌─────────────────────────────┐
 │ FC Layer (64 -> 32) + ReLU  │
 │ FC Layer (32 -> 2 Logits)   │
 └─────────────────────────────┘
```

- **Loss Function:** `CrossEntropyLoss` with balanced class weights.
- **Optimizer:** `Adam(lr=0.001, weight_decay=1e-4)`.
- **Overfitting Control:** Early stopping monitoring `val_loss` ($patience=10$ epochs), Batch Normalization, and $30\%$ Dropout per convolutional block.

---

## 3. RAW EEG INPUT VALIDATION

- **Tensor Shape:** $(600, 23, 1024)$
- **Sampling Rate:** $256.0\,\text{Hz}$
- **NaN / Inf Check:** Passed (0 missing or infinite values).
- **Validation Status:** ✅ VALID raw 3D tensor suitable for 1D deep convolutional feature extraction.

---

## 4. PATIENT-INDEPENDENT SPLIT COHORT

- **Train Patients:** `chb01`, `chb02` (400 raw signal windows).
- **Test Patients (Unseen):** `chb03` (200 raw signal windows: 180 non-seizure, 20 seizure). Zero `chb03` data seen during training or scaling fit.
- **Leakage Verification:** Passed (`verify_no_leakage()` confirmed $S_{\text{train}} \cap S_{\text{test}} = \emptyset$).

---

## 5. EVALUATION RESULTS & METRICS

Evaluated strictly on unseen test patient `chb03`:

| Metric | Measured Value | Comparison vs. Classical Baseline (EXP 001) | Status |
| :--- | :---: | :---: | :---: |
| **Accuracy** | `0.7400` (74.0%) | $-26.0\%$ vs Classical | ⚠️ SCIENTIFIC FINDING |
| **Precision** | `0.2037` (20.4%) | $-79.6\%$ vs Classical | ⚠️ HIGH FALSE POSITIVES |
| **Recall / Sensitivity** | `0.5500` (55.0%) | $-45.0\%$ vs Classical | ⚠️ MISSED SEIZURES |
| **Specificity** | `0.7611` (76.1%) | $-23.9\%$ vs Classical | ⚠️ BACKGROUND CONFUSION |
| **F1-Score** | `0.2973` (0.30) | $-0.7027$ vs Classical | ⚠️ LOWER GENERALIZATION |
| **ROC-AUC (AUROC)** | `0.7519` (0.75) | $-0.2481$ vs Classical | ⚠️ LOWER DISCRIMINATION |
| **PR-AUC (AUPRC)** | `0.4463` (0.45) | $-0.5537$ vs Classical | ⚠️ CLASS IMBALANCE SENSITIVE |
| **False Positives (FP)** | `43` | $+43$ false alarms | ⚠️ ELEVATED |
| **False Negatives (FN)** | `9` | $+9$ missed windows | ⚠️ ELEVATED |

---

## 6. CONFUSION MATRIX

Confusion matrix saved to [`ml_models/research/exp_005_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_005_confusion_matrix.json):

```
                   Predicted Non-Seizure (0)    Predicted Seizure (1)
True Non-Seizure (0)         137                         43
True Seizure (1)               9                         11
```

---

## 7. CRITICAL SCIENTIFIC COMPARISON & FAILURE ANALYSIS

1. **Spectral Feature Importance:** 1D CNN operating directly on raw time-domain waveforms achieved $74.0\%$ accuracy on unseen patient `chb03`, whereas classical models operating on explicit Welch PSD spectral band features achieved $98.0\%-100\%$.
2. **Patient Baseline Generalization:** Raw temporal waveforms carry patient-specific phase and baseline DC characteristics. Without explicit frequency-domain feature engineering (e.g. relative alpha/theta band power), pure 1D time convolutions struggle to generalize patient-independently across raw signals.
3. **Clinical Recommendation:** Deep learning architectures for scalp EEG should incorporate frequency-domain representations (STFT / Spectrograms) or hybrid spectral-spatial attention rather than unconstrained raw 1D time convolutions.

---

## 8. ARTIFACT LOCATIONS

- **Saved Checkpoint:** [`ml_models/research/1d_cnn_best_checkpoint.pt`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/1d_cnn_best_checkpoint.pt)
- **Confusion Matrix:** [`ml_models/research/exp_005_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_005_confusion_matrix.json)
- **Training History:** [`ml_models/research/exp_005_training_history.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_005_training_history.json)
- **Split Manifest:** [`ml_models/research/split_manifest_exp005.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/split_manifest_exp005.json)
- **Experiment Log:** [`ml_models/research/experiments.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/experiments.json)
- **Model Registry:** [`ml_models/research/model_registry.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/model_registry.json)
