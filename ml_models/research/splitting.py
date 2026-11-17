"""
NeuroGuard AI Research Pipeline — Data Splitting & Leakage Prevention Module
==============================================================================
Implements patient-independent splitting strategies and automated leakage
verification checks to guarantee zero patient overlap across train/val/test.

Key Protocols Supported:
-----------------------
- Protocol A: Patient-Independent Train / Validation / Test Holdout
- Protocol B: Patient-Grouped K-Fold Cross-Validation (GroupKFold, 5-fold)
- Protocol C: Leave-One-Subject-Out Cross-Validation (LOSO / LOGO)

Leakage Guards:
---------------
1. Zero Patient Overlap: Patient X can NEVER appear in both training and test/val.
2. Preprocessing Isolation: LeakageFreeScaler fits ONLY on X_train.
3. Automated Verification: Raises DataLeakageError if any overlap is detected.
"""

import json
import os
import datetime
import numpy as np
from typing import Dict, List, Tuple, Set, Optional
from dataclasses import dataclass, asdict
from sklearn.model_selection import GroupKFold, KFold
from sklearn.preprocessing import StandardScaler

from .segmentation import SegmentedDataset, EEGWindow


class DataLeakageError(Exception):
    """Raised when data leakage or patient overlap is detected across splits."""


@dataclass
class PatientSummary:
    patient_id: str
    total_windows: int
    seizure_windows: int
    non_seizure_windows: int
    seizure_ratio: float
    recordings: List[str]


def get_patient_inventory(dataset: SegmentedDataset) -> Dict[str, PatientSummary]:
    """
    Build a patient group inventory mapping:
    Patient ID -> Recordings -> Total Windows -> Class Counts.
    """
    inventory: Dict[str, dict] = {}
    for w in dataset.windows:
        pid = w.patient_id
        if pid not in inventory:
            inventory[pid] = {
                "recordings": set(),
                "total": 0,
                "seizure": 0,
                "non_seizure": 0
            }
        inventory[pid]["recordings"].add(w.recording_id)
        inventory[pid]["total"] += 1
        if w.label == 1:
            inventory[pid]["seizure"] += 1
        else:
            inventory[pid]["non_seizure"] += 1

    summary_map = {}
    for pid, info in inventory.items():
        tot = info["total"]
        sz = info["seizure"]
        nsz = info["non_seizure"]
        ratio = sz / tot if tot > 0 else 0.0
        summary_map[pid] = PatientSummary(
            patient_id=pid,
            total_windows=tot,
            seizure_windows=sz,
            non_seizure_windows=nsz,
            seizure_ratio=float(ratio),
            recordings=sorted(list(info["recordings"]))
        )
    return summary_map


def verify_no_leakage(train_patients: Set[str],
                      val_patients: Set[str],
                      test_patients: Set[str],
                      train_recordings: Optional[Set[str]] = None,
                      val_recordings: Optional[Set[str]] = None,
                      test_recordings: Optional[Set[str]] = None) -> Dict[str, bool]:
    """
    Automated leakage verification check.
    Checks for non-empty intersections between patient sets and recording sets.
    Raises DataLeakageError if any overlap exists.
    """
    train_val_overlap = train_patients.intersection(val_patients)
    train_test_overlap = train_patients.intersection(test_patients)
    val_test_overlap = val_patients.intersection(test_patients)

    if train_val_overlap:
        raise DataLeakageError(f"LEAKAGE DETECTED: Train & Val share patients: {train_val_overlap}")
    if train_test_overlap:
        raise DataLeakageError(f"LEAKAGE DETECTED: Train & Test share patients: {train_test_overlap}")
    if val_test_overlap:
        raise DataLeakageError(f"LEAKAGE DETECTED: Val & Test share patients: {val_test_overlap}")

    rec_checks = {}
    if train_recordings and val_recordings:
        tr_val_rec = train_recordings.intersection(val_recordings)
        if tr_val_rec:
            raise DataLeakageError(f"LEAKAGE DETECTED: Train & Val share recordings: {tr_val_rec}")
        rec_checks["train_val_rec"] = True

    if train_recordings and test_recordings:
        tr_ts_rec = train_recordings.intersection(test_recordings)
        if tr_ts_rec:
            raise DataLeakageError(f"LEAKAGE DETECTED: Train & Test share recordings: {tr_ts_rec}")
        rec_checks["train_test_rec"] = True

    if val_recordings and test_recordings:
        val_ts_rec = val_recordings.intersection(test_recordings)
        if val_ts_rec:
            raise DataLeakageError(f"LEAKAGE DETECTED: Val & Test share recordings: {val_ts_rec}")
        rec_checks["val_test_rec"] = True

    return {
        "train_val_patient_overlap": False,
        "train_test_patient_overlap": False,
        "val_test_patient_overlap": False,
        "recording_overlap": False
    }


