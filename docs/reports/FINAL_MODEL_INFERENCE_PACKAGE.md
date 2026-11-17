# Final Model Inference Package Specification

**Package Name:** `neuroguard_production_inference`  
**Selected Model ID:** `MODEL_RF_V1`  
**Model Version:** `v1.0.0`  
**Date:** September 3, 2026  
**Status:** Validated & Production-Ready  
**Inference Module:** [`ml_models/production_inference.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/production_inference.py)  
**Test Suite:** [`test_production_inference.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/test_production_inference.py)

---

## 1. PACKAGE SPECIFICATION & ARTIFACT METADATA

| Parameter | Package Specification Detail |
| :--- | :--- |
| **Selected Model Algorithm** | `RandomForestClassifier(n_estimators=100, max_depth=15, class_weight='balanced')` |
| **Model ID** | `MODEL_RF_V1` |
| **Model Version** | `v1.0.0` |
| **Model Artifact** | [`ml_models/research/random_forest_model.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/random_forest_model.joblib) |
| **Scaler Artifact** | [`ml_models/research/random_forest_scaler.joblib`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/random_forest_scaler.joblib) |
| **Preprocessing Version** | `v1.0` (Bandpass $0.5-70\,\text{Hz}$, Notch $50/60\,\text{Hz}$, Artifact clip $\pm 800\,\mu\text{V}$, Polyphase $256\,\text{Hz}$) |
| **Feature Schema Version** | `v1.0` (38 classical time, Hjorth, and Welch PSD features) |
| **Expected Input Shape** | $(N, 38)$ — 2D Matrix of 38 numerical features per window |
| **Low-Confidence Cutoff** | `0.65` (65.0% prediction probability threshold) |
| **Task Definition** | Task A: Binary Seizure Detection (`0 = non_seizure`, `1 = seizure`) |

---

## 2. INPUT VALIDATION GATE & SAFETY RULES

Before running inference, `NeuroGuardInferenceEngine.validate_features()` enforces 5 strict validation gates:
1. **Dimension Check:** Input must be a 2D matrix $(N \times 38)$. 1D single-window inputs $(38,)$ are auto-reshaped to $(1 \times 38)$.
2. **Feature Count Gate:** Must match exactly 38 numerical features matching canonical schema `v1.0`. Schema mismatches (e.g., 36 features) raise `InferenceInputError`.
3. **NaN Protection:** Inputs containing NaN values are rejected immediately with `InferenceInputError`.
4. **Inf Protection:** Inputs containing infinite (Inf) values are rejected immediately.
5. **Artifact Integrity:** Missing or corrupted model/scaler files raise `ModelArtifactError`.

---

## 3. LOW-CONFIDENCE ABSTENTION POLICY

 predictions with confidence $< 0.65$ trigger a safe abstention state:
- **Status Field:** `"UNABLE_TO_RELIABLY_CLASSIFY"`
- **Low-Confidence Flag:** `True`
- **Warning Notice:** `"Prediction confidence is below safety threshold (65.00%). Manual expert EEG review required."`
- **Clinical Benefit:** Prevents false alarms on ambiguous, highly noisy EEG segments by requesting expert neurologist review.

---

## 4. NON-DIAGNOSTIC OUTPUT STRUCTURE & MEDICAL DISCLAIMER

All inference outputs follow a structured JSON response schema:

```json
{
  "model_id": "MODEL_RF_V1",
  "model_version": "v1.0.0",
  "preprocessing_version": "v1.0",
  "feature_schema_version": "v1.0",
  "status": "SUCCESS",
  "prediction": "seizure",
  "clinical_finding": "Electrographic Seizure Activity Detected",
  "confidence": 0.985,
  "class_probabilities": {
    "non_seizure": 0.015,
    "seizure": 0.985
  },
  "low_confidence_flag": false,
  "warnings": [],
  "medical_disclaimer": "NeuroGuard AI is an assistive research and clinical decision support prototype. Output does not constitute a formal clinical diagnosis. All findings must be reviewed by a board-certified neurologist."
}
```

---

## 5. APPLICATION BOUNDARY ISOLATION

To ensure clinical safety and user clarity, the backend architecture enforces strict separation between **Research Metrics** and **Patient Analysis**:

```
                       ┌─────────────────────────┐
                       │   MODEL INFERENCE RUN   │
                       └────────────┬────────────┘
                                    │
            ┌───────────────────────┴───────────────────────┐
            ▼                                               ▼
┌───────────────────────────────┐               ┌───────────────────────────────┐
│   PATIENT-FACING ANALYSIS     │               │   RESEARCH EXPERIMENT METRICS │
│  (production_inference.py)    │               │    (experiments.json log)     │
├───────────────────────────────┤               ├───────────────────────────────┤
│ • Clinical Finding Display    │               │ • Confusion Matrix            │
│ • Window Confidence %         │               │ • ROC-AUC / PR-AUC Scores     │
│ • Low Confidence Abstention   │               │ • Cross-Validation Folds      │
│ • Non-Diagnostic Disclaimer   │               │ • Patient ID Splits & Seeds   │
└───────────────────────────────┘               └───────────────────────────────┘
```

Patients and clinicians are presented only with decision support findings and safety disclaimers, never internal research confusion matrices or holdout split seeds.
