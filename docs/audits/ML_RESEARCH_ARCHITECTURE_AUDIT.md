# NeuroGuard AI — Forensic ML/AI Audit & Scientific Research Architecture

**Mission:** Mission 21 — Forensic ML Audit, Scientific Experiment Architecture & Patient-Independent Framework Locking  
**Date:** September 3, 2026  
**Status:** Completed (Audit & Design Locked — Zero Retraining Executed)  
**Governance Framework:** `MEDICAL_SAFETY_RULES.md`, `ML_RESEARCH_RULES.md`, `FINAL_ARCHITECTURE.md`, `NEUROGUARD_RISK_REGISTER.md`

---

## 1. EXECUTIVE SUMMARY

Mission 21 conducted a complete forensic scientific audit of the existing NeuroGuard AI machine learning artifacts, feature extraction pipelines, data ingestion assumptions, and model performance baselines.

The audit revealed that the active baseline model artifact (`seizure_model_production.pkl`) was trained on synthetic 16-feature noise (`demo_train.csv`) evaluated using random `StratifiedKFold` cross-validation, achieving an overall accuracy of **32.5%** and an F1-score of **29.3%**. 

Furthermore, the audit locked the scientific experiment architecture for Round 5, establishing a strict **Patient-Independent Evaluation Protocol** (`GroupKFold` / `Leave-One-Group-Out` by `patient_id`) to eliminate patient leakage, separating binary seizure detection from multiclass classification, and defining a leakage-free canonical experiment pipeline across 5–7 model families.

---

## 2. EXISTING MODEL INVENTORY & FORENSIC AUDIT

Inspection of files in `ml_models/` (`seizure_model_production.pkl`, `seizure_scaler.pkl`, `seizure_meta.json`, `production_pipeline.py`, `train_pipeline_v2.py`):

| Artifact / Property | Current Implementation Details | Forensic Finding / Assessment |
| :--- | :--- | :--- |
| **Active Production Model** | `seizure_model_production.pkl` / `.joblib` | Calibrated Support Vector Classifier (`SVC(C=3.437, gamma='auto')`) |
| **Scaler Artifact** | `seizure_scaler.pkl` / `.joblib` | `StandardScaler` fitted on 14 selected features |
| **Metadata File** | `seizure_meta.json` (Version `v2`) | Documents model params, 14 selected features, and evaluation metrics |
| **Training Dataset** | `demo_train.csv` (801 rows, 16 columns) | **Synthetic Random Data:** Not derived from clinical patient EEGs |
| **Test Accuracy** | `32.5%` (`seizure_meta.json:44`) | Barely above random chance for 4 classes |
| **Test F1-Macro** | `29.3%` (`seizure_meta.json:48`) | High misclassification rate across all classes |
| **Test ROC-AUC** | `0.5618` (`seizure_meta.json:49`) | Poor class discrimination capability |

---

## 3. FEATURE SCHEMA & PREPROCESSING MISMATCH ANALYSIS

Forensic investigation of `ml_models/production_pipeline.py` vs `ml_models/train_pipeline_v2.py`:

```
+-----------------------------------------------------------------------------------+
|                  FEATURE SCHEMA MISMATCH & RUNTIME WORKAROUND                     |
+-----------------------------------------------------------------------------------+
| 1. Training Schema (train_pipeline_v2.py):                                        |
|    - Expects 16 static synthetic columns (feature_0 ... feature_15).              |
|    - RFECV feature selection reduced schema to 14 active features.                |
|                                                                                   |
| 2. Signal Preprocessing Extractor (production_pipeline.py:aggregate_channel_features):|
|    - Extracts 36 signal processing features across 14-19 EEG channels:           |
|      * Hjorth Parameters (Activity, Mobility, Complexity)                        |
|      * Welch PSD Band Powers (Delta 0.5-4Hz, Theta 4-8Hz, Alpha 8-13Hz,          |
|        Beta 13-30Hz, Gamma 30-100Hz) & Relative Powers                           |
|      * Spectral Entropy, Line Length, RMS, Mean, Standard Deviation             |
|                                                                                   |
| 3. Runtime Defensive Adapter (production_pipeline.py:predict_from_raw):            |
|    - Automatically truncates 36 extracted features down to 14 or zero-pads        |
|      vector to match scaler dimension.                                            |
|    - CONSEQUENCE: Real signal information is discarded to match synthetic model.   |
+-----------------------------------------------------------------------------------+
```

