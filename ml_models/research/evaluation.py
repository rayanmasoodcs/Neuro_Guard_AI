"""
NeuroGuard AI Research Pipeline — Evaluation & Metrics Module
==============================================================
Provides comprehensive, clinically and scientifically relevant evaluation
metrics, confusion matrix generation, uncertainty analysis, and error tracking.

Core Principles:
----------------
1. Beyond Accuracy: Imbalance makes accuracy alone deceptive. Always compute
   Sensitivity, Specificity, F1-score, AUROC, AUPRC, FP count, FN count, FPR, FNR.
2. Error Traceability: Track specific patient IDs and recording IDs associated
   with False Positives and False Negatives.
3. Uncertainty & Abstain: Support prediction confidence thresholding and low-confidence
   abstain flags to prevent uncertain predictions from being presented as certainty.
4. Experiment Status Guard: Explicitly report 'EXPERIMENT_NOT_RUN', 'EXPERIMENT_FAILED',
   or 'EXPERIMENT_COMPLETED'.
"""

import numpy as np
import math
from typing import Dict, List, Tuple, Optional, Any
from dataclasses import dataclass, asdict
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, roc_auc_score, precision_recall_curve,
    auc, roc_curve, classification_report
)

STATUS_NOT_RUN    = "EXPERIMENT_NOT_RUN"
STATUS_FAILED     = "EXPERIMENT_FAILED"
STATUS_COMPLETED  = "EXPERIMENT_COMPLETED"


@dataclass
class BinaryMetricsResult:
    accuracy:            float
    precision:           float
    recall_sensitivity:  float
    specificity:         float
    f1_score:            float
    tp:                  int
    fp:                  int
    tn:                  int
    fn:                  int
    fpr:                 float
    fnr:                 float
    roc_auc:             Optional[float]
    pr_auc:              Optional[float]
    confusion_matrix:    List[List[int]]
    low_confidence_count: int
    abstain_rate:        float
    status:              str = STATUS_COMPLETED

    def to_dict(self) -> dict:
        return asdict(self)


def compute_binary_metrics(y_true: np.ndarray,
                           y_pred: np.ndarray,
                           y_prob: Optional[np.ndarray] = None,
                           confidence_threshold: float = 0.5,
                           low_confidence_margin: float = 0.15) -> BinaryMetricsResult:
    """
    Computes comprehensive binary classification metrics.

    Args:
        y_true:                Ground truth binary labels (0 or 1)
        y_pred:                Predicted binary labels (0 or 1)
        y_prob:                Optional continuous probabilities for class 1
        confidence_threshold:  Threshold for binary classification (default 0.5)
        low_confidence_margin: Margin around threshold for low-confidence flag
                               (e.g., probabilities between 0.35 and 0.65 are flagged)
    """
    y_true = np.asarray(y_true, dtype=int)
    y_pred = np.asarray(y_pred, dtype=int)

    if len(y_true) == 0:
        raise ValueError("Cannot compute metrics on empty arrays.")

    acc  = float(accuracy_score(y_true, y_pred))
    prec = float(precision_score(y_true, y_pred, zero_division=0))
    rec  = float(recall_score(y_true, y_pred, zero_division=0))
    f1   = float(f1_score(y_true, y_pred, zero_division=0))

    cm = confusion_matrix(y_true, y_pred, labels=[0, 1])
    if cm.shape == (2, 2):
        tn, fp, fn, tp = map(int, cm.ravel())
    else:
        # Edge case: single class present
        tn = int(cm[0, 0]) if y_true[0] == 0 else 0
        tp = int(cm[0, 0]) if y_true[0] == 1 else 0
        fp = fn = 0

    spec = float(tn / (tn + fp)) if (tn + fp) > 0 else 0.0
    fpr  = float(fp / (fp + tn)) if (fp + tn) > 0 else 0.0
    fnr  = float(fn / (fn + tp)) if (fn + tp) > 0 else 0.0

    roc_auc = None
    pr_auc  = None

    if y_prob is not None:
        y_prob = np.asarray(y_prob, dtype=float)
        # Verify both classes exist for AUROC calculation
        if len(np.unique(y_true)) > 1:
            try:
                roc_auc = float(roc_auc_score(y_true, y_prob))
                p_vec, r_vec, _ = precision_recall_curve(y_true, y_prob)
                pr_auc  = float(auc(r_vec, p_vec))
            except Exception:
                pass

    # Low-confidence & abstain calculation
    low_conf_count = 0
    abstain_rate   = 0.0
    if y_prob is not None:
        lower_b = confidence_threshold - low_confidence_margin
        upper_b = confidence_threshold + low_confidence_margin
        low_conf_mask = (y_prob >= lower_b) & (y_prob <= upper_b)
        low_conf_count = int(np.sum(low_conf_mask))
        abstain_rate   = float(low_conf_count / len(y_prob))

    return BinaryMetricsResult(
        accuracy           = acc,
        precision          = prec,
        recall_sensitivity = rec,
        specificity        = spec,
        f1_score           = f1,
        tp                 = tp,
        fp                 = fp,
        tn                 = tn,
        fn                 = fn,
        fpr                = fpr,
        fnr                = fnr,
        roc_auc            = roc_auc,
        pr_auc             = pr_auc,
        confusion_matrix   = cm.tolist(),
        low_confidence_count = low_conf_count,
        abstain_rate       = abstain_rate,
        status             = STATUS_COMPLETED
    )


