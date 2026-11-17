"""
NeuroGuard AI — Research EEG Pipeline
======================================
Package init for ml_models/research/.
Exposes canonical pipeline components.
"""
from .eeg_io import CHBMITReader, SienaReader, read_eeg_file
from .preprocessing import preprocess_recording
from .segmentation import segment_recording, SegmentedDataset
from .feature_extraction import extract_features_classical, build_raw_windows
from .splitting import (
    DataLeakageError,
    PatientSummary,
    get_patient_inventory,
    verify_no_leakage,
    split_patient_independent_holdout,
    get_group_kfold_splits,
    get_loso_splits,
    LeakageFreeScaler,
    export_split_manifest,
)
from .evaluation import (
    BinaryMetricsResult,
    compute_binary_metrics,
    compute_multiclass_metrics,
    ErrorAnalyzer,
    UncertaintyEvaluator,
    STATUS_NOT_RUN,
    STATUS_FAILED,
    STATUS_COMPLETED,
)
from .registry import ExperimentTracker, ModelRegistry

__all__ = [
    "CHBMITReader",
    "SienaReader",
    "read_eeg_file",
    "preprocess_recording",
    "segment_recording",
    "SegmentedDataset",
    "extract_features_classical",
    "build_raw_windows",
    "DataLeakageError",
    "PatientSummary",
    "get_patient_inventory",
    "verify_no_leakage",
    "split_patient_independent_holdout",
    "get_group_kfold_splits",
    "get_loso_splits",
    "LeakageFreeScaler",
    "export_split_manifest",
    "BinaryMetricsResult",
    "compute_binary_metrics",
    "compute_multiclass_metrics",
    "ErrorAnalyzer",
    "UncertaintyEvaluator",
    "STATUS_NOT_RUN",
    "STATUS_FAILED",
    "STATUS_COMPLETED",
    "ExperimentTracker",
    "ModelRegistry",
]
