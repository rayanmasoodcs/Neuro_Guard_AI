"""
NeuroGuard AI — Mission 25: Evaluation Framework & Experiment Tracking Verification Suite
================================================================------------------------
Tests binary/multiclass metrics, confusion matrices, error analysis, uncertainty flags,
experiment logging, and model registry compatibility.
No model training occurs.
"""

import sys
import os
import json
import numpy as np

sys.path.insert(0, os.path.abspath("."))

from ml_models.research.evaluation import (
    compute_binary_metrics, compute_multiclass_metrics,
    ErrorAnalyzer, UncertaintyEvaluator,
    STATUS_NOT_RUN, STATUS_FAILED, STATUS_COMPLETED
)
from ml_models.research.registry import ExperimentTracker, ModelRegistry

results = []

def record(name, passed, detail=""):
    mark = "[PASS]" if passed else "[FAIL]"
    print(f"  {mark} {name} {detail}")
    results.append((name, passed, detail))

print("=" * 65)
print("NEUROGUARD AI — MISSION 25 EVALUATION & REGISTRY TEST SUITE")
print("=" * 65)

# ---------------------------------------------------------------
# TEST 1: Binary Metrics Computation
# ---------------------------------------------------------------
print("\n--- TEST 1: Binary Metrics Computation ---")
try:
    y_true = np.array([0, 0, 0, 0, 1, 1, 1, 1])
    y_pred = np.array([0, 0, 0, 1, 0, 1, 1, 1])
    y_prob = np.array([0.1, 0.2, 0.3, 0.7, 0.4, 0.8, 0.9, 0.95])

    res = compute_binary_metrics(y_true, y_pred, y_prob)

    record("Accuracy calculated", res.accuracy == 0.75, f"acc={res.accuracy}")
    record("TP count correct", res.tp == 3)
    record("FP count correct", res.fp == 1)
    record("TN count correct", res.tn == 3)
    record("FN count correct", res.fn == 1)
    record("Sensitivity/Recall correct", abs(res.recall_sensitivity - 0.75) < 1e-4)
    record("Specificity correct", abs(res.specificity - 0.75) < 1e-4)
    record("ROC-AUC calculated", res.roc_auc is not None and res.roc_auc > 0.5, f"auc={res.roc_auc}")
    record("PR-AUC calculated", res.pr_auc is not None and res.pr_auc > 0.5, f"pr_auc={res.pr_auc}")
    record("Confusion matrix shape 2x2", np.array(res.confusion_matrix).shape == (2, 2))
    record("Status is STATUS_COMPLETED", res.status == STATUS_COMPLETED)
except Exception as e:
    record("Binary metrics computation", False, str(e))

# ---------------------------------------------------------------
# TEST 2: Multiclass Metrics Computation
# ---------------------------------------------------------------
print("\n--- TEST 2: Multiclass Metrics Computation ---")
try:
    mc_true = np.array([0, 1, 2, 0, 1, 2])
    mc_pred = np.array([0, 1, 2, 0, 2, 2])

    mc_res = compute_multiclass_metrics(mc_true, mc_pred, class_names=["A", "B", "C"])
    record("Accuracy calculated", abs(mc_res["accuracy"] - 5/6) < 1e-4)
    record("Macro F1 calculated", mc_res["macro_f1"] > 0)
    record("Confusion matrix 3x3", np.array(mc_res["confusion_matrix"]).shape == (3, 3))
    record("Class report contains class B", "B" in mc_res["class_report"])
except Exception as e:
    record("Multiclass metrics computation", False, str(e))

# ---------------------------------------------------------------
# TEST 3: Error Analysis Structure
# ---------------------------------------------------------------
print("\n--- TEST 3: Error Analysis Structure ---")
try:
    y_t = np.array([0, 0, 1, 1])
    y_p = np.array([0, 1, 0, 1])
    pats = ["chb01", "chb01", "chb02", "chb02"]
    recs = ["chb01_01", "chb01_01", "chb02_01", "chb02_01"]
    probs = np.array([0.1, 0.6, 0.4, 0.9])

    analyzer = ErrorAnalyzer(y_t, y_p, pats, recs, probs)
    summary = analyzer.get_patient_error_summary()
    err_list = analyzer.get_detailed_error_list()

    record("FP indices detected", len(analyzer.fp_indices) == 1 and analyzer.fp_indices[0] == 1)
    record("FN indices detected", len(analyzer.fn_indices) == 1 and analyzer.fn_indices[0] == 2)
    record("Patient summary has chb01 FP count == 1", summary["chb01"]["fp_count"] == 1)
    record("Patient summary has chb02 FN count == 1", summary["chb02"]["fn_count"] == 1)
    record("Detailed error list length == 2", len(err_list) == 2)
except Exception as e:
    record("Error analysis structure", False, str(e))