---

## 4. DATASET AVAILABILITY & COMPATIBILITY AUDIT

### Current Repository Inventory
- **Local Clinical Datasets:** **0 datasets** currently mounted/downloaded in local repository.
- **Reference Datasets:** Architecture documents specify **CHB-MIT Scalp EEG** and **Siena Scalp EEG**.

### Cross-Dataset Scientific Compatibility Assessment

| Dimension | CHB-MIT Scalp EEG Database | Siena Scalp EEG Dataset | Harmonization Requirement |
| :--- | :--- | :--- | :--- |
| **Institution** | Boston Children's Hospital / PhysioNet | Univ. of Siena / PhysioNet | Independent recording conditions |
| **Subject Population** | 23 Pediatric Patients (chb01–chb24) | 9 Adult Patients (PN00–PN10) | Distinct demographic distributions |
| **Montage Type** | 23-channel Bipolar Montage | 29-channel Monopolar / Average | Standardize to 10-20 Common Subset |
| **Sampling Frequency** | 256 Hz | 512 Hz | Resample Siena recordings to 256 Hz |
| **Annotation Format** | Text files (`.seizures` / summary.txt) | EDF Annotations (`.edf.seizures`) | Custom EDF annotation parsers |
| **Seizure Types** | Pediatric Focal & Generalized | Adult Focal Onset | Separate Task A from Task B |

> [!IMPORTANT]
> **Compatibility Conclusion:** CHB-MIT and Siena Scalp EEG datasets are **NOT directly interchangeable** without explicit montage harmonization (10-20 International System subset) and anti-aliased resampling.

---

## 5. PATIENT LEAKAGE & SCIENTIFIC RISKS

1. **Patient Leakage Risk (CRITICAL):**
   - Previous baseline scripts used random `StratifiedKFold` cross-validation across sliding EEG windows.
   - When 4-second sliding windows (with 50% overlap) from the same patient's EEG recording are split randomly across train and test folds, **overlapping temporal windows from Patient #1 appear in both training and test sets**.
   - This leads to severe **patient contamination** and inflated, ungeneralizable performance metrics.

2. **Resolution — Locked Patient-Independent Protocol:**
   - All evaluation in Round 5 MUST enforce **`GroupKFold` or `Leave-One-Group-Out` (LOGO-CV)** partitioned by `patient_id`.
   - **ZERO patient overlap** permitted between training, validation, and testing folds.

---

## 6. EXPLICIT TASK DEFINITIONS

To prevent scientific confusion between detection and classification:

### TASK A: Binary Seizure Detection
- **Objective:** Classify EEG windows as `Seizure` (1) vs `Non-Seizure` (0).
- **Window Length:** 4.0 seconds (1024 samples at 256 Hz) with 2.0s step overlap.
- **Primary Metrics:** Sensitivity (Recall), False Positive Rate per hour (FPR/h), AUROC, AUPRC, Specificity.

### TASK B: Multiclass Seizure Classification
- **Objective:** Classify specific seizure clinical subtypes (e.g. Focal, Generalized Tonic-Clonic, Absence).
- **Inclusion Criteria:** Evaluated ONLY on datasets where seizure subtypes are explicitly annotated with a minimum of **50 events per class**.

### TASK C: Cross-Patient Generalization
- **Objective:** Evaluate model performance on unseen patients within the same dataset using `GroupKFold(n_splits=5, groups=patient_id)`.

### TASK D: Cross-Dataset Generalization
- **Objective:** Train model exclusively on CHB-MIT (Pediatric) -> Evaluate out-of-domain transfer performance on Siena Scalp EEG (Adult).

---

## 7. CANDIDATE MODEL COMPARISON ARCHITECTURE (5–7 MODELS)

The Round 5 benchmark suite will compare **6 candidate model architectures** under identical patient-independent splits and preprocessing assumptions:

