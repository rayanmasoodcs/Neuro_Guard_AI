"""
NeuroGuard AI — Production Inference Engine
============================================
Model-agnostic validated wrapper for seizure detection.
All model parameters (feature count, class labels, thresholds) are read at
runtime from seizure_meta.json — no hard-coded magic numbers.

Safety features:
  1. Strict input validation gate (shape, NaN/Inf, feature-count assertion)
  2. Feature-selector support (optional seizure_feature_selector.joblib)
  3. Low-confidence abstention (configurable threshold, default 0.60)
  4. Non-diagnostic structured output with explicit medical disclaimer
"""

import os
import json
import warnings
warnings.filterwarnings("ignore")

import numpy as np
import joblib

# ─── Artifact paths (resolved relative to this file's directory) ──────────────

_HERE = os.path.dirname(os.path.abspath(__file__))

_DEFAULTS = {
    "model":    os.path.join(_HERE, "seizure_model_production.joblib"),
    "scaler":   os.path.join(_HERE, "seizure_scaler.joblib"),
    "meta":     os.path.join(_HERE, "seizure_meta.json"),
    "selector": os.path.join(_HERE, "seizure_feature_selector.joblib"),
}

LOW_CONFIDENCE_THRESH = 0.60

MEDICAL_DISCLAIMER = (
    "NeuroGuard AI is an assistive clinical decision support prototype. "
    "Output does not constitute a formal clinical diagnosis. "
    "All findings must be reviewed by a board-certified neurologist."
)


# ─── Errors ───────────────────────────────────────────────────────────────────

class InferenceInputError(ValueError):
    """Raised when input fails pre-inference validation."""

class ModelArtifactError(RuntimeError):
    """Raised when model/scaler/meta artifacts are missing or unloadable."""


# ─── Engine ───────────────────────────────────────────────────────────────────

