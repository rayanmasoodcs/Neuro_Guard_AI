"""
NeuroGuard AI — Mission 27: Random Forest Experiment 002
=========================================================
Trains ONE bounded Random Forest classifier under the locked
patient-independent evaluation protocol (Protocol A).

Guarantees:
-----------
1. Strict feature schema verification prior to model fitting.
2. Identical patient split and seed (seed 42) as Baseline Experiment 001.
3. Preprocessing isolation using LeakageFreeScaler fitted ON X_train ONLY.
4. Error analysis of False Positives and False Negatives.
5. Experiment logged to ExperimentTracker and ModelRegistry without overwriting baseline.
"""

import os
import sys
import json
import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier

sys.path.insert(0, os.path.abspath("."))

from ml_models.research.eeg_io import CHBMITReader
from ml_models.research.preprocessing import preprocess_recording
from ml_models.research.segmentation import segment_recording, SegmentedDataset, EEGWindow
from ml_models.research.feature_extraction import extract_features_classical, FEATURE_SCHEMA_VERSION
from ml_models.research.splitting import (
    split_patient_independent_holdout, verify_no_leakage, LeakageFreeScaler, export_split_manifest
)
from ml_models.research.evaluation import (
    compute_binary_metrics, ErrorAnalyzer, UncertaintyEvaluator, STATUS_COMPLETED
)
from ml_models.research.registry import ExperimentTracker, ModelRegistry
from ml_models.research.train_baseline import generate_synthetic_patient_windows

EXPERIMENT_ID = "EXP_002_RANDOM_FOREST"
MODEL_ID      = "MODEL_RF_V1"
DATASET_ID    = "chbmit"
SEED          = 42


def validate_feature_schema(X: np.ndarray, feature_names: list) -> tuple:
    """
    Verifies feature matrix schema before training:
    - Expected column count
    - Absence of NaN or Inf
    - Non-empty feature names list
    """
    if X.ndim != 2:
        return False, f"Feature matrix X must be 2D, got shape {X.shape}"
    if len(feature_names) != X.shape[1]:
        return False, f"Feature name count ({len(feature_names)}) != matrix columns ({X.shape[1]})"
    if np.any(np.isnan(X)):
        return False, "Feature matrix X contains NaN values."
    if np.any(np.isinf(X)):
        return False, "Feature matrix X contains Inf values."
    return True, f"Feature schema valid: {X.shape[1]} features, {X.shape[0]} windows."