1. **Random Forest Classifier (Baseline ML):** Ensemble of decision trees with balanced class weighting.
2. **Support Vector Classifier (SVC):** Calibrated RBF kernel SVM with probability scaling.
3. **HistGradientBoosting Classifier:** Fast gradient-boosted decision trees for non-linear feature interactions.
4. **1D Convolutional Neural Network (1D CNN):** Multi-layer 1D CNN operating directly on raw multi-channel EEG time-series windows.
5. **CNN + LSTM / GRU Network:** Spatio-temporal deep network combining 1D CNN spatial feature extraction with Recurrent units for temporal modeling.
6. **Spatial-Temporal Attention / Transformer (Optional Advanced DL):** Multi-head self-attention network modeling inter-channel dependencies and long-range time dynamics.

---

## 8. CANONICAL EXPERIMENT PIPELINE (LEAKAGE-FREE)

```
Raw EEG Files (.edf)
     ↓
Dataset Ingestion (CHB-MIT / Siena EDF Parsers)
     ↓
Annotation Validation & Timestamp Matching
     ↓
Montage Harmonization (10-20 System) & Resampling (256 Hz)
     ↓
Segmentation & Sliding Windowing (4s Window, 2s Step)
     ↓
Label & Patient Metadata Assignment (Group = patient_id)
     ↓
Patient-Independent Split (GroupKFold / LOGO-CV by patient_id)
     ↓
[TRAINING SET ONLY] Fit Scaler & Feature Extraction Normalization
     ↓
[VALIDATION / TEST SET] Transform using Training-Fitted Scaler (NO LEAKAGE)
     ↓
Model Training (6 Candidate Models)
     ↓
Inference & Evaluation (AUROC, AUPRC, Sensitivity, Specificity, F1, FPR/h)
     ↓
Error Analysis & Model Registration into seizure_meta.json
```

> [!CAUTION]
> **Leakage Prevention Rule:** `StandardScaler` and feature normalization parameters MUST be fitted on the **training fold ONLY** and applied to the validation/test fold. Fitting scalers on the entire dataset prior to splitting is strictly prohibited.

---

## 9. ADAPTIVE FRAMEWORK DEFINITION

The term **"Adaptive"** in NeuroGuard AI is defined as:

1. **Domain-Aware Preprocessing:** Dynamic z-score signal scaling adapted to individual channel variances per recording session without altering test evaluation bounds.
2. **Dataset-Aware Ingestion:** Auto-detection of input sampling rate (e.g. 512 Hz vs 256 Hz) with dynamic anti-aliasing low-pass filtering and resampling.
3. **Confidence-Based Abstention:** Predictions with high entropy / uncertainty (softmax probability between 0.40 and 0.60) trigger an `UNCERTAIN_PREDICTION` flag requesting physician review.
4. **Probability Calibration:** Isotonic regression or Platt scaling ensuring predicted probabilities reflect true empirical error rates.

*Unsafe online retraining on user mobile devices is strictly prohibited to prevent catastrophic forgetting and evaluation contamination.*

---

## 10. TRAINING VS. PRODUCTION INFERENCE BOUNDARY

- **Research Training Pipeline (`ml_models/research/`):** Dynamic multi-patient training, hyperparameter tuning, cross-dataset evaluation.
- **Production Inference Pipeline (`ml_models/production_pipeline.py`):** Version-locked static model file (`seizure_model_production.joblib` / `.pkl`) + scaler (`seizure_scaler.joblib`) + metadata (`seizure_meta.json`).
- Mobile Flutter app and Flask REST API execute ONLY `predict_from_raw()` using version-locked artifacts. Zero online model retraining occurs on user mobile devices.

---

## 11. GO/NO-GO STATUS & RECOMMENDED NEXT MISSION

- **Mission 21 Status:** **COMPLETE (Audit & Design Locked)**
- **Models Retrained:** **NO** (Strictly enforced audit phase)
- **Next Recommended Mission:** **Mission 22** — *Implement Clinical Dataset Ingestion & Preprocessing Pipeline for CHB-MIT / Siena EEG Datasets*.