def compute_multiclass_metrics(y_true: np.ndarray,
                              y_pred: np.ndarray,
                              class_names: Optional[List[str]] = None) -> dict:
    """
    Computes multiclass classification metrics.
    """
    y_true = np.asarray(y_true, dtype=int)
    y_pred = np.asarray(y_pred, dtype=int)

    classes = np.unique(np.concatenate([y_true, y_pred]))
    if class_names is None:
        class_names = [f"Class_{c}" for c in classes]

    cm = confusion_matrix(y_true, y_pred, labels=classes).tolist()
    report = classification_report(y_true, y_pred, target_names=class_names, output_dict=True, zero_division=0)

    return {
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "macro_f1": float(report["macro avg"]["f1-score"]),
        "weighted_f1": float(report["weighted avg"]["f1-score"]),
        "confusion_matrix": cm,
        "class_report": report,
        "classes": [int(c) for c in classes],
        "class_names": class_names,
        "status": STATUS_COMPLETED
    }


class ErrorAnalyzer:
    """
    Analyzes False Positive and False Negative instances by patient ID,
    recording ID, and window indices to expose patient-specific failure patterns.
    """

    def __init__(self, y_true: np.ndarray,
                 y_pred: np.ndarray,
                 patient_ids: List[str],
                 recording_ids: List[str],
                 y_prob: Optional[np.ndarray] = None):
        self.y_true = np.asarray(y_true, dtype=int)
        self.y_pred = np.asarray(y_pred, dtype=int)
        self.patient_ids = patient_ids
        self.recording_ids = recording_ids
        self.y_prob = np.asarray(y_prob, dtype=float) if y_prob is not None else None

        self.fp_indices = np.where((self.y_true == 0) & (self.y_pred == 1))[0]
        self.fn_indices = np.where((self.y_true == 1) & (self.y_pred == 0))[0]

    def get_patient_error_summary(self) -> dict:
        """
        Groups FP and FN errors by patient ID.
        """
        summary = {}
        all_pats = set(self.patient_ids)
        for pid in all_pats:
            summary[pid] = {"fp_count": 0, "fn_count": 0, "total_windows": 0}

        for idx, pid in enumerate(self.patient_ids):
            summary[pid]["total_windows"] += 1

        for idx in self.fp_indices:
            summary[self.patient_ids[idx]]["fp_count"] += 1

        for idx in self.fn_indices:
            summary[self.patient_ids[idx]]["fn_count"] += 1

        return summary

    def get_detailed_error_list(self, limit: int = 100) -> List[dict]:
        """
        Returns detailed list of FP and FN error instances.
        """
        errors = []
        for idx in self.fp_indices[:limit]:
            item = {
                "window_index": int(idx),
                "error_type": "False Positive",
                "patient_id": self.patient_ids[idx],
                "recording_id": self.recording_ids[idx],
                "probability": float(self.y_prob[idx]) if self.y_prob is not None else None
            }
            errors.append(item)

        for idx in self.fn_indices[:limit]:
            item = {
                "window_index": int(idx),
                "error_type": "False Negative",
                "patient_id": self.patient_ids[idx],
                "recording_id": self.recording_ids[idx],
                "probability": float(self.y_prob[idx]) if self.y_prob is not None else None
            }
            errors.append(item)

        return errors


class UncertaintyEvaluator:
    """
    Evaluates prediction confidence, calibrates probabilities, and flags low-confidence predictions.
    Used by application interfaces to prevent presenting uncertain predictions as certain diagnoses.
    """

    def __init__(self, confidence_threshold: float = 0.5,
                 low_confidence_margin: float = 0.15):
        self.confidence_threshold = confidence_threshold
        self.margin = low_confidence_margin

    def evaluate_probabilities(self, y_prob: np.ndarray) -> dict:
        y_prob = np.asarray(y_prob, dtype=float)
        lower_b = self.confidence_threshold - self.margin
        upper_b = self.confidence_threshold + self.margin

        low_conf_mask = (y_prob >= lower_b) & (y_prob <= upper_b)
        high_conf_sz_mask = y_prob > upper_b
        high_conf_nsz_mask = y_prob < lower_b

        # Entropy calculation per probability
        eps = 1e-12
        p_clipped = np.clip(y_prob, eps, 1.0 - eps)
        entropy = - (p_clipped * np.log2(p_clipped) + (1.0 - p_clipped) * np.log2(1.0 - p_clipped))

        predictions = []
        for p in y_prob:
            if p > upper_b:
                predictions.append({"label": 1, "label_str": "seizure", "is_certain": True, "confidence": float(p)})
            elif p < lower_b:
                predictions.append({"label": 0, "label_str": "non_seizure", "is_certain": True, "confidence": float(1.0 - p)})
            else:
                predictions.append({"label": -1, "label_str": "uncertain_abstain", "is_certain": False, "confidence": float(p)})

        return {
            "total_predictions": len(y_prob),
            "high_confidence_seizure": int(np.sum(high_conf_sz_mask)),
            "high_confidence_non_seizure": int(np.sum(high_conf_nsz_mask)),
            "uncertain_abstain_count": int(np.sum(low_conf_mask)),
            "abstain_ratio": float(np.sum(low_conf_mask) / len(y_prob)),
            "mean_entropy": float(np.mean(entropy)),
            "predictions": predictions
        }
