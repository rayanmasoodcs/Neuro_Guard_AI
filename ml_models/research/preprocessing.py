"""
NeuroGuard AI Research Pipeline — Preprocessing Module
=======================================================
Applies ONLY scientifically justified, documented preprocessing
to a Canonical EEG Record (CER).

All operations are:
- Applied independently per recording (no cross-recording fitting).
- Documented with rationale.
- Reversible in principle (no lossy irreversible steps without justification).

Preprocessing artifact schema
------------------------------
{
    "pipeline_version":    str,     # e.g. "v1.0"
    "operations_applied":  list,    # ordered list of operation names
    "resampled_from":      float | None,
    "target_sfreq":        float,
    "bandpass_low_hz":     float,
    "bandpass_high_hz":    float,
    "notch_hz":            list[float],
    "normalization":       str,     # "zscore_per_channel" | "none"
}
"""

import numpy as np
from scipy.signal import butter, filtfilt, iirnotch, resample_poly
from math import gcd

PIPELINE_VERSION = "v1.0"

# Target common sampling rate after harmonization
TARGET_SFREQ = 256.0

# Bandpass: preserve clinically relevant EEG frequencies.
# Lower bound 0.5 Hz removes slow DC drift without destroying seizure onset morphology.
# Upper bound 70 Hz is below the Nyquist frequency of both 256 Hz and 512 Hz recordings.
BANDPASS_LOW_HZ  = 0.5
BANDPASS_HIGH_HZ = 70.0

# Notch: suppress AC mains interference at 50 Hz (EU) and 60 Hz (US).
# Applied at quality factor 30 (narrow notch).
NOTCH_FREQS_HZ = [50.0, 60.0]

# Amplitude clipping: values beyond ±800 µV are likely artifacts or electrode pop artifacts.
# Threshold is conservative relative to typical seizure amplitudes (50–200 µV scalp).
ARTIFACT_CLIP_UV = 800.0


def _bandpass_filter(signals: np.ndarray, sfreq: float,
                     low_hz: float = BANDPASS_LOW_HZ,
                     high_hz: float = BANDPASS_HIGH_HZ,
                     order: int = 4) -> np.ndarray:
    """
    4th-order Butterworth bandpass filter applied with zero-phase filtfilt.
    Rationale: Removes sub-0.5 Hz baseline wander (electrode movement drift) and
    high-frequency noise above 70 Hz without distorting ictal onset morphology.
    """
    nyq = sfreq / 2.0
    low  = low_hz  / nyq
    high = high_hz / nyq
    low  = np.clip(low,  0.001, 0.999)
    high = np.clip(high, 0.001, 0.999)
    if low >= high:
        return signals
    b, a = butter(order, [low, high], btype="band")
    out = np.zeros_like(signals)
    for ch in range(signals.shape[0]):
        try:
            out[ch] = filtfilt(b, a, signals[ch])
        except Exception:
            out[ch] = signals[ch]  # leave unchanged if filter fails
    return out


def _notch_filter(signals: np.ndarray, sfreq: float,
                  freqs: list = None, quality: float = 30.0) -> np.ndarray:
    """
    IIR notch filter at mains frequencies (50/60 Hz).
    Rationale: AC mains interference creates sinusoidal artifacts that mimic
    high-frequency beta/gamma activity relevant to seizure detection.
    Applied only where frequency is below Nyquist.
    """
    if freqs is None:
        freqs = NOTCH_FREQS_HZ
    out = signals.copy()
    nyq = sfreq / 2.0
    for f0 in freqs:
        if f0 >= nyq:
            continue
        b, a = iirnotch(f0 / nyq, quality)
        for ch in range(out.shape[0]):
            try:
                out[ch] = filtfilt(b, a, out[ch])
            except Exception:
                pass
    return out


def _resample(signals: np.ndarray, src_sfreq: float,
              tgt_sfreq: float) -> np.ndarray:
    """
    Integer-ratio polyphase resampling (scipy.signal.resample_poly).
    Rationale: Siena records at 512 Hz. CHB-MIT at 256 Hz.
    Polyphase resampling is anti-aliased and preserves spectral content
    below min(src_nyq, tgt_nyq) = 128 Hz, which covers all clinically
    relevant EEG bands up to our 70 Hz bandpass ceiling.

    The ratio up/down is computed from a reduced integer fraction of
    tgt_sfreq / src_sfreq to avoid floating-point errors.
    """
    src = int(round(src_sfreq))
    tgt = int(round(tgt_sfreq))
    divisor = gcd(src, tgt)
    up   = tgt // divisor
    down = src // divisor
    out = np.zeros((signals.shape[0],
                    int(np.round(signals.shape[1] * tgt / src))),
                   dtype=np.float32)
    for ch in range(signals.shape[0]):
        out[ch] = resample_poly(signals[ch], up, down).astype(np.float32)
    return out


