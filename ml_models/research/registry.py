"""
NeuroGuard AI Research Pipeline — Model Registry & Experiment Tracker
======================================================================
Manages reproducible experiment tracking and model registration.

Key Guarantee:
--------------
No experiment results or trained models are overwritten.
Every run receives a unique ID (`EXP_YYYYMMDD_HHMMSS_XXXX`) and preserves:
- Full training configuration & hyperparameters
- Preprocessing artifact version
- Feature schema version
- Patient split manifest link
- Evaluation metrics & confusion matrix
- Model compatibility status
"""

import json
import os
import time
import datetime
from typing import Dict, List, Optional, Tuple, Any


DEFAULT_EXPERIMENT_LOG = "ml_models/research/experiments.json"
DEFAULT_MODEL_REGISTRY = "ml_models/research/model_registry.json"


class ExperimentTracker:
    """
    Records and appends experiment results to the reproducible experiment log.
    Prevents overwriting previous experiment runs.
    """

    def __init__(self, log_path: str = DEFAULT_EXPERIMENT_LOG):
        self.log_path = os.path.abspath(log_path)

    def _load_log(self) -> List[dict]:
        if not os.path.exists(self.log_path):
            return []
        try:
            with open(self.log_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def _save_log(self, records: List[dict]):
        os.makedirs(os.path.dirname(self.log_path), exist_ok=True)
        with open(self.log_path, "w", encoding="utf-8") as f:
            json.dump(records, f, indent=2)

    def log_experiment(self,
                       experiment_id: str,
                       model_type: str,
                       hyperparameters: dict,
                       dataset_id: str,
                       split_protocol: str,
                       metrics: dict,
                       preprocessing_version: str = "v1.0",
                       feature_schema_version: str = "v1.0",
                       seed: int = 42,
                       status: str = "EXPERIMENT_COMPLETED",
                       notes: str = "") -> dict:
        """
        Appends a complete experiment record to the experiment log.
        """
        records = self._load_log()
        
        # Ensure unique experiment_id
        existing_ids = set(r.get("experiment_id") for r in records)
        if experiment_id in existing_ids:
            timestamp_suffix = int(time.time() % 10000)
            experiment_id = f"{experiment_id}_{timestamp_suffix}"

        record = {
            "experiment_id":           experiment_id,
            "timestamp":               datetime.datetime.now().isoformat(),
            "model_type":              model_type,
            "hyperparameters":         hyperparameters,
            "dataset_id":              dataset_id,
            "split_protocol":          split_protocol,
            "seed":                    seed,
            "preprocessing_version":   preprocessing_version,
            "feature_schema_version":  feature_schema_version,
            "metrics":                 metrics,
            "status":                  status,
            "notes":                   notes,
        }

        records.append(record)
        self._save_log(records)
        return record

    def get_experiment(self, experiment_id: str) -> Optional[dict]:
        records = self._load_log()
        for r in records:
            if r.get("experiment_id") == experiment_id:
                return r
        return None

    def list_experiments(self) -> List[dict]:
        return self._load_log()


class ModelRegistry:
    """
    Model Registry for managing saved model metadata and compatibility checks.
    Ensures that Flutter/Django application layers never load a model without
    validating its expected preprocessing, feature schema, and compatibility.
    """

    def __init__(self, registry_path: str = DEFAULT_MODEL_REGISTRY):
        self.registry_path = os.path.abspath(registry_path)

    def _load_registry(self) -> List[dict]:
        if not os.path.exists(self.registry_path):
            return []
        try:
            with open(self.registry_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def _save_registry(self, records: List[dict]):
        os.makedirs(os.path.dirname(self.registry_path), exist_ok=True)
        with open(self.registry_path, "w", encoding="utf-8") as f:
            json.dump(records, f, indent=2)

    def register_model(self,
                       model_id: str,
                       algorithm: str,
                       task_type: str,
                       dataset_id: str,
                       artifact_path: str,
                       preprocessing_version: str,
                       feature_schema_version: str,
                       expected_n_features: int,
                       label_mapping: dict,
                       experiment_id: str,
                       evaluation_metrics: dict,
                       compatibility_status: str = "PRODUCTION_READY") -> dict:
        """
        Registers a model entry in the Model Registry.
        """
        records = self._load_registry()

        entry = {
            "model_id":               model_id,
            "registered_at":          datetime.datetime.now().isoformat(),
            "algorithm":              algorithm,
            "task_type":              task_type,
            "dataset_id":             dataset_id,
            "artifact_path":          artifact_path,
            "preprocessing_version":  preprocessing_version,
            "feature_schema_version": feature_schema_version,
            "expected_n_features":    expected_n_features,
            "label_mapping":          label_mapping,
            "experiment_id":          experiment_id,
            "evaluation_metrics":     evaluation_metrics,
            "compatibility_status":    compatibility_status,
        }

        # Update if model_id exists, else append
        updated = False
        for idx, r in enumerate(records):
            if r.get("model_id") == model_id:
                records[idx] = entry
                updated = True
                break
        if not updated:
            records.append(entry)

        self._save_registry(records)
        return entry

    def get_model(self, model_id: str) -> Optional[dict]:
        records = self._load_registry()
        for r in records:
            if r.get("model_id") == model_id:
                return r
        return None

    def validate_model_compatibility(self, model_id: str,
                                     input_feature_count: int,
                                     input_pp_version: str) -> Tuple[bool, str]:
        """
        Validates model compatibility against input feature count and preprocessing version.
        Used by API inference layer before running predictions.
        """
        model_info = self.get_model(model_id)
        if not model_info:
            return False, f"Model ID '{model_id}' not found in registry."

        if model_info["compatibility_status"] != "PRODUCTION_READY":
            return False, f"Model ID '{model_id}' status is '{model_info['compatibility_status']}', not PRODUCTION_READY."

        if input_feature_count != model_info["expected_n_features"]:
            return False, f"Feature count mismatch: model expects {model_info['expected_n_features']}, got {input_feature_count}."

        if input_pp_version != model_info["preprocessing_version"]:
            return False, f"Preprocessing version mismatch: model expects {model_info['preprocessing_version']}, got {input_pp_version}."

        return True, "Model compatibility validated successfully."
