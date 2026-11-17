"""
NeuroGuard AI - EEG file inference
==================================
Runs the trained window-level seizure detector on an uploaded recording.

Pipeline (identical to training in build_feature_matrix.py):
    read EDF/CSV -> segment (4 s windows, 2 s step) -> extract_features_classical -> model

The model artifact (seizure_eeg_model.joblib) is a dict:
    pipeline, feature_names, threshold, consecutive_windows, model_version, evaluation
Inputs that cannot be analysed safely return status "CANNOT_ASSESS" instead of a label.
"""
import io
import os
import sys
import tempfile

import joblib
import numpy as np

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(_HERE))

from ml_models.research.eeg_io import _read_edf_header, _read_edf_signals  # noqa: E402
from ml_models.research.feature_extraction import extract_features_classical  # noqa: E402
from ml_models.research.segmentation import segment_recording  # noqa: E402

MODEL_PATH = os.path.join(_HERE, "seizure_eeg_model.joblib")
WINDOW_S, STEP_S = 4.0, 2.0
NON_EEG = ["ECG", "EKG", "EMG", "EOG", "MARK", "STIM", "EVENT", "DC"]
TIME_COLUMNS = {"time", "timestamp", "t", "sec", "seconds", "time_s", "sample", "sample_index", "index"}
MIN_DURATION_S = WINDOW_S * 3

DISCLAIMER = ("AI output is decision support, not a diagnosis. "
              "All findings must be reviewed by a qualified clinician.")

_artifact = None


class CannotAssess(Exception):
    """Input is readable but not suitable for analysis."""


def load_model():
    global _artifact
    if _artifact is None:
        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(f"Model artifact not found: {MODEL_PATH}")
        _artifact = joblib.load(MODEL_PATH)
    return _artifact


def _record_from_edf(data: bytes, name: str) -> tuple[dict, list]:
    with tempfile.NamedTemporaryFile(suffix=".edf", delete=False) as f:
        f.write(data)
        path = f.name
    try:
        hdr = _read_edf_header(path)
        idx = [i for i, ch in enumerate(hdr["ch_names"]) if not any(k in ch.upper() for k in NON_EEG)]
        ignored = [ch for i, ch in enumerate(hdr["ch_names"]) if i not in idx]
        if not idx:
            raise CannotAssess("No EEG channels found in the EDF file.")
        signals = _read_edf_signals(path, hdr, channel_indices=idx)
        names = [hdr["ch_names"][i] for i in idx]
        sfreq = float(hdr["sfreq"])
    finally:
        os.unlink(path)
    warnings = [f"Ignored non-EEG channels: {ignored}"] if ignored else []
    return _record(signals, sfreq, names, name), warnings


def _record_from_table(data: bytes, name: str, sampling_rate: float | None) -> tuple[dict, list]:
    import pandas as pd
    try:
        df = pd.read_csv(io.BytesIO(data), sep=None, engine="python")
    except Exception as e:
        raise CannotAssess(f"File could not be parsed as a table: {e}")
    warnings = []
    time_cols = [c for c in df.columns if str(c).strip().lower() in TIME_COLUMNS]
    numeric = df.drop(columns=time_cols).apply(pd.to_numeric, errors="coerce")
    non_numeric = [c for c in numeric.columns if numeric[c].isna().mean() > 0.5]
    channels = [c for c in numeric.columns if c not in non_numeric]
    if non_numeric:
        warnings.append(f"Ignored non-numeric columns: {non_numeric}")
    if not channels:
        raise CannotAssess("No numeric EEG channel columns found.")
    if sampling_rate is None and time_cols:
        t = pd.to_numeric(df[time_cols[0]], errors="coerce").dropna().values
        if len(t) > 1 and np.median(np.diff(t)) > 0 and str(time_cols[0]).lower() not in {"sample", "sample_index", "index"}:
            sampling_rate = float(round(1.0 / np.median(np.diff(t))))
            warnings.append(f"Sampling rate {sampling_rate} Hz derived from column '{time_cols[0]}'.")
    if sampling_rate is None:
        raise CannotAssess("Sampling rate is unknown. Provide sampling_rate or a time column in seconds.")
    missing = float(numeric[channels].isna().mean().mean())
    if missing > 0.05:
        raise CannotAssess(f"{missing:.0%} of samples are missing.")
    signals = numeric[channels].interpolate(limit_direction="both").to_numpy(dtype=np.float32).T
    return _record(signals, float(sampling_rate), [str(c) for c in channels], name), warnings


def _record(signals, sfreq, names, name):
    return {
        "dataset_id": "upload", "recording_id": os.path.splitext(name)[0] or "upload",
        "patient_id": "upload", "sfreq": sfreq, "n_channels": len(names), "ch_names": names,
        "signals": signals, "duration_s": signals.shape[1] / sfreq, "seizures": [], "warnings": [],
    }


