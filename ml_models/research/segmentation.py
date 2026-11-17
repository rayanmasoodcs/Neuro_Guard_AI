"""
NeuroGuard AI Research Pipeline — Segmentation Module
======================================================
Segments a preprocessed Canonical EEG Record into fixed-length windows
and assigns binary seizure/non-seizure labels. Patient identity metadata
is preserved in every window for patient-independent splitting.

Segmentation parameters (justified)
--------------------------------------
WINDOW_LENGTH_S = 4.0  seconds
  Rationale: Standard in EEG seizure detection literature (e.g. Shoeb 2010,
  Tsiouris 2018). Long enough to capture at least one cycle of delta (0.5 Hz)
  and several cycles of ictal high-frequency oscillations.

WINDOW_STEP_S = 2.0  seconds (50% overlap)
  Rationale: 50% overlap increases training examples without creating fully
  identical windows. For inference, stride can be adjusted to 0.5s.

SEIZURE_LABEL_THRESHOLD = 0.5
  A window is labelled SEIZURE (1) if >50% of its duration overlaps with
  a documented seizure interval. Windows with 0–50% overlap are labelled
  NON-SEIZURE (0). This avoids ambiguous transition windows that would
  introduce noisy labels.

Output window metadata schema
-------------------------------
{
    "dataset_id":     str,
    "patient_id":     str,
    "recording_id":   str,
    "window_index":   int,
    "onset_s":        float,   # window start relative to recording start
    "offset_s":       float,   # window end relative to recording start
    "label":          int,     # 0 = Non-Seizure, 1 = Seizure
    "label_str":      str,     # "non_seizure" | "seizure"
    "seizure_overlap_frac": float,  # fraction of window that is ictal
    "preprocessing_version": str,
}
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Optional

# Canonical segmentation constants
WINDOW_LENGTH_S        = 4.0
WINDOW_STEP_S          = 2.0
SEIZURE_LABEL_THRESHOLD = 0.50   # >50% overlap -> label = SEIZURE


@dataclass
class EEGWindow:
    """
    A single segmented EEG window with full provenance metadata.
    Signals shape: (n_channels, n_window_samples)
    """
    signals:                np.ndarray
    dataset_id:             str
    patient_id:             str
    recording_id:           str
    window_index:           int
    onset_s:                float
    offset_s:               float
    label:                  int       # 0 or 1
    label_str:              str       # "non_seizure" | "seizure"
    seizure_overlap_frac:   float
    sfreq:                  float
    ch_names:               List[str]
    preprocessing_version:  str


@dataclass
class SegmentedDataset:
    """
    Collection of windows from one or more recordings.
    Preserves per-window metadata for GroupKFold splitting.
    """
    windows:           List[EEGWindow]  = field(default_factory=list)
    label_map:         dict             = field(default_factory=lambda: {0: "non_seizure", 1: "seizure"})
    segmentation_params: dict           = field(default_factory=dict)

    def __len__(self):
        return len(self.windows)

    def append(self, w: EEGWindow):
        self.windows.append(w)

    @property
    def patient_ids(self) -> List[str]:
        return [w.patient_id for w in self.windows]

    @property
    def labels(self) -> np.ndarray:
        return np.array([w.label for w in self.windows], dtype=np.int32)

    @property
    def n_seizure(self) -> int:
        return int(np.sum(self.labels == 1))

    @property
    def n_non_seizure(self) -> int:
        return int(np.sum(self.labels == 0))

    def summary(self) -> str:
        patients = set(self.patient_ids)
        recordings = set(w.recording_id for w in self.windows)
        return (
            f"SegmentedDataset: {len(self.windows)} windows | "
            f"{len(patients)} patients | {len(recordings)} recordings | "
            f"Seizure={self.n_seizure} Non-Seizure={self.n_non_seizure}"
        )


def _compute_seizure_overlap(win_onset: float, win_offset: float,
                              seizures: list) -> float:
    """
    Computes fraction of window [win_onset, win_offset] that overlaps
    with any documented seizure interval.
    """
    win_len = win_offset - win_onset
    if win_len <= 0:
        return 0.0
    overlap = 0.0
    for sz in seizures:
        ov_start = max(win_onset, sz["onset_s"])
        ov_end   = min(win_offset, sz["offset_s"])
        if ov_end > ov_start:
            overlap += ov_end - ov_start
    return min(overlap / win_len, 1.0)


def segment_recording(record: dict,
                       window_length_s: float = WINDOW_LENGTH_S,
                       window_step_s: float   = WINDOW_STEP_S,
                       label_threshold: float = SEIZURE_LABEL_THRESHOLD,
                       include_transition_windows: bool = False
                       ) -> SegmentedDataset:
    """
    Segment a preprocessed Canonical EEG Record into fixed-length windows.

    Args:
        record:                Preprocessed CER dict.
        window_length_s:       Window duration in seconds.
        window_step_s:         Step/stride between windows in seconds.
        label_threshold:       Minimum seizure overlap fraction for label=1.
        include_transition_windows: If False (default), windows with
                               0 < overlap_frac <= label_threshold are
                               EXCLUDED to avoid noisy boundary labels.

    Returns:
        SegmentedDataset containing all valid windows.
    """
    sfreq          = float(record["sfreq"])
    signals        = record["signals"]          # (n_ch, n_samples)
    n_samples      = signals.shape[1]
    duration_s     = record["duration_s"]
    seizures       = record.get("seizures", [])
    patient_id     = record["patient_id"]
    dataset_id     = record["dataset_id"]
    recording_id   = record["recording_id"]
    ch_names       = record["ch_names"]
    preprocessing  = record.get("preprocessing", {})
    pp_version     = preprocessing.get("pipeline_version", "unknown")

    win_samples  = int(round(window_length_s * sfreq))
    step_samples = int(round(window_step_s * sfreq))

    if win_samples > n_samples:
        raise ValueError(
            f"Recording {recording_id} ({duration_s:.1f}s) is shorter than "
            f"window length ({window_length_s}s). Cannot segment."
        )
    if win_samples <= 0 or step_samples <= 0:
        raise ValueError("Window length and step must be positive.")

    dataset = SegmentedDataset(
        segmentation_params={
            "window_length_s":         window_length_s,
            "window_step_s":           window_step_s,
            "win_samples":             win_samples,
            "step_samples":            step_samples,
            "label_threshold":         label_threshold,
            "include_transition_windows": include_transition_windows,
            "sfreq":                   sfreq,
        }
    )

    window_index = 0
    start_sample = 0

    while start_sample + win_samples <= n_samples:
        end_sample = start_sample + win_samples
        win_onset_s  = start_sample / sfreq
        win_offset_s = end_sample   / sfreq

        overlap_frac = _compute_seizure_overlap(win_onset_s, win_offset_s, seizures)

        # Label assignment
        if overlap_frac > label_threshold:
            label = 1
        elif overlap_frac == 0.0:
            label = 0
        else:
            # Transition window: overlaps with seizure boundary but below threshold
            if not include_transition_windows:
                start_sample += step_samples
                window_index += 1
                continue
            label = 0  # conservative: treat as non-seizure

        label_str = "seizure" if label == 1 else "non_seizure"
        win_signals = signals[:, start_sample:end_sample].copy()

        dataset.append(EEGWindow(
            signals               = win_signals,
            dataset_id            = dataset_id,
            patient_id            = patient_id,
            recording_id          = recording_id,
            window_index          = window_index,
            onset_s               = win_onset_s,
            offset_s              = win_offset_s,
            label                 = label,
            label_str             = label_str,
            seizure_overlap_frac  = float(overlap_frac),
            sfreq                 = sfreq,
            ch_names              = ch_names,
            preprocessing_version = pp_version,
        ))

        start_sample += step_samples
        window_index += 1

    return dataset