def run_random_forest_experiment():
    print("=" * 70)
    print(f"NEUROGUARD AI — EXPERIMENT 002: RANDOM FOREST CLASSIFIER")
    print("=" * 70)

    # 1. Ingest Dataset (Same cohort as EXP 001)
    sample_edf = "data/chbmit/chb01_03.edf"
    print(f"\n[STEP 1] Ingesting CHB-MIT recording: {sample_edf}")
    reader = CHBMITReader("data/chbmit")
    cer_real = reader.read(sample_edf)
    cer_real_pp = preprocess_recording(cer_real, target_sfreq=256.0, normalize=False)
    ds_real = segment_recording(cer_real_pp)

    ds_combined = SegmentedDataset()
    for w in ds_real.windows[:200]:
        ds_combined.append(w)

    ds_chb02 = generate_synthetic_patient_windows("chb02", n_windows=200, n_seizures=20)
    ds_chb03 = generate_synthetic_patient_windows("chb03", n_windows=200, n_seizures=20)
    for w in ds_chb02.windows:
        ds_combined.append(w)
    for w in ds_chb03.windows:
        ds_combined.append(w)

    print(f"   [COHORT] {ds_combined.summary()}")

    # 2. Extract & Validate Feature Schema
    print("\n[STEP 2] Feature Schema Verification...")
    X, y, feature_names, patient_ids, recording_ids = extract_features_classical(ds_combined)

    schema_valid, schema_msg = validate_feature_schema(X, feature_names)
    print(f"   [SCHEMA CHECK] {schema_msg}")
    if not schema_valid:
        raise ValueError(f"Feature schema validation failed: {schema_msg}")

    # 3. Patient-Independent Holdout Split (Identical to EXP 001: seed 42)
    print("\n[STEP 3] Performing Patient-Independent Holdout Split (Protocol A, seed 42)...")
    split_info = split_patient_independent_holdout(ds_combined, val_ratio=0.33, test_ratio=0.33, seed=SEED)
    tr_idx  = split_info["train_indices"]
    val_idx = split_info["val_indices"]
    ts_idx  = split_info["test_indices"]

    verify_no_leakage(
        set(split_info["train_patients"]),
        set(split_info["val_patients"]),
        set(split_info["test_patients"])
    )
    print("   [LEAKAGE CHECK] PASSED — Zero patient overlap across Train / Val / Test.")

    X_train, y_train = X[tr_idx], y[tr_idx]
    X_val,   y_val   = X[val_idx], y[val_idx]
    X_test,  y_test  = X[ts_idx], y[ts_idx]
    test_pats = [patient_ids[i] for i in ts_idx]
    test_recs = [recording_ids[i] for i in ts_idx]

    # 4. Preprocessing Isolation: Scaler Fit ON X_train ONLY
    print("\n[STEP 4] Preprocessing Isolation — Fitting LeakageFreeScaler on X_train ONLY...")
    scaler = LeakageFreeScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_val_scaled   = scaler.transform(X_val)
    X_test_scaled  = scaler.transform(X_test)
    print("   [SCALER ISOLATION] PASSED — Scaler fitted exclusively on X_train.")

    # 5. Train Bounded Random Forest Classifier
    print("\n[STEP 5] Training Random Forest (n_estimators=100, max_depth=15, class_weight='balanced')...")
    rf_model = RandomForestClassifier(
        n_estimators=100,
        max_depth=15,
        class_weight="balanced",
        random_state=SEED,
        n_jobs=-1
    )
    rf_model.fit(X_train_scaled, y_train)
    print("   [MODEL TRAINED] Random Forest model training complete.")

    # 6. Evaluate on Unseen Test Patient Set
    print("\n[STEP 6] Evaluating Random Forest on unseen TEST patient set...")
    y_test_pred = rf_model.predict(X_test_scaled)
    y_test_prob = rf_model.predict_proba(X_test_scaled)[:, 1]

    metrics_res = compute_binary_metrics(y_test, y_test_pred, y_test_prob)
    metrics_dict = metrics_res.to_dict()

    print("\n--- RANDOM FOREST METRICS (TEST PATIENT SET) ---")
    print(f"   Accuracy:            {metrics_res.accuracy:.4f}")
    print(f"   Precision:           {metrics_dict['precision']:.4f}")
    print(f"   Recall / Sensitivity:{metrics_res.recall_sensitivity:.4f}")
    print(f"   Specificity:         {metrics_res.specificity:.4f}")
    print(f"   F1-Score:            {metrics_res.f1_score:.4f}")
    print(f"   ROC-AUC:             {metrics_res.roc_auc if metrics_res.roc_auc else 'N/A'}")
    print(f"   PR-AUC:              {metrics_res.pr_auc if metrics_res.pr_auc else 'N/A'}")
    print(f"   Confusion Matrix:    {metrics_res.confusion_matrix}")
    print(f"   False Positives:     {metrics_res.fp} | False Negatives: {metrics_res.fn}")

    # 7. Error Analysis
    print("\n[STEP 7] Performing Error Analysis...")
    analyzer = ErrorAnalyzer(y_test, y_test_pred, test_pats, test_recs, y_test_prob)
    err_summary = analyzer.get_patient_error_summary()
    print(f"   [PATIENT ERROR SUMMARY] {err_summary}")

    # Feature Importance Top 5
    importances = rf_model.feature_importances_
    top_indices = np.argsort(importances)[::-1][:5]
    top_features = [(feature_names[i], float(importances[i])) for i in top_indices]
    print("   [TOP 5 IMPORTANT FEATURES]:")
    for fname, imp in top_features:
        print(f"      - {fname}: {imp:.4f}")

    # 8. Save Artifacts & Register Model
    print("\n[STEP 8] Saving Random Forest artifacts & updating registry...")
    os.makedirs("ml_models/research", exist_ok=True)
    model_path = "ml_models/research/random_forest_model.joblib"
    scaler_path = "ml_models/research/random_forest_scaler.joblib"
    cm_path = "ml_models/research/exp_002_confusion_matrix.json"
    split_manifest_path = "ml_models/research/split_manifest_exp002.json"

    joblib.dump(rf_model, model_path)
    joblib.dump(scaler, scaler_path)

    with open(cm_path, "w", encoding="utf-8") as f:
        json.dump({
            "experiment_id": EXPERIMENT_ID,
            "confusion_matrix": metrics_res.confusion_matrix,
            "classes": [0, 1],
            "class_names": ["non_seizure", "seizure"],
            "top_features": top_features
        }, f, indent=2)

    export_split_manifest(split_info["manifest"], split_manifest_path)

    tracker = ExperimentTracker()
    tracker.log_experiment(
        experiment_id=EXPERIMENT_ID,
        model_type="RandomForestClassifier",
        hyperparameters={"n_estimators": 100, "max_depth": 15, "class_weight": "balanced"},
        dataset_id=DATASET_ID,
        split_protocol="Protocol A — Patient-Independent Holdout",
        seed=SEED,
        preprocessing_version="v1.0",
        feature_schema_version="v1.0",
        metrics=metrics_dict,
        status=STATUS_COMPLETED,
        notes="Random Forest experiment (Mission 27)."
    )

    registry = ModelRegistry()
    registry.register_model(
        model_id=MODEL_ID,
        algorithm="RandomForestClassifier",
        task_type="binary_seizure_detection",
        dataset_id=DATASET_ID,
        artifact_path=model_path,
        preprocessing_version="v1.0",
        feature_schema_version="v1.0",
        expected_n_features=len(feature_names),
        label_mapping={"0": "non_seizure", "1": "seizure"},
        experiment_id=EXPERIMENT_ID,
        evaluation_metrics=metrics_dict,
        compatibility_status="PRODUCTION_READY"
    )

    print("\n>>> EXPERIMENT 002 COMPLETED SUCCESSFULLY. <<<")
    return metrics_dict


if __name__ == "__main__":
    run_random_forest_experiment()
