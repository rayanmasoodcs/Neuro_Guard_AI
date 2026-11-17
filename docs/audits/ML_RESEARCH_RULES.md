# NeuroGuard AI — Machine Learning & Research Rules

These research rules apply to all machine learning pipelines, evaluation scripts, experimental notebooks, data preprocessing routines, and model training in **NeuroGuard AI**.

Research Focus:
> *"A Patient-Independent, Adaptive EEG-Based Framework for Detection and Classification of Diverse and Subtle Seizures: Design, Evaluation Protocol, and Cross-Dataset Generalization Strategy."*

---

## A. NO DATA LEAKAGE

Strict separation between training, validation, and test data is non-negotiable.

1. **Patient-Independent Evaluation (Inter-Patient Protocol):**
   - A patient's data must **never** appear in both the training set and the validation/test set.
   - Cross-validation must strictly employ Leave-One-Patient-Out (LOPO) or Patient-Stratified Group K-Fold splitting.
2. **Window & Time-Series Leakage Prevention:**
   - Overlapping EEG signal sliding windows must never span across train/val/test boundaries.
   - Sequential EEG segments from the same continuous recording must be kept in the same split to avoid temporal autocorrelation leakage.
   - Ensure duplicate or identical signal artifacts are identified and eliminated.
3. **Preprocessing & Transformation Isolation:**
   - Scalers (StandardScaler, MinMaxScaler, RobustScaler), normalizers, and filters must be fitted **exclusively on the training split**.
   - Feature selectors, PCA, embedding projectors, and dimensionality reducers must be fitted **exclusively on the training split** and applied transform-only on validation/test splits.
   - Global statistics from the full dataset must never inform model inputs.

---

## B. EXPERIMENT REPRODUCIBILITY

Every ML experiment, baseline evaluation, and training run must log complete provenance metadata.

For every experiment run, record:
- **Experiment ID** (UUID or timestamped slug)
- **Dataset Name & Version** (e.g., CHB-MIT, TUSZ, Siena, or custom dataset version)
- **Patient Cohort & IDs** used across each split
- **Train / Validation / Test Split Configuration** (exact split strategy and fold indices)
- **Preprocessing Pipeline Version** (bandpass filters, notch filter frequencies, window size, overlap stride)
- **Feature Representation & Extraction Pipeline** (raw time series, spectral band powers, wavelets, STFT, graph features, etc.)
- **Model Name, Architecture, & Version**
- **Hyperparameters** (learning rate, batch size, epochs, regularization, optimizer parameters)
- **Random Seeds** (NumPy, PyTorch, Scikit-learn, etc.)
- **Execution Date & Hardware Environment**
- **Evaluation Results & Artifact Checkpoints** (stored model weights and config jsons)

---

## C. NO FABRICATED METRICS

Academic and clinical integrity is paramount.

- **Strict Prohibition on Fabricated Metrics:** Never invent, extrapolate, or approximate performance metrics.
- Prohibited from invention:
  - Accuracy
  - Sensitivity / Recall
  - Precision / Positive Predictive Value (PPV)
  - F1-Score / Macro-F1 / Weighted-F1
  - Specificity / True Negative Rate
  - False Positive Rate (FPR) / False Positives per Hour (FP/h)
  - False Negative Rate (FNR)
  - Confusion Matrices
  - ROC-AUC / PR-AUC
- **Calculation Rule:** All reported figures must be computed strictly from real inference predictions evaluated against verified, ground-truth label annotations.

---

## D. MODEL SELECTION CRITERIA

Accuracy alone is an invalid metric for imbalanced biomedical and seizure detection datasets.

Model selection and comparison must comprehensively evaluate:
1. **Sensitivity / Recall:** Crucial for detecting rare seizure onset events and subtle seizures.
2. **False Negative Rate (FNR):** Minimizing missed seizures is critical in seizure monitoring.
3. **Specificity & False Positive Rate per Hour (FP/h):** Minimizing alarm fatigue.
4. **F1-Score & Balanced Accuracy:** Assessing balanced performance under severe class imbalance (seizure vs. non-seizure / background EEG).
5. **Class-Wise Breakdown:** Evaluating performance on distinct seizure types (focal, generalized, tonic-clonic, absence, subtle/subclinical).
6. **Patient-Independent Generalization:** Out-of-sample patient performance stability.
7. **Cross-Dataset Generalization:** Transferability across varying recording montages, electrode setups, and sampling rates.
8. **Model Stability & Variance:** Variance across folds/patients.
9. **Computational Complexity & Latency:** Feasibility for real-time edge or mobile inference.

---

## E. MEDICAL INTERPRETATION & TAXONOMY

Machine learning outputs must never be conflated with definitive clinical diagnoses.

The system must clearly delineate between distinct taxonomic categories in code, UI, and documentation:
1. **AI Model Prediction:** Statistical classification or probability score output by an algorithm.
2. **Confidence / Uncertainty Measure:** Estimated prediction confidence, epistemic uncertainty, or calibration metric.
3. **Manual / Expert Annotation:** Ground-truth markings provided by neurologists or trained EEG reviewers.
4. **Clinical Diagnosis:** Formal medical evaluation rendered by licensed healthcare professionals.

These concepts must **never** be silently equated, merged, or presented interchangeably.