def _clip_artifacts(signals: np.ndarray,
                    clip_uv: float = ARTIFACT_CLIP_UV) -> tuple:
    """
    Hard amplitude clipping. Returns clipped signals and count of clipped samples.
    Rationale: Electrode pop / motion artifacts can produce spikes of thousands of µV
    that saturate downstream normalizers and distort feature extraction.
    This is a conservative guard, not a sophisticated artifact rejection step.
    """
    clipped = np.clip(signals, -clip_uv, clip_uv)
    n_clipped = int(np.sum(np.abs(signals) > clip_uv))
    return clipped, n_clipped


def _zscore_per_channel(signals: np.ndarray) -> np.ndarray:
    """
    Z-score normalization per channel (mean=0, std=1).
    Rationale: Equalizes channel amplitude scales before feature extraction.
    MUST be applied AFTER patient-independent train/test split and
    ONLY using training data statistics when used in ML training context.
    In this preprocessing step it is applied per-recording for ingestion
    purposes only; the scaler fitted on training data is applied separately.
    """
    out = np.zeros_like(signals, dtype=np.float32)
    for ch in range(signals.shape[0]):
        mu  = np.mean(signals[ch])
        std = np.std(signals[ch])
        out[ch] = (signals[ch] - mu) / (std + 1e-8) if std > 1e-8 else signals[ch] - mu
    return out


def preprocess_recording(record: dict, target_sfreq: float = TARGET_SFREQ,
                          normalize: bool = False) -> dict:
    """
    Apply the documented preprocessing pipeline to a Canonical EEG Record.

    Steps applied in order:
      1. Amplitude clipping (artifact guard, ±800 µV)
      2. Resampling to target_sfreq (if src_sfreq != target_sfreq)
      3. Bandpass filtering (0.5–70 Hz, Butterworth order 4, zero-phase)
      4. Notch filtering (50 Hz, 60 Hz, Q=30)
      5. [Optional] Per-channel Z-score normalization

    Returns the record dict with updated 'signals', 'sfreq', and
    a new 'preprocessing' sub-dict documenting what was applied.

    NOTE: 'normalize=False' by default.
    In cross-patient training, normalization MUST be fitted on the
    training fold only and applied to the test fold via the scaler artifact.
    """
    signals   = record["signals"].astype(np.float32)
    src_sfreq = float(record["sfreq"])
    ops       = []
    warnings  = list(record.get("warnings", []))

    # 1. Amplitude clipping
    signals, n_clipped = _clip_artifacts(signals, ARTIFACT_CLIP_UV)
    ops.append("artifact_clip_800uV")
    if n_clipped > 0:
        warnings.append(f"Amplitude clipping applied to {n_clipped} samples.")

    # 2. Resampling
    resampled_from = None
    if abs(src_sfreq - target_sfreq) > 0.5:
        if src_sfreq < target_sfreq:
            warnings.append(
                f"Source sampling rate {src_sfreq} Hz is BELOW target {target_sfreq} Hz. "
                "Upsampling will not recover lost frequency content."
            )
        signals = _resample(signals, src_sfreq, target_sfreq)
        resampled_from = src_sfreq
        ops.append(f"resample_{int(src_sfreq)}Hz_to_{int(target_sfreq)}Hz_polyphase")

    current_sfreq = target_sfreq

    # 3. Bandpass
    signals = _bandpass_filter(signals, current_sfreq, BANDPASS_LOW_HZ, BANDPASS_HIGH_HZ)
    ops.append(f"bandpass_{BANDPASS_LOW_HZ}_{BANDPASS_HIGH_HZ}Hz_butterworth4")

    # 4. Notch
    signals = _notch_filter(signals, current_sfreq, NOTCH_FREQS_HZ)
    ops.append("notch_50Hz_60Hz_Q30")

    # 5. Optional normalization
    if normalize:
        signals = _zscore_per_channel(signals)
        ops.append("zscore_per_channel")

    out = dict(record)
    out["signals"] = signals
    out["sfreq"]   = current_sfreq
    out["warnings"] = warnings
    out["preprocessing"] = {
        "pipeline_version":   PIPELINE_VERSION,
        "operations_applied": ops,
        "resampled_from":     resampled_from,
        "target_sfreq":       target_sfreq,
        "bandpass_low_hz":    BANDPASS_LOW_HZ,
        "bandpass_high_hz":   BANDPASS_HIGH_HZ,
        "notch_hz":           NOTCH_FREQS_HZ,
        "normalization":      "zscore_per_channel" if normalize else "none",
    }
    return out
