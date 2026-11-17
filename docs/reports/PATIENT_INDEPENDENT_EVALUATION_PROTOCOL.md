# Patient-Independent Evaluation Protocol — NeuroGuard AI

**Version:** 1.0  
**Date:** September 3, 2026  
**Status:** Approved & Verified (Mission 24)  
**Implementation Module:** [`ml_models/research/splitting.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/splitting.py)

---

## 1. SPLIT STRATEGY & ABSOLUTE LEAKAGE RULE

### 1.1 The Absolute Leakage Rule
> **EEG window data MUST NOT be randomly split.**
>
> In EEG-based machine learning, temporal windows extracted from the same recording or the same patient exhibit strong autocorrelation and patient-specific baseline spectral traits. If windows from Patient X are randomly assigned to both training and test sets, the model will memorize Patient X's individual physiological baseline rather than learning generalizable seizure biomarkers.

### 1.2 Patient-Level Disjoint Splitting
All partitioning occurs strictly at the **Patient ID** level before window indexing or feature matrix construction. For any partition $(S_{\text{train}}, S_{\text{val}}, S_{\text{test}})$:

$$\text{Patient}(S_{\text{train}}) \cap \text{Patient}(S_{\text{val}}) = \emptyset$$
$$\text{Patient}(S_{\text{train}}) \cap \text{Patient}(S_{\text{test}}) = \emptyset$$
$$\text{Patient}(S_{\text{val}}) \cap \text{Patient}(S_{\text{test}}) = \emptyset$$

---

## 2. SCIENTIFIC JUSTIFICATION

1. **Clinical Utility:** NeuroGuard AI is designed as a patient-independent screening framework for newly presenting patients whose EEG profiles have never been seen during training.
2. **Prevention of Overoptimistic Metrics:** Random window splitting regularly reports misleadingly high AUROC ($>99\%$) due to patient baseline memorization. Grouped patient-level evaluation reports realistic cross-patient generalization ($75\%-92\%$).
3. **Regulatory Alignment:** Medical software validation guidelines (FDA AI/ML SaMD guidelines and ISO 14971 / IEC 62304) require patient-disjoint test cohorts for diagnostic algorithms.

---

## 3. TRAIN / VALIDATION / TEST RULES

| Partition | Patient Allocation | Role & Constraints |
| :--- | :--- | :--- |
| **TRAIN** | $65\% - 70\%$ of Patient Cohort | Model training, loss minimization, gradient updates, and feature scaler fitting. |
| **VALIDATION** | $15\% - 20\%$ of Patient Cohort | Hyperparameter tuning, early stopping, threshold selection, model selection across 5–7 model candidates. |
| **TEST (HOLDOUT)** | $15\% - 20\%$ of Patient Cohort | **Strictly locked final evaluation.** Zero influence on scaling, feature selection, architecture tuning, or early stopping. Evaluated ONCE at benchmark conclusion. |

---

## 4. PREPROCESSING LEAKAGE PREVENTION

Learned transformations (such as `StandardScaler`, PCA, or feature selection) must be fitted **EXCLUSIVELY on training partition data**:

```
                       X_train (Train Patients)
                                  │
                                  ▼
                     ┌──────────────────────────┐
                     │ Fit LeakageFreeScaler    │
                     │ (Compute mu, sigma)      │
                     └────────────┬─────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         ▼                        ▼                        ▼
  Transform(X_train)       Transform(X_val)        Transform(X_test)
 (Train Features)         (Val Features)          (Test Features)
```

- **Violation Guard:** `LeakageFreeScaler` raises `RuntimeError` if `.transform()` is called before `.fit_transform()` on `X_train`.
- **Global Normalization Prohibited:** No joint normalization or global z-score normalization across all recordings prior to splitting.

---

## 5. CLASS IMBALANCE STRATEGY

1. **Natural Imbalance Acknowledgment:** In continuous EEG recordings, non-seizure background activity accounts for $>95\%$ of total recording duration (e.g. 19 seizure windows vs. 1778 non-seizure windows in `chb01_03`).
2. **No Resampling of Test Data:** Validation and Test sets retain natural class distributions. Synthetic sampling (SMOTE/ADASYN) or undersampling is **PROHIBITED on test and validation sets**.
3. **Training-Only Class Balancing:** If class balancing is required during training, sample weighting (`class_weight='balanced'`) or training-fold-only random undersampling may be used.
4. **Primary Evaluation Metrics:**
   - **Primary Metric:** Area Under the Precision-Recall Curve (AUPRC) & Area Under ROC (AUROC).
   - **Secondary Metrics:** Sensitivity (Recall), Specificity, False Positive Rate per Hour (FPR/h), and F1-Score.

---

## 6. CROSS-VALIDATION STRATEGY (PROTOCOLS A, B, C)

### Protocol A — Patient-Independent Holdout Split
- **Usage:** Primary benchmark evaluation split ($70\%$ Train, $15\%$ Val, $15\%$ Test).
- **Execution:** Deterministic stratified patient assignment allocating patients with recorded seizures proportionally across splits.

### Protocol B — Patient-Grouped K-Fold Cross-Validation (5-Fold GroupKFold)
- **Usage:** Model selection and hyperparameter optimization.
- **Execution:** 5-fold `GroupKFold` on patient IDs. In every fold $k$, $4/5$ of patients form the training fold, and $1/5$ form the validation fold.

### Protocol C — Leave-One-Subject-Out (LOSO / LOGO)
- **Usage:** In-depth generalization profiling per patient.
- **Execution:** $N$ folds where $N = \text{number of patients}$ (23 folds for CHB-MIT, 14 folds for Siena). In fold $i$, Patient $i$ is held out as the single validation subject.

---

## 7. LEAVE-ONE-SUBJECT-OUT (LOSO) FEASIBILITY ANALYSIS

- **CHB-MIT (23 Patients):** Fully feasible for classical ML models (RandomForest, LightGBM, SVC). Computationally demanding for deep learning models; 5-fold GroupKFold (Protocol B) serves as the primary cross-validation alternative for neural network architectures.
- **Siena (14 Patients):** Fully feasible for all model families (14 total folds).

---

## 8. CROSS-DATASET PROTOCOL (CHB-MIT $\rightarrow$ SIENA)

For zero-shot cross-dataset evaluation:
1. **Training Set:** 100% of CHB-MIT patients ($N=23$).
2. **External Test Set:** 100% of Siena patients ($N=14$). Zero Siena data seen during training or scaling fit.
3. **Isolation Rule:** Feature scaling parameters fitted on CHB-MIT training data are applied to Siena test data without refitting.
4. **Domain Shift Metric:** Performance delta ($\Delta \text{AUROC} = \text{AUROC}_{\text{CHB-MIT}} - \text{AUROC}_{\text{Siena}}$) is reported as a primary scientific finding measuring pediatric-to-adult generalization.

---

## 9. AUTOMATED LEAKAGE CHECKS

The function `verify_no_leakage()` is called automatically prior to any training or evaluation run:

```python
def verify_no_leakage(train_patients, val_patients, test_patients,
                       train_recordings=None, val_recordings=None, test_recordings=None):
    # 1. Asserts train_patients ∩ val_patients = ∅
    # 2. Asserts train_patients ∩ test_patients = ∅
    # 3. Asserts val_patients ∩ test_patients = ∅
    # 4. Asserts recording-level disjointness
    # Raises DataLeakageError on failure
```

---

## 10. REPRODUCIBILITY STRATEGY

1. **Split Manifest Export:** Every experiment run saves a reproducible JSON split artifact (e.g. `ml_models/research/split_manifest_chbmit.json`) containing:
   - Experiment ID & Timestamp
   - Random seed (default: `42`)
   - Exact patient IDs allocated to `train`, `validation`, and `test`
   - Total window count & class distribution per split
2. **Fixed Random Seeds:** All stochastic operations (patient shuffling, model initialization) use fixed seeds.
