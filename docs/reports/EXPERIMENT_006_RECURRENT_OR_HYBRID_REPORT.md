# Experiment 006 — CNN + LSTM Hybrid Recurrent Deep Learning Model Report

**Experiment ID:** `EXP_006_CNN_LSTM`  
**Model ID:** `MODEL_CNN_LSTM_V1`  
**Date:** September 3, 2026  
**Status:** Completed  
**Execution Script:** [`ml_models/research/train_cnn_lstm.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/train_cnn_lstm.py)

---

## 1. SCIENTIFIC JUSTIFICATION & MODEL SELECTION

- **Scientific Rationale:** Scalp EEG seizure discharges exhibit spatio-temporal evolution across a 4.0-second window (pre-ictal background $\rightarrow$ high-amplitude fast activity $\rightarrow$ post-ictal suppression). A hybrid CNN + LSTM models spatial multi-channel features at sub-second intervals ($1.0\,\text{s}$ sub-windows) using 1D convolutions, then captures temporal transition dynamics across sub-steps via an LSTM recurrent layer.
- **Model Type:** `CNN_LSTM_Hybrid` (1D Spatial Conv + Recurrent LSTM).
- **Computational Feasibility:** Verified feasible ($\approx 600$ sub-sequence tensors processed under 15 seconds).

---

## 2. EXPERIMENT CONFIGURATION

| Parameter | Configuration Detail |
| :--- | :--- |
| **Experiment ID** | `EXP_006_CNN_LSTM` |
| **Model Architecture** | `Conv1D(23->32)` per sub-step $\rightarrow$ `LSTM(input=2048, hidden=64)` $\rightarrow$ `FC(64->32->2)` |
| **Input Shape** | 4D Sub-Sequence Tensor $(N \times 4 \times 23 \times 256)$ — 4 sub-steps, 23 channels, 256 samples each |
| **Task Type** | Task A: Binary Seizure Detection (`0 = non_seizure`, `1 = seizure`) |
| **Dataset** | CHB-MIT Scalp EEG Database (`dataset_id: "chbmit"`) |
| **Split Protocol** | Protocol A — Patient-Independent Holdout ($67\%$ Train, $33\%$ Test) |
| **Random Seed** | `42` |
| **Preprocessing Version** | `v1.0` (Artifact clip $\pm 800\,\mu\text{V}$, 256 Hz, Bandpass $0.5-70\,\text{Hz}$, Notch $50/60\,\text{Hz}$) |
| **Feature Schema Version** | `raw_subsequence_tensor_4x23x256` |
| **Normalization Isolation** | Channel mean/std normalization fitted exclusively on $X_{\text{train}}$ |

---

## 3. PATIENT-INDEPENDENT SPLIT COHORT

- **Train Patients:** `chb01`, `chb02` (400 sub-sequence tensors).
- **Test Patients (Unseen):** `chb03` (200 sub-sequence tensors: 180 non-seizure, 20 seizure).
- **Leakage Verification:** Passed (`verify_no_leakage()` confirmed zero patient overlap).

---

## 4. EVALUATION RESULTS & METRICS

Evaluated strictly on unseen test patient `chb03`:

| Metric | Measured Value | Comparison vs. Classical Baseline (EXP 001) | Status |
| :--- | :---: | :---: | :---: |
| **Accuracy** | `0.9000` (90.0%) | $-10.0\%$ | ⚠️ MAJORITY CLASS COLLAPSE |
| **Precision** | `0.0000` (0.0%) | $-100.0\%$ | ❌ NO SEIZURES DETECTED |
| **Recall / Sensitivity** | `0.0000` (0.0%) | $-100.0\%$ | ❌ ALL SEIZURES MISSED |
| **Specificity** | `1.0000` (100.0%) | Equal (`1.0000`) | ✅ NO FALSE POSITIVES |
| **F1-Score** | `0.0000` (0.0%) | $-1.0000$ | ❌ FAILED RECALL |
| **ROC-AUC (AUROC)** | `0.0117` (0.01) | $-0.9883$ | ❌ POOR RANKING |
| **PR-AUC (AUPRC)** | `0.0518` (0.05) | $-0.9482$ | ❌ POOR PRECISION-RECALL |
| **False Positives (FP)** | `0` | Equal (`0`) | ✅ ZERO FALSE ALARMS |
| **False Negatives (FN)** | `20` | $+20$ missed seizures | ❌ ALL 20 MISSED |

---

## 5. CONFUSION MATRIX

Confusion matrix saved to [`ml_models/research/exp_006_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_006_confusion_matrix.json):

```
                   Predicted Non-Seizure (0)    Predicted Seizure (1)
True Non-Seizure (0)         180                          0
True Seizure (1)              20                          0
```

---

## 6. OVERFITTING & SCIENTIFIC FAILURE ANALYSIS

1. **Temporal Oversmoothing & Majority Class Collapse:** Under high class imbalance ($90\%$ non-seizure vs $10\%$ seizure), recurrent hidden states ($h_t$) accumulate majority background information across sub-windows, causing the network to collapse to predicting non-seizure for all samples ($90\%$ raw accuracy, $0\%$ sensitivity).
2. **Raw Sub-Window Limitation:** Direct temporal convolutions on sub-second raw voltage sequences without spectral PSD band features fail to provide strong discriminating gradients across recurrent time steps.
3. **Key Finding across Round 6 Experiments:** Classical machine learning models utilizing explicit Welch PSD band power features significantly outperform unconstrained deep neural networks (1D CNN & CNN+LSTM) on patient-independent scalp EEG seizure detection.

---

## 7. ARTIFACT LOCATIONS

- **Saved Checkpoint:** [`ml_models/research/cnn_lstm_best_checkpoint.pt`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/cnn_lstm_best_checkpoint.pt)
- **Confusion Matrix:** [`ml_models/research/exp_006_confusion_matrix.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_006_confusion_matrix.json)
- **Training History:** [`ml_models/research/exp_006_training_history.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/exp_006_training_history.json)
- **Split Manifest:** [`ml_models/research/split_manifest_exp006.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/split_manifest_exp006.json)
- **Experiment Log:** [`ml_models/research/experiments.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/experiments.json)
- **Model Registry:** [`ml_models/research/model_registry.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/model_registry.json)