# ---------------------------------------------------------------
# TEST 4: Uncertainty & Low-Confidence Abstain
# ---------------------------------------------------------------
print("\n--- TEST 4: Uncertainty & Low-Confidence Abstain ---")
try:
    probs = np.array([0.05, 0.45, 0.55, 0.95])
    evaluator = UncertaintyEvaluator(confidence_threshold=0.5, low_confidence_margin=0.15)
    unc_res = evaluator.evaluate_probabilities(probs)

    record("Total predictions == 4", unc_res["total_predictions"] == 4)
    record("High confidence seizure == 1", unc_res["high_confidence_seizure"] == 1)
    record("High confidence non-seizure == 1", unc_res["high_confidence_non_seizure"] == 1)
    record("Uncertain abstain count == 2", unc_res["uncertain_abstain_count"] == 2)
    record("Abstain ratio == 0.5", unc_res["abstain_ratio"] == 0.5)
    record("Uncertain predictions marked as is_certain=False", unc_res["predictions"][1]["is_certain"] is False)
except Exception as e:
    record("Uncertainty evaluator", False, str(e))

# ---------------------------------------------------------------
# TEST 5: Experiment Tracking & Non-Overwriting Log
# ---------------------------------------------------------------
print("\n--- TEST 5: Experiment Tracker ---")
try:
    tmp_exp_log = "ml_models/research/test_experiments.json"
    tracker = ExperimentTracker(tmp_exp_log)

    r1 = tracker.log_experiment(
        experiment_id="EXP_TEST_001",
        model_type="RandomForest",
        hyperparameters={"n_estimators": 100},
        dataset_id="chbmit",
        split_protocol="Protocol A Holdout",
        metrics={"accuracy": 0.88, "auroc": 0.92}
    )
    r2 = tracker.log_experiment(
        experiment_id="EXP_TEST_002",
        model_type="LightGBM",
        hyperparameters={"num_leaves": 31},
        dataset_id="chbmit",
        split_protocol="Protocol A Holdout",
        metrics={"accuracy": 0.90, "auroc": 0.94}
    )

    exps = tracker.list_experiments()
    record("Logged 2 distinct experiments", len(exps) == 2)
    record("EXP_TEST_001 retrieved correctly", tracker.get_experiment("EXP_TEST_001")["model_type"] == "RandomForest")
    record("Status is STATUS_COMPLETED", r1["status"] == STATUS_COMPLETED)

    if os.path.exists(tmp_exp_log):
        os.unlink(tmp_exp_log)
except Exception as e:
    record("Experiment tracker", False, str(e))

# ---------------------------------------------------------------
# TEST 6: Model Registry & Compatibility Check
# ---------------------------------------------------------------
print("\n--- TEST 6: Model Registry & Compatibility Validation ---")
try:
    tmp_reg_log = "ml_models/research/test_model_registry.json"
    registry = ModelRegistry(tmp_reg_log)

    reg_entry = registry.register_model(
        model_id="MODEL_RF_V1",
        algorithm="RandomForestClassifier",
        task_type="binary_seizure_detection",
        dataset_id="chbmit",
        artifact_path="ml_models/research/rf_v1.joblib",
        preprocessing_version="v1.0",
        feature_schema_version="v1.0",
        expected_n_features=38,
        label_mapping={"0": "non_seizure", "1": "seizure"},
        experiment_id="EXP_TEST_001",
        evaluation_metrics={"auroc": 0.92, "f1_score": 0.85},
        compatibility_status="PRODUCTION_READY"
    )

    record("Model registered in registry", registry.get_model("MODEL_RF_V1") is not None)

    # Validate correct compatibility
    valid, msg = registry.validate_model_compatibility("MODEL_RF_V1", input_feature_count=38, input_pp_version="v1.0")
    record("Valid compatibility check passes", valid is True, msg)

    # Validate feature count mismatch rejection
    invalid_feat, msg_f = registry.validate_model_compatibility("MODEL_RF_V1", input_feature_count=14, input_pp_version="v1.0")
    record("Feature count mismatch rejected", invalid_feat is False, msg_f)

    # Validate preprocessing version mismatch rejection
    invalid_pp, msg_p = registry.validate_model_compatibility("MODEL_RF_V1", input_feature_count=38, input_pp_version="v0.9")
    record("Preprocessing version mismatch rejected", invalid_pp is False, msg_p)

    if os.path.exists(tmp_reg_log):
        os.unlink(tmp_reg_log)
except Exception as e:
    record("Model registry & compatibility validation", False, str(e))

# ---------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------
print("\n" + "=" * 65)
total = len(results)
passed = sum(1 for _, p, _ in results if p)
failed = total - passed
print(f"TOTAL: {total}  PASSED: {passed}  FAILED: {failed}")
print("=" * 65)

if failed > 0:
    print("\nFAILED TESTS:")
    for name, p, detail in results:
        if not p:
            print(f"  FAIL: {name}: {detail}")
    sys.exit(1)
else:
    print("\n>>> ALL EVALUATION & REGISTRY TESTS PASSED. MISSION 25 COMPLETE. <<<")
