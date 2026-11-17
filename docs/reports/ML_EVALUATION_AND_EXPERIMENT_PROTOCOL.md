# ML Evaluation and Experiment Protocol — NeuroGuard AI

**Version:** 1.0  
**Date:** September 3, 2026  
**Status:** Approved & Verified (Mission 25)  
**Implementation Modules:**  
- [`ml_models/research/evaluation.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/evaluation.py)  
- [`ml_models/research/registry.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/registry.py)

---

## 1. REQUIRED METRICS & MATHEMATICAL DEFINITIONS

Accuracy alone is deceptive in seizure detection due to severe class imbalance ($>95\%$ background activity). The evaluation framework calculates and reports the following reusable metrics:

| Metric | Formula / Calculation | Clinical & Scientific Rationale |
| :--- | :--- | :--- |
| **Accuracy** | $\frac{TP + TN}{TP + TN + FP + FN}$ | Overall correctness. Reported but secondary. |
| **Sensitivity / Recall** | $\frac{TP}{TP + FN}$ | **Primary Metric:** Rate of correctly identified seizure windows. |
| **Specificity** | $\frac{TN}{TN + FP}$ | Rate of correctly identified non-seizure background windows. |
| **Precision** | $\frac{TP}{TP + FP}$ | Fraction of positive predictions that are true seizures. |
| **F1-Score** | $2 \cdot \frac{\text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$ | Harmonic mean of precision and recall. |
| **False Positive Rate (FPR)** | $\frac{FP}{FP + TN}$ | Rate of false alarms per total non-seizure windows. |
| **False Negative Rate (FNR)** | $\frac{FN}{FN + TP}$ | Rate of missed seizures (critical medical risk). |
| **False Positive Count (FP)** | Absolute integer count | Number of false alarm windows. |
| **False Negative Count (FN)** | Absolute integer count | Number of missed seizure windows. |
| **ROC-AUC (AUROC)** | Area under ROC Curve ($TPR$ vs $FPR$) | Threshold-independent discrimination power across operating points. |
| **PR-AUC (AUPRC)** | Area under PR Curve ($\text{Precision}$ vs $\text{Recall}$) | **Primary Metric under Imbalance:** Focuses strictly on the rare positive class. |

---

## 2. CONFUSION MATRIX POLICY

1. **Mandatory Generation:** Every evaluated model must generate a labeled $2 \times 2$ (binary) or $K \times K$ (multiclass) confusion matrix.
2. **Standard Alignment:** Rows represent **Ground Truth** ($y_{\text{true}}$); columns represent **Model Prediction** ($y_{\text{pred}}$).
3. **No Overwriting:** Confusion matrix outputs are stored per experiment ID (`EXP_..._cm.json`) to preserve full history across hyperparameter runs.

---

## 3. VISUALIZATION POLICY

The evaluation engine supports generating the following standardized plots:
1. **Confusion Matrix Heatmaps:** Normalized and raw count heatmaps.
2. **ROC Curves:** Plotted per model candidate with confidence intervals.
3. **Precision-Recall Curves:** Plotted with baseline random performance reference line.
4. **Model Comparison Bar Charts:** Side-by-side comparison of AUROC, AUPRC, F1-Score, and Sensitivity across candidate models.
5. **Training History Curves:** Loss and accuracy vs. epoch for deep learning architectures.
6. **Patient-Level Error Distribution:** Error counts (FP and FN) grouped by patient ID.

---

## 4. EXPERIMENT METADATA SCHEMA

All experiments log JSON metadata to [`ml_models/research/experiments.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/experiments.json) without overwriting existing entries:

```json
{
  "experiment_id": "EXP_20260903_153000_RF01",
  "timestamp": "2026-09-03T15:30:00.000000",
  "model_type": "RandomForestClassifier",
  "hyperparameters": {
    "n_estimators": 100,
    "max_depth": 15,
    "class_weight": "balanced"
  },
  "dataset_id": "chbmit",
  "split_protocol": "Protocol A — Patient-Independent Holdout",
  "seed": 42,
  "preprocessing_version": "v1.0",
  "feature_schema_version": "v1.0",
  "metrics": {
    "accuracy": 0.885,
    "precision": 0.721,
    "recall_sensitivity": 0.842,
    "specificity": 0.890,
    "f1_score": 0.777,
    "roc_auc": 0.923,
    "pr_auc": 0.815,
    "fp": 198,
    "fn": 31,
    "status": "EXPERIMENT_COMPLETED"
  },
  "status": "EXPERIMENT_COMPLETED",
  "notes": "Baseline classical ML evaluation"
}
```

---

## 5. MODEL REGISTRY SCHEMA & COMPATIBILITY GATE

Trained models are registered in [`ml_models/research/model_registry.json`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/model_registry.json). The inference layer enforces pre-prediction compatibility checks:

```python
# Compatibility validation interface:
valid, message = registry.validate_model_compatibility(
    model_id="MODEL_RF_V1",
    input_feature_count=38,
    input_pp_version="v1.0"
)
```

Rejection occurs if:
- Feature count does not match `expected_n_features` (e.g. 38 features).
- Preprocessing version does not match `preprocessing_version` (e.g. `v1.0`).
- Model `compatibility_status` is not `PRODUCTION_READY`.

---

## 6. CONFIDENCE & UNCERTAINTY STRATEGY

1. **Probability Margin:** For binary threshold $T = 0.5$ and margin $M = 0.15$:
   - High Confidence Seizure: $P(\text{Seizure}) > 0.65$
   - High Confidence Non-Seizure: $P(\text{Seizure}) < 0.35$
   - **Low-Confidence Abstain Region:** $0.35 \le P(\text{Seizure}) \le 0.65$
2. **Abstain Flag (`uncertain_abstain`):** Windows falling in the low-confidence margin are flagged as `is_certain=False` to prevent presenting uncertain model outputs as definitive medical diagnoses.

---

## 7. ERROR ANALYSIS STRATEGY

`ErrorAnalyzer` indexes FP and FN instances to trace failure patterns:
- **Patient-Level Error Grouping:** Identifies if false positives/negatives concentrate in specific patients.
- **Recording-Level Trace:** Flags continuous recordings with elevated noise or baseline shifts.
- **Privacy Protection:** Patient IDs remain anonymized hashes (`chb01`, `PN00`) in logs.

---

## 8. PATIENT-FACING VS. RESEARCH/DOCTOR RESULT BOUNDARIES

```
                        Raw Model Inference
                                │
                                ▼
                   ┌──────────────────────────┐
                   │ Uncertainty & Metrics    │
                   │ Evaluation Module        │
                   └────────────┬─────────────┘
                                │
         ┌──────────────────────┴──────────────────────┐
         ▼                                             ▼
 ┌─────────────────────────────┐               ┌─────────────────────────────┐
 │ Doctor / Research View      │               │ Patient View                │
 │ - AUROC / AUPRC / F1        │               │ - Simplified Status        │
 │ - Full Confusion Matrix     │               │   ("Normal" / "Review")     │
 │ - Per-channel PSD & Heatmap │               │ - Low-confidence flag       │
 │ - Low-confidence abstain rate│              │   ("Consult Physician")     │
 └─────────────────────────────┘               └─────────────────────────────┘
```

- **Doctor/Researcher Role:** Access to raw probabilities, confusion matrices, patient-level error analysis, and full metric suites via authorized APIs.
- **Patient Role:** Simplified qualitative status notifications (e.g., "EEG Analysis Complete — Reviewed by NeuroGuard AI"). Low-confidence flags prompt recommendation for clinical physician review rather than displaying confusing confidence scores.
