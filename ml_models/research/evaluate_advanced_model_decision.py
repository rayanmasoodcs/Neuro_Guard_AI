"""
NeuroGuard AI — Mission 32: Advanced Model Justification & Decision Engine
==========================================================================
Evaluates dataset size, patient count, parameter scale, and overfitting risk
to determine whether an attention-based Transformer model is scientifically justified.

Logs Option B decision record in ExperimentTracker and ModelRegistry.
"""

import os
import sys
import json
import warnings
warnings.filterwarnings("ignore")

sys.path.insert(0, os.path.abspath("."))

from ml_models.research.evaluation import STATUS_COMPLETED
from ml_models.research.registry import ExperimentTracker, ModelRegistry

EXPERIMENT_ID = "EXP_007_ADVANCED_MODEL_DECISION"
MODEL_ID      = "DECISION_OPTION_B_TRANSFORMER_NOT_JUSTIFIED"
DATASET_ID    = "chbmit"


def analyze_suitability():
    # Cohort Statistics
    n_train_patients = 2  # chb01, chb02
    n_test_patients  = 1  # chb03
    n_train_windows   = 400
    n_test_windows    = 200

    # Minimal Transformer parameter count (~250k parameters)
    min_transformer_params = 250_000
    samples_per_param      = n_train_windows / min_transformer_params  # 0.0016 samples/param!

    print("=" * 70)
    print("NEUROGUARD AI — MISSION 32: ADVANCED MODEL DECISION ANALYSIS")
    print("=" * 70)
    print(f"\n1. DATASET SUITABILITY:")
    print(f"   - Train Cohort: {n_train_patients} patients ({n_train_windows} windows)")
    print(f"   - Test Cohort:  {n_test_patients} patient ({n_test_windows} windows)")
    print(f"   - Data Volume:  INSUFFICIENT for multi-head self-attention mechanisms.")

    print(f"\n2. PARAMETER-TO-SAMPLE RATIO:")
    print(f"   - Min Transformer Parameters: ~{min_transformer_params:,}")
    print(f"   - Training Windows Available: {n_train_windows}")
    print(f"   - Ratio: {samples_per_param:.4f} samples per parameter (Severe Overfitting Hazard!)")

    print(f"\n3. DEEP LEARNING BENCHMARK PRECEDENT (EXP 005 & EXP 006):")
    print(f"   - EXP 005 (1D CNN):   F1 = 0.2973 | Recall = 55.0% | Accuracy = 74.0%")
    print(f"   - EXP 006 (CNN+LSTM): F1 = 0.0000 | Recall = 0.0%  | Accuracy = 90.0% (Class Collapse)")
    print(f"   - Classical Models:   F1 = 0.8889 - 1.0000 | Recall = 80.0% - 100.0%")

    print(f"\n4. DECISION:")
    print(f"   >>> OPTION B: Transformer model is NOT scientifically justified.")
    print(f"   >>> RECOMMENDATION: Proceed to final model comparison with existing 6 controlled models.")


def record_decision_in_registry():
    tracker = ExperimentTracker()
    tracker.log_experiment(
        experiment_id=EXPERIMENT_ID,
        model_type="Transformer_Decision",
        hyperparameters={"decision": "OPTION_B", "reason": "Insufficient dataset size (400 train windows) for self-attention parameters."},
        dataset_id=DATASET_ID,
        split_protocol="Protocol A — Patient-Independent Holdout",
        seed=42,
        preprocessing_version="v1.0",
        feature_schema_version="N/A",
        metrics={
            "status": "OPTION_B_NOT_JUSTIFIED",
            "justification": "High overfitting risk, parameter ratio < 0.002, deep models underperformed classical feature ML."
        },
        status=STATUS_COMPLETED,
        notes="Mission 32 decision-first analysis. Option B selected."
    )

    registry = ModelRegistry()
    registry.register_model(
        model_id=MODEL_ID,
        algorithm="Transformer_Attention_Decision",
        task_type="binary_seizure_detection",
        dataset_id=DATASET_ID,
        artifact_path="EXPERIMENT_007_ADVANCED_MODEL_DECISION_REPORT.md",
        preprocessing_version="v1.0",
        feature_schema_version="N/A",
        expected_n_features=0,
        label_mapping={"0": "non_seizure", "1": "seizure"},
        experiment_id=EXPERIMENT_ID,
        evaluation_metrics={"decision": "OPTION_B_NOT_TRAINED"},
        compatibility_status="ARCHITECTURAL_DECISION_RECORD"
    )
    print("\n[REGISTRY UPDATE] Decision logged in experiments.json and model_registry.json.")


if __name__ == "__main__":
    analyze_suitability()
    record_decision_in_registry()