def _quality(record) -> list:
    sig = record["signals"]
    var = np.var(sig, axis=1)
    flat = [n for n, v in zip(record["ch_names"], var) if v < 1e-12]
    if len(flat) == len(record["ch_names"]):
        raise CannotAssess("All channels are flat (no signal).")
    if record["duration_s"] < MIN_DURATION_S:
        raise CannotAssess(f"Recording is {record['duration_s']:.1f} s; at least {MIN_DURATION_S:.0f} s is required.")
    if not 100 <= record["sfreq"] <= 2048:
        raise CannotAssess(f"Sampling rate {record['sfreq']} Hz is outside the supported 100-2048 Hz range.")
    return [f"Flat channels: {flat}"] if flat else []


def _read(data: bytes, filename: str, sampling_rate: float | None):
    ext = os.path.splitext(filename.lower())[1]
    if ext == ".edf" or data[:8] == b"0       ":
        return _record_from_edf(data, filename)
    if ext in (".csv", ".txt", ".dat", ".tsv"):
        return _record_from_table(data, filename, sampling_rate)
    raise CannotAssess(f"Unsupported file type '{ext}'. Supported: EDF, CSV, TXT, DAT.")


def summarize(data: bytes, filename: str, sampling_rate: float | None = None) -> dict:
    """Pre-analysis preview (spec §5.1): format, channels, duration, sampling rate."""
    ext = os.path.splitext(filename.lower())[1].lstrip(".").upper() or "UNKNOWN"
    base = {"filename": filename, "format": ext, "size_kb": round(len(data) / 1024, 1),
            "has_label_column": False, "unique_classes": 0, "class_distribution": {}, "is_multi_patient": False}
    try:
        record, warnings = _read(data, filename, sampling_rate)
    except Exception as e:
        return {**base, "readable": False, "reason": str(e)}
    return {**base, "readable": True, "total_rows": int(record["signals"].shape[1]),
            "feature_columns": record["n_channels"], "channels": record["ch_names"],
            "sampling_rate_hz": record["sfreq"], "duration_seconds": round(record["duration_s"], 1),
            "warnings": warnings}


def analyse(data: bytes, filename: str, sampling_rate: float | None = None) -> dict:
    """Analyse one uploaded recording. Never raises for bad input; returns CANNOT_ASSESS instead."""
    art = load_model()
    base = {"model_version": art["model_version"], "disclaimer": DISCLAIMER, "source": "ml_model"}
    try:
        record, warnings = _read(data, filename, sampling_rate)
        warnings += _quality(record)

        ds = segment_recording(record, window_length_s=WINDOW_S, window_step_s=STEP_S)
        X, _, feat_names, _, _ = extract_features_classical(ds)
        if list(feat_names) != list(art["feature_names"]):
            raise CannotAssess("Extracted features do not match the model's expected feature schema.")
        X = np.where(np.isfinite(X), X, np.nan)
    except CannotAssess as e:
        return {**base, "status": "CANNOT_ASSESS", "result": "cannot_assess", "reason": str(e)}
    except Exception as e:
        return {**base, "status": "CANNOT_ASSESS", "result": "cannot_assess",
                "reason": f"File could not be read as EEG ({type(e).__name__}: {e})"}

    prob = art["pipeline"].predict_proba(X)[:, 1]
    thr, k = art["threshold"], art["consecutive_windows"]
    pos = prob >= thr
    alarm = np.convolve(pos.astype(int), np.ones(k, int), "full")[: len(pos)] >= k

    intervals, start = [], None
    for i, a in enumerate(alarm):
        if a and start is None:
            start = max(0, i - k + 1)
        if not a and start is not None:
            intervals.append((start, i - 1)); start = None
    if start is not None:
        intervals.append((start, len(alarm) - 1))
    flagged = [{"start_s": round(s * STEP_S, 1), "end_s": round(e * STEP_S + WINDOW_S, 1),
                "max_probability": round(float(prob[s:e + 1].max()), 3)} for s, e in intervals]

    detected = bool(flagged)
    return {
        **base,
        "status": "SUCCESS",
        "result": "seizure_like_activity" if detected else "no_seizure_like_activity",
        "clinical_finding": ("Seizure-like EEG activity flagged for clinician review" if detected
                             else "No seizure-like activity flagged by the model"),
        "flagged_intervals": flagged,
        "max_window_probability": round(float(prob.max()), 3),
        "n_windows": int(len(prob)),
        "duration_s": round(record["duration_s"], 1),
        "sampling_rate_hz": record["sfreq"],
        "channels": record["ch_names"],
        "window_probabilities": [round(float(p), 3) for p in prob],
        "window_step_s": STEP_S,
        "warnings": warnings,
        "evaluation": art.get("evaluation", {}),
    }
