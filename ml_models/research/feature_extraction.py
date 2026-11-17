"""
NeuroGuard AI Research Pipeline — Feature Extraction Module
============================================================
Prepares two distinct canonical representations from a SegmentedDataset:

1. CLASSICAL ML FEATURES (feature_extraction_classical)
   Fixed-length numerical feature vectors extracted from EEG windows.
   Compatible with scikit-learn models (RandomForest, SVC, etc.).
   Feature schema is versioned and logged.

2. RAW WINDOW ARRAYS (build_raw_windows)
   Padded/truncated numpy arrays of shape (n_windows, n_channels, n_samples).
   Compatible with deep learning models (1D CNN, CNN+LSTM, Transformer).

These representations are NEVER mixed. Classical features are extracted
from the same segmented windows as raw arrays, ensuring comparability.

Classical Feature Schema (per window, per channel, aggregated across channels)
-------------------------------------------------------------------------------
For each channel:
  - mean, std, rms, peak_to_peak, line_length
  - hjorth_activity, hjorth_mobility, hjorth_complexity
  - band power: delta, theta, alpha, beta, gamma  (absolute)
  - band power: delta_rel, theta_rel, alpha_rel, beta_rel, gamma_rel  (relative)
  - spectral_entropy

Aggregation across channels: mean and std.
Total features: 18 per-channel features × 2 aggregation ops = 36 features.
"""

import numpy as np
from scipy.signal import welch
from typing import List, Tuple
import math

from .segmentation import SegmentedDataset, EEGWindow

FEATURE_SCHEMA_VERSION = "v1.0"

BANDS = {
    "delta": (0.5,  4.0),
    "theta": (4.0,  8.0),
    "alpha": (8.0,  13.0),
    "beta":  (13.0, 30.0),
    "gamma": (30.0, 70.0),
}


def _bandpower(freqs: np.ndarray, psd: np.ndarray, fmin: float, fmax: float) -> float:
    mask = (freqs >= fmin) & (freqs <= fmax)
    if not np.any(mask):
        return 0.0
    return float(np.trapz(psd[mask], freqs[mask]))


def _extract_single_channel(sig: np.ndarray, sfreq: float) -> dict:
    """
    Extract all per-channel features from a 1D signal array.
    Returns a dict of {feature_name: float}.
    """
    n = len(sig)
    feats = {}

    # Basic statistics
    feats["mean"]           = float(np.mean(sig))
    feats["std"]            = float(np.std(sig))
    feats["rms"]            = float(np.sqrt(np.mean(sig ** 2)))
    feats["peak_to_peak"]   = float(np.ptp(sig))

    # Line length (sum of absolute differences)
    diff1 = np.diff(sig)
    feats["line_length"] = float(np.sum(np.abs(diff1)))

    # Hjorth parameters
    diff2    = np.diff(diff1)
    var0     = float(np.var(sig))
    var1     = float(np.var(diff1)) if len(diff1) > 0 else 0.0
    var2     = float(np.var(diff2)) if len(diff2) > 0 else 0.0
    activity = var0
    mobility = math.sqrt(var1 / var0) if var0 > 0 else 0.0
    complexity = (math.sqrt(var2 / var1) / mobility
                  if var1 > 0 and mobility > 0 else 0.0)
    feats["hjorth_activity"]   = activity
    feats["hjorth_mobility"]   = mobility
    feats["hjorth_complexity"] = complexity

    # Welch PSD band powers
    try:
        nperseg = min(256, n)
        freqs, psd = welch(sig, fs=sfreq, nperseg=nperseg)
        total_power = float(np.trapz(psd, freqs)) if psd.size > 0 else 0.0
        for band_name, (flo, fhi) in BANDS.items():
            bp = _bandpower(freqs, psd, flo, fhi)
            feats[f"bp_{band_name}"]     = bp
            feats[f"bp_{band_name}_rel"] = bp / total_power if total_power > 0 else 0.0
        # Spectral entropy
        psd_norm = psd / (np.sum(psd) + 1e-12)
        feats["spectral_entropy"] = float(-np.sum(psd_norm * np.log(psd_norm + 1e-12)))
    except Exception:
        for band_name in BANDS:
            feats[f"bp_{band_name}"]     = 0.0
            feats[f"bp_{band_name}_rel"] = 0.0
        feats["spectral_entropy"] = 0.0

    return feats