def split_patient_independent_holdout(dataset: SegmentedDataset,
                                       val_ratio: float = 0.15,
                                       test_ratio: float = 0.20,
                                       seed: int = 42) -> dict:
    """
    Protocol A: Patient-Independent Train / Validation / Test Holdout.

    Splits dataset at patient level using deterministic random shuffling
    on patient IDs (weighted to try and balance seizure presence across splits).

    Returns:
        dict with keys:
          'train_indices': np.ndarray,
          'val_indices':   np.ndarray,
          'test_indices':  np.ndarray,
          'train_patients': list[str],
          'val_patients':   list[str],
          'test_patients':  list[str],
          'manifest':      dict metadata
    """
    inv = get_patient_inventory(dataset)
    patient_ids = sorted(list(inv.keys()))
    if len(patient_ids) < 3:
        raise ValueError(f"At least 3 patients required for train/val/test split. Got {len(patient_ids)}")

    # Sort patients by seizure presence & ratio to ensure balanced assignment
    rng = np.random.RandomState(seed)
    
    # Separate patients with seizures vs without seizures
    sz_patients = [pid for pid in patient_ids if inv[pid].seizure_windows > 0]
    nonsz_patients = [pid for pid in patient_ids if inv[pid].seizure_windows == 0]

    rng.shuffle(sz_patients)
    rng.shuffle(nonsz_patients)

    # Allocate test patients first, then val, then train
    n_test_sz = max(1, int(round(len(sz_patients) * test_ratio))) if sz_patients else 0
    n_val_sz = max(1, int(round(len(sz_patients) * val_ratio))) if len(sz_patients) > 2 else 0

    test_pats = set(sz_patients[:n_test_sz])
    val_pats = set(sz_patients[n_test_sz:n_test_sz + n_val_sz])
    train_pats = set(sz_patients[n_test_sz + n_val_sz:])

    # Distribute non-seizure patients proportionally
    n_test_nsz = int(round(len(nonsz_patients) * test_ratio))
    n_val_nsz = int(round(len(nonsz_patients) * val_ratio))

    test_pats.update(nonsz_patients[:n_test_nsz])
    val_pats.update(nonsz_patients[n_test_nsz:n_test_nsz + n_val_nsz])
    train_pats.update(nonsz_patients[n_test_nsz + n_val_nsz:])

    # If train_pats is empty due to small patient count, re-balance
    if not train_pats:
        all_p = list(test_pats | val_pats)
        train_pats.add(all_p.pop())

    # Verify no overlap
    verify_no_leakage(train_pats, val_pats, test_pats)

    # Assign window indices based on patient allocation
    train_idx, val_idx, test_idx = [], [], []
    train_recs, val_recs, test_recs = set(), set(), set()

    for idx, w in enumerate(dataset.windows):
        if w.patient_id in train_pats:
            train_idx.append(idx)
            train_recs.add(w.recording_id)
        elif w.patient_id in val_pats:
            val_idx.append(idx)
            val_recs.add(w.recording_id)
        elif w.patient_id in test_pats:
            test_idx.append(idx)
            test_recs.add(w.recording_id)

    verify_no_leakage(train_pats, val_pats, test_pats, train_recs, val_recs, test_recs)

    train_arr = np.array(train_idx, dtype=int)
    val_arr = np.array(val_idx, dtype=int)
    test_arr = np.array(test_idx, dtype=int)

    all_labels = dataset.labels
    manifest = {
        "protocol": "Protocol A — Patient-Independent Holdout",
        "seed": seed,
        "total_windows": len(dataset),
        "train": {
            "patients": sorted(list(train_pats)),
            "windows": len(train_arr),
            "seizure_windows": int(np.sum(all_labels[train_arr] == 1)),
            "non_seizure_windows": int(np.sum(all_labels[train_arr] == 0)),
        },
        "validation": {
            "patients": sorted(list(val_pats)),
            "windows": len(val_arr),
            "seizure_windows": int(np.sum(all_labels[val_arr] == 1)),
            "non_seizure_windows": int(np.sum(all_labels[val_arr] == 0)),
        },
        "test": {
            "patients": sorted(list(test_pats)),
            "windows": len(test_arr),
            "seizure_windows": int(np.sum(all_labels[test_arr] == 1)),
            "non_seizure_windows": int(np.sum(all_labels[test_arr] == 0)),
        },
        "created_at": datetime.date.today().isoformat()
    }

    return {
        "train_indices": train_arr,
        "val_indices": val_arr,
        "test_indices": test_arr,
        "train_patients": sorted(list(train_pats)),
        "val_patients": sorted(list(val_pats)),
        "test_patients": sorted(list(test_pats)),
        "manifest": manifest
    }