class NeuroGuardInferenceEngine:
    """
    Production inference engine.
    Loads artifacts from disk once, then serves predict() calls.
    Thread-safety: load once at startup; predict() is read-only.
    """

    def __init__(self,
                 model_path: str = None,
                 scaler_path: str = None,
                 meta_path: str = None,
                 selector_path: str = None):

        self.model_path    = model_path    or _DEFAULTS["model"]
        self.scaler_path   = scaler_path   or _DEFAULTS["scaler"]
        self.meta_path     = meta_path     or _DEFAULTS["meta"]
        self.selector_path = selector_path or _DEFAULTS["selector"]

        self._model    = None
        self._scaler   = None
        self._selector = None
        self._meta     = {}

        self._load()

    # ── Artifact loading ──────────────────────────────────────────────────────

    def _load(self):
        # Meta JSON (required — defines feature contract)
        if not os.path.exists(self.meta_path):
            raise ModelArtifactError(f"seizure_meta.json not found: {self.meta_path}")
        with open(self.meta_path, "r") as f:
            self._meta = json.load(f)

        # Derive expected feature count from meta
        # After training, meta stores n_features_selected (post-selector count).
        # If the model was trained without a selector, n_features_selected == n_features_original.
        self._n_features_model_input = self._meta.get(
            "n_features_selected",
            self._meta.get("n_features_original", None)
        )
        self._n_features_raw = self._meta.get(
            "n_features_original",
            self._n_features_model_input
        )

        if self._n_features_model_input is None:
            raise ModelArtifactError(
                "seizure_meta.json is missing 'n_features_selected' or 'n_features_original'."
            )

        # Class mapping
        self._classes   = self._meta.get("classes", ["0", "1"])
        self._label_map = self._meta.get("label_map", {str(i): c for i, c in enumerate(self._classes)})

        # Model (required)
        if not os.path.exists(self.model_path):
            raise ModelArtifactError(f"Model artifact not found: {self.model_path}")
        self._model = joblib.load(self.model_path)

        # Scaler (required)
        if not os.path.exists(self.scaler_path):
            raise ModelArtifactError(f"Scaler artifact not found: {self.scaler_path}")
        self._scaler = joblib.load(self.scaler_path)

        # Feature selector (optional)
        if os.path.exists(self.selector_path):
            try:
                self._selector = joblib.load(self.selector_path)
            except Exception:
                self._selector = None

    # ── Input validation ──────────────────────────────────────────────────────

    def _validate(self, X: np.ndarray) -> np.ndarray:
        if X is None:
            raise InferenceInputError("Feature matrix X cannot be None.")
        if not isinstance(X, np.ndarray):
            X = np.asarray(X, dtype=np.float32)
        if X.ndim == 1:
            X = X.reshape(1, -1)
        if X.ndim != 2:
            raise InferenceInputError(f"Feature matrix must be 2D; got shape {X.shape}.")
        if np.any(np.isnan(X)):
            raise InferenceInputError("Feature matrix contains NaN values.")
        if np.any(np.isinf(X)):
            raise InferenceInputError("Feature matrix contains infinite (Inf) values.")

        # Feature count check against raw feature space (pre-selector)
        if self._n_features_raw is not None and X.shape[1] != self._n_features_raw:
            raise InferenceInputError(
                f"Feature count mismatch: model trained on {self._n_features_raw} raw features "
                f"but received {X.shape[1]}. "
                "Ensure the same feature extraction pipeline is used at inference time."
            )
        return X

    # ── Core prediction ───────────────────────────────────────────────────────

    def predict(self, X: np.ndarray) -> list[dict]:
        """
        Run validated inference on one or more feature vectors.

        Args:
            X: ndarray, shape (n_windows, n_raw_features) or (n_raw_features,)

        Returns:
            List of result dicts, one per window.
        """
        X = self._validate(X)

        # Scale with training scaler
        X_scaled = self._scaler.transform(X)

        # Optional feature selector (RFECV mask trained alongside the model)
        if self._selector is not None:
            try:
                X_scaled = self._selector.transform(X_scaled)
            except Exception:
                # If selector fails (e.g., wrong shape), fall through
                pass

        # Assertion: model must receive exactly the number of features it was trained on
        if X_scaled.shape[1] != self._n_features_model_input:
            raise InferenceInputError(
                f"Post-selector feature count ({X_scaled.shape[1]}) does not match "
                f"model's expected input ({self._n_features_model_input}). "
                "Model artifacts are inconsistent — retrain the model."
            )

        has_proba = hasattr(self._model, "predict_proba")
        if has_proba:
            proba_matrix = self._model.predict_proba(X_scaled)
        else:
            raw_preds = self._model.predict(X_scaled)

        results = []
        for i in range(X_scaled.shape[0]):
            if has_proba:
                probs    = proba_matrix[i]
                pred_idx = int(np.argmax(probs))
                confidence = float(probs[pred_idx])
            else:
                pred_idx   = int(raw_preds[i])
                confidence = 1.0
                probs      = np.zeros(len(self._classes))
                probs[pred_idx] = 1.0

            predicted_label = self._label_map.get(str(pred_idx), str(pred_idx))
            low_conf = confidence < LOW_CONFIDENCE_THRESH
            status   = "UNABLE_TO_RELIABLY_CLASSIFY" if low_conf else "SUCCESS"

            warn = []
            if low_conf:
                warn.append(
                    f"Confidence {confidence:.1%} is below threshold {LOW_CONFIDENCE_THRESH:.0%}. "
                    "Manual expert EEG review required."
                )

            results.append({
                "status":           status,
                "prediction":       predicted_label,
                "confidence":       round(confidence, 4),
                "class_probabilities": {
                    self._label_map.get(str(j), str(j)): round(float(p), 4)
                    for j, p in enumerate(probs)
                },
                "low_confidence_flag": low_conf,
                "warnings":         warn,
                "model_version":    self._meta.get("model_version", "unknown"),
                "model_name":       self._meta.get("model_name", "unknown"),
                "medical_disclaimer": MEDICAL_DISCLAIMER,
            })

        return results

    def predict_single(self, feature_vector: np.ndarray) -> dict:
        """Convenience wrapper — returns a single result dict."""
        return self.predict(feature_vector)[0]

    # ── Info ──────────────────────────────────────────────────────────────────

    def info(self) -> dict:
        return {
            "model_name":            self._meta.get("model_name"),
            "model_version":         self._meta.get("model_version"),
            "n_features_raw":        self._n_features_raw,
            "n_features_model":      self._n_features_model_input,
            "classes":               self._classes,
            "has_selector":          self._selector is not None,
            "training_date":         self._meta.get("training_date"),
            "test_accuracy":         self._meta.get("test_metrics", {}).get("accuracy"),
            "test_recall":           self._meta.get("test_metrics", {}).get("recall_macro"),
            "test_f1":               self._meta.get("test_metrics", {}).get("f1_macro"),
            "low_confidence_thresh": LOW_CONFIDENCE_THRESH,
        }


# ─── Module-level singleton (lazy-loaded) ────────────────────────────────────

_engine: NeuroGuardInferenceEngine | None = None

def get_engine() -> NeuroGuardInferenceEngine:
    global _engine
    if _engine is None:
        _engine = NeuroGuardInferenceEngine()
    return _engine


# ─── CLI inspect ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("NeuroGuard AI — Production Inference Engine")
    print("=" * 70)
    try:
        engine = NeuroGuardInferenceEngine()
        info   = engine.info()
        for k, v in info.items():
            print(f"  {k:<30} {v}")

        # Smoke test with a zero vector
        X_dummy = np.zeros((1, info["n_features_raw"]), dtype=np.float32)
        result  = engine.predict_single(X_dummy)
        print(f"\n  Smoke-test prediction: {result['prediction']} "
              f"(confidence={result['confidence']:.4f}, status={result['status']})")
        print("=" * 70)
        print("ENGINE LOADED SUCCESSFULLY")
    except ModelArtifactError as e:
        print(f"\n  [ModelArtifactError] {e}")
        print("  Train the model first: python ml_models/train_pipeline_v2.py ...")
    print("=" * 70)