def _extract_window_features(window: EEGWindow) -> np.ndarray:
    """
    Extract aggregated feature vector from a single EEGWindow.
    Aggregation: mean and std across channels for each per-channel feature.
    Returns 1D float32 array of shape (n_features,).
    """
    sfreq    = window.sfreq
    signals  = window.signals  # (n_channels, n_samples)
    n_ch     = signals.shape[0]

    per_ch_features = [_extract_single_channel(signals[ch], sfreq)
                       for ch in range(n_ch)]

    # Build aggregated dict
    feature_keys = list(per_ch_features[0].keys())
    agg = {}
    for k in feature_keys:
        vals = np.array([f[k] for f in per_ch_features])
        agg[f"{k}_ch_mean"] = float(np.mean(vals))
        agg[f"{k}_ch_std"]  = float(np.std(vals))

    return np.array(list(agg.values()), dtype=np.float32), list(agg.keys())


def extract_features_classical(dataset: SegmentedDataset) -> Tuple[np.ndarray, np.ndarray, List[str], List[str], List[str]]:
    """
    Extract classical ML feature matrix from a SegmentedDataset.

    Returns:
        X:            Feature matrix, shape (n_windows, n_features), float32
        y:            Label vector, shape (n_windows,), int32  (0 or 1)
        feature_names: List of feature column names (length n_features)
        patient_ids:  List of patient_id strings per window (for GroupKFold)
        recording_ids: List of recording_id strings per window

    IMPORTANT: This function does NOT fit any scaler.
    Scaling must be done AFTER patient-independent splitting.
    """
    if not dataset.windows:
        raise ValueError("SegmentedDataset is empty. No windows to extract features from.")

    X_list = []
    feature_names = None

    for window in dataset.windows:
        feat_vec, names = _extract_window_features(window)
        X_list.append(feat_vec)
        if feature_names is None:
            feature_names = names

    X           = np.vstack(X_list).astype(np.float32)
    y           = dataset.labels
    patient_ids = dataset.patient_ids
    recording_ids = [w.recording_id for w in dataset.windows]

    return X, y, feature_names, patient_ids, recording_ids


def build_raw_windows(dataset: SegmentedDataset,
                      pad_or_truncate: bool = True
                      ) -> Tuple[np.ndarray, np.ndarray, List[str], List[str]]:
    """
    Build raw signal window array for deep learning models.

    Returns:
        X_raw:        ndarray shape (n_windows, n_channels, n_samples), float32
        y:            Label vector, shape (n_windows,), int32
        patient_ids:  List of patient_id strings per window
        recording_ids: List of recording_id strings per window

    All windows are padded (with zeros) or truncated to the modal shape.
    """
    if not dataset.windows:
        raise ValueError("SegmentedDataset is empty.")

    shapes  = [w.signals.shape for w in dataset.windows]
    n_ch    = max(s[0] for s in shapes)
    n_samp  = max(s[1] for s in shapes)

    X_list = []
    for w in dataset.windows:
        sig = w.signals
        ch, sa = sig.shape
        if pad_or_truncate:
            out = np.zeros((n_ch, n_samp), dtype=np.float32)
            out[:ch, :sa] = sig[:, :n_samp]
        else:
            out = sig.astype(np.float32)
        X_list.append(out)

    X_raw       = np.stack(X_list).astype(np.float32)
    y           = dataset.labels
    patient_ids = dataset.patient_ids
    recording_ids = [w.recording_id for w in dataset.windows]
    return X_raw, y, patient_ids, recording_ids