def get_group_kfold_splits(dataset: SegmentedDataset,
                            n_splits: int = 5,
                            seed: int = 42) -> List[dict]:
    """
    Protocol B: Patient-Grouped K-Fold Cross-Validation.

    Uses sklearn GroupKFold on window patient_ids to generate n_splits folds.
    In every fold, zero patients overlap between train and validation.
    """
    groups = dataset.patient_ids
    unique_patients = np.unique(groups)
    if len(unique_patients) < n_splits:
        n_splits = len(unique_patients)

    gkf = GroupKFold(n_splits=n_splits)
    X_dummy = np.zeros((len(dataset), 1))
    y = dataset.labels

    folds = []
    all_patients_set = set(unique_patients)

    for fold_idx, (train_idx, val_idx) in enumerate(gkf.split(X_dummy, y, groups=groups)):
        tr_pats = set(np.array(groups)[train_idx])
        val_pats = set(np.array(groups)[val_idx])

        # Verify zero patient overlap
        verify_no_leakage(tr_pats, val_pats, set())

        tr_recs = set(dataset.windows[i].recording_id for i in train_idx)
        val_recs = set(dataset.windows[i].recording_id for i in val_idx)
        verify_no_leakage(tr_pats, val_pats, set(), tr_recs, val_recs, None)

        fold_info = {
            "fold": fold_idx + 1,
            "train_indices": train_idx,
            "val_indices": val_idx,
            "train_patients": sorted(list(tr_pats)),
            "val_patients": sorted(list(val_pats)),
            "train_windows": len(train_idx),
            "val_windows": len(val_idx),
            "train_seizures": int(np.sum(y[train_idx] == 1)),
            "val_seizures": int(np.sum(y[val_idx] == 1)),
        }
        folds.append(fold_info)

    return folds


def get_loso_splits(dataset: SegmentedDataset) -> List[dict]:
    """
    Protocol C: Leave-One-Subject-Out (LOSO / LOGO) Cross-Validation.

    Generates N folds where N = number of unique patients.
    Each patient serves as the validation subject exactly once.
    """
    groups = dataset.patient_ids
    unique_patients = sorted(list(set(groups)))
    y = dataset.labels

    folds = []
    for fold_idx, test_pid in enumerate(unique_patients):
        val_idx = np.where(np.array(groups) == test_pid)[0]
        train_idx = np.where(np.array(groups) != test_pid)[0]

        tr_pats = set(unique_patients) - {test_pid}
        val_pats = {test_pid}

        verify_no_leakage(tr_pats, val_pats, set())

        fold_info = {
            "fold": fold_idx + 1,
            "test_patient": test_pid,
            "train_indices": train_idx,
            "val_indices": val_idx,
            "train_patients": sorted(list(tr_pats)),
            "val_patients": sorted(list(val_pats)),
            "train_windows": len(train_idx),
            "val_windows": len(val_idx),
            "train_seizures": int(np.sum(y[train_idx] == 1)),
            "val_seizures": int(np.sum(y[val_idx] == 1)),
        }
        folds.append(fold_info)

    return folds


class LeakageFreeScaler:
    """
    Feature Scaler wrapper ensuring strict leakage prevention.

    StandardScaler is fitted ONLY on training feature matrix X_train.
    The fitted parameters (mean_, scale_) are applied to X_val and X_test.
    """

    def __init__(self):
        self.scaler = StandardScaler()
        self.is_fitted = False

    def fit_transform(self, X_train: np.ndarray) -> np.ndarray:
        if X_train.size == 0:
            raise ValueError("Cannot fit scaler on empty X_train.")
        X_scaled = self.scaler.fit_transform(X_train)
        self.is_fitted = True
        return X_scaled.astype(np.float32)

    def transform(self, X: np.ndarray) -> np.ndarray:
        if not self.is_fitted:
            raise RuntimeError("LeakageFreeScaler is not fitted yet. Must call fit_transform on X_train first.")
        if X.size == 0:
            return X.astype(np.float32)
        return self.scaler.transform(X).astype(np.float32)


def export_split_manifest(split_manifest: dict, output_path: str):
    """
    Save reproducible split information to JSON file.
    """
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(split_manifest, f, indent=2)
