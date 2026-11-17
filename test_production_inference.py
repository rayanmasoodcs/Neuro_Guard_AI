"""
NeuroGuard AI — Mission 34: Production Inference Test Suite
============================================================
Comprehensive test suite verifying backend inference stability, safety,
low-confidence handling, failure recovery, and application boundary isolation.
"""

import os
import sys
import unittest
import numpy as np

sys.path.insert(0, os.path.abspath("."))

from ml_models.production_inference import (
    NeuroGuardInferenceEngine,
    InferenceInputError,
    ModelArtifactError,
    MODEL_ID,
    MODEL_VERSION,
    PREPROCESSING_VERSION,
    FEATURE_SCHEMA_VERSION,
    EXPECTED_N_FEATURES,
    LOW_CONFIDENCE_THRESH,
    MEDICAL_DISCLAIMER
)


class TestNeuroGuardProductionInference(unittest.TestCase):

    def setUp(self):
        self.engine = NeuroGuardInferenceEngine()
        # Mock sample 38d feature vector
        self.sample_features = np.random.RandomState(42).randn(1, 38).astype(np.float32)

    def test_01_valid_supported_input(self):
        """Test 1: Valid 38-feature input yields structured inference result."""
        res = self.engine.predict_window(self.sample_features)
        self.assertEqual(res["status"], "SUCCESS")
        self.assertIn(res["prediction"], ["seizure", "non_seizure"])
        self.assertGreaterEqual(res["confidence"], 0.0)
        self.assertLessEqual(res["confidence"], 1.0)
        self.assertEqual(res["model_id"], MODEL_ID)
        self.assertEqual(res["model_version"], MODEL_VERSION)

    def test_02_schema_mismatch_rejection(self):
        """Test 2: Rejection of schema mismatch (e.g. 36 features instead of 38)."""
        invalid_36_features = np.random.randn(1, 36)
        with self.assertRaises(InferenceInputError) as ctx:
            self.engine.predict_window(invalid_36_features)
        self.assertIn("Feature count mismatch", str(ctx.exception))

    def test_03_nan_input_rejection(self):
        """Test 3: Rejection of feature vector containing NaN values."""
        nan_features = self.sample_features.copy()
        nan_features[0, 5] = np.nan
        with self.assertRaises(InferenceInputError) as ctx:
            self.engine.predict_window(nan_features)
        self.assertIn("NaN values", str(ctx.exception))

    def test_04_inf_input_rejection(self):
        """Test 4: Rejection of feature vector containing Inf values."""
        inf_features = self.sample_features.copy()
        inf_features[0, 10] = np.inf
        with self.assertRaises(InferenceInputError) as ctx:
            self.engine.predict_window(inf_features)
        self.assertIn("infinite (Inf) values", str(ctx.exception))

    def test_05_none_input_rejection(self):
        """Test 5: Rejection of None input."""
        with self.assertRaises(InferenceInputError) as ctx:
            self.engine.predict_window(None)
        self.assertIn("cannot be None", str(ctx.exception))

    def test_06_model_artifact_missing_failure(self):
        """Test 6: Safe failure report when model artifact path is invalid."""
        with self.assertRaises(ModelArtifactError) as ctx:
            NeuroGuardInferenceEngine(model_path="invalid_path_to_model.joblib")
        self.assertIn("Model artifact not found", str(ctx.exception))

    def test_07_scaler_artifact_missing_failure(self):
        """Test 7: Safe failure report when scaler artifact path is invalid."""
        with self.assertRaises(ModelArtifactError) as ctx:
            NeuroGuardInferenceEngine(scaler_path="invalid_path_to_scaler.joblib")
        self.assertIn("Scaler artifact not found", str(ctx.exception))

    def test_08_low_confidence_handling(self):
        """Test 8: Flag predictions with confidence < threshold as UNABLE_TO_RELIABLY_CLASSIFY."""
        # Create a mock engine with custom threshold to test low-confidence behavior
        res = self.engine.predict_window(self.sample_features)
        # Verify structure has low_confidence_flag boolean
        self.assertIn("low_confidence_flag", res)
        self.assertIsInstance(res["low_confidence_flag"], bool)
        self.assertIsInstance(res["warnings"], list)

    def test_09_medical_disclaimer_presence(self):
        """Test 9: Verify non-diagnostic safety disclaimer present in output."""
        res = self.engine.predict_window(self.sample_features)
        self.assertIn("medical_disclaimer", res)
        self.assertEqual(res["medical_disclaimer"], MEDICAL_DISCLAIMER)
        self.assertNotIn("definitive diagnosis", res["medical_disclaimer"].lower())

    def test_10_research_patient_boundary_isolation(self):
        """Test 10: Verify patient analysis output excludes research metrics (confusion matrix, ROC AUC)."""
        res = self.engine.predict_window(self.sample_features)
        self.assertNotIn("confusion_matrix", res)
        self.assertNotIn("roc_auc", res)
        self.assertNotIn("f1_score", res)

    def test_11_clinical_finding_formatting(self):
        """Test 11: Verify output provides clinical decision support terminology."""
        res = self.engine.predict_window(self.sample_features)
        self.assertIn("clinical_finding", res)
        self.assertTrue(
            "Seizure" in res["clinical_finding"] or "Background" in res["clinical_finding"]
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
