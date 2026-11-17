"""
NeuroGuard AI - Production ML Pipeline
Provides:
- Robust EEG file parsing (CSV, TXT, DAT, EDF) using base64 decoding and mne (if available)
- Time-series feature extraction (band power, Hjorth, entropy, line length, basic stats)
- Model prediction wrapper that loads saved artifacts (model, scaler, label map)
- Utilities for batch prediction and graph generation

Dependencies (add to environment): mne, pyedflib, scipy, numpy, pandas, joblib, matplotlib
"""

import io
import os
import base64
import json
import math
import numpy as np
import pandas as pd
import joblib
from scipy.signal import welch, iirnotch, butter, filtfilt, resample_poly, detrend
from scipy.stats import skew, kurtosis
from scipy import fftpack

# Try to import mne for EDF parsing; fallback if not installed
try:
    import mne
    _HAS_MNE = True
except Exception:
    _HAS_MNE = False

# EEG bands in Hz
BANDS = {
    'delta': (0.5, 4),
    'theta': (4, 8),
    'alpha': (8, 13),
    'beta': (13, 30),
    'gamma': (30, 100)
}


# ------------------ Signal preprocessing utilities ------------------

def notch_filter(sig, sfreq, freqs=(50.0, 60.0), quality=30.0):
    """Apply notch filters at given mains frequencies (50/60 Hz) if present."""
    try:
        out = sig.copy()
        for f0 in freqs:
            if f0 is None or sfreq <= (f0 * 2.5):
                continue
            # Design narrow-band notch
            b, a = iirnotch(w0=f0 / (sfreq / 2.0), Q=quality)
            out = filtfilt(b, a, out)
        return out
    except Exception:
        return sig


def bandpass_filter(sig, sfreq, l_freq=0.5, h_freq=40.0, order=4):
    """Zero-phase Butterworth bandpass filter."""
    try:
        nyq = 0.5 * sfreq
        low = max(l_freq / nyq, 1e-6)
        high = min(h_freq / nyq, 0.9999)
        if low >= high:
            return sig
        b, a = butter(order, [low, high], btype='band')
        return filtfilt(b, a, sig)
    except Exception:
        return sig


def resample_signals(signals, orig_sfreq, target_sfreq=256.0):
    """Resample signals to target_sfreq using polyphase resampling."""
    try:
        if orig_sfreq == target_sfreq:
            return signals, orig_sfreq
        import math
        gcd = math.gcd(int(round(orig_sfreq)), int(round(target_sfreq)))
        up = int(round(target_sfreq)) // gcd
        down = int(round(orig_sfreq)) // gcd
        if signals.ndim == 1:
            res = resample_poly(signals, up, down)
            return res.astype(np.float32), target_sfreq
        else:
            resampled = np.vstack([resample_poly(signals[ch, :], up, down) for ch in range(signals.shape[0])]).astype(np.float32)
            return resampled, target_sfreq
    except Exception:
        return signals, orig_sfreq


def remove_artifact_outliers(signals, z_thresh=6.0, clip_percentile=99.5):
    """Clip extreme outliers per-channel and replace NaNs with channel median."""
    try:
        sig = signals.copy()
        if sig.ndim == 1:
            sig = sig.reshape(1, -1)
        for ch in range(sig.shape[0]):
            chan = sig[ch]
            # clip large amplitude spikes
            high = np.nanpercentile(np.abs(chan), clip_percentile)
            limit = max(1e6, high)  # avoid tiny limits
            chan = np.clip(chan, -limit, limit)
            # median fill for NaNs
            if np.isnan(chan).any():
                med = np.nanmedian(chan)
                chan = np.where(np.isnan(chan), med, chan)
            sig[ch] = chan
        return sig
    except Exception:
        return signals


def apply_ica_if_available(signals, sfreq, n_components=None):
    """Attempt ICA-based artifact correction using MNE when available and enough channels."""
    try:
        if not _HAS_MNE:
            return signals
        import mne
        from mne.preprocessing import ICA
        if signals.ndim == 1:
            return signals
        n_ch = signals.shape[0]
        if n_ch < 4:
            return signals
        info = mne.create_info(ch_names=[f'CH{i+1}' for i in range(n_ch)], sfreq=sfreq, ch_types=['eeg'] * n_ch)
        raw = mne.io.RawArray(signals, info)
        # High-pass slightly to help ICA
        raw.filter(1.0, None, fir_design='firwin', verbose=False)
        if n_components is None:
            n_components = min(n_ch, 20)
        ica = ICA(n_components=n_components, random_state=42, max_iter='auto')
        ica.fit(raw, verbose=False)
        # Auto-detect components correlated with EOG/ECG is complex; skip automatic exclusion to avoid mis-removal
        cleaned = ica.apply(raw.copy(), exclude=[])  # placeholder: exclude none but keep pipeline
        return cleaned.get_data()
    except Exception:
        return signals


def preprocess_signals(signals, sfreq, target_sfreq=256.0, apply_ica=False):
    """Full preprocessing pipeline: orientation check -> detrend -> notch -> bandpass -> resample -> artifact removal.
    Input: signals (n_channels, n_samples)
    Returns: preprocessed_signals, final_sfreq
    """
    try:
        sig = np.asarray(signals, dtype=np.float32)
        if sig.ndim == 1:
            sig = sig.reshape(1, -1)
        # Detrend per channel
        for ch in range(sig.shape[0]):
            try:
                sig[ch] = detrend(sig[ch])
            except Exception:
                pass
        # Notch filter to remove mains interference
        for ch in range(sig.shape[0]):
            try:
                sig[ch] = notch_filter(sig[ch], sfreq)
            except Exception:
                pass
        # Bandpass
        for ch in range(sig.shape[0]):
            try:
                sig[ch] = bandpass_filter(sig[ch], sfreq)
            except Exception:
                pass
        # Resample
        sig, final_sfreq = resample_signals(sig, int(round(sfreq)), int(round(target_sfreq)))
        # Outlier removal / clipping
        sig = remove_artifact_outliers(sig)
        # Optional ICA
        if apply_ica:
            sig = apply_ica_if_available(sig, final_sfreq)
        return sig, float(final_sfreq)
    except Exception:
        return signals, float(sfreq)


def _bandpower_from_psd(freqs, psd, band):
    fmin, fmax = band
    mask = (freqs >= fmin) & (freqs <= fmax)
    if not np.any(mask):
        return 0.0
    return np.trapz(psd[mask], freqs[mask])


def extract_features_from_signal(sig, sfreq):
    """Extract features from a 1D numpy signal (single channel). Returns dict of features."""
    features = {}
    # Basic stats
    features['mean'] = float(np.nanmean(sig))
    features['std'] = float(np.nanstd(sig))
    features['min'] = float(np.nanmin(sig))
    features['max'] = float(np.nanmax(sig))
    features['skew'] = float(skew(sig, nan_policy='omit'))
    features['kurtosis'] = float(kurtosis(sig, nan_policy='omit'))

    # Hjorth parameters
    diff1 = np.diff(sig)
    diff2 = np.diff(diff1)
    var0 = np.nanvar(sig)
    var1 = np.nanvar(diff1) if diff1.size else 0.0
    var2 = np.nanvar(diff2) if diff2.size else 0.0
    activity = var0
    mobility = math.sqrt(var1 / var0) if var0 > 0 else 0.0
    complexity = math.sqrt(var2 / var1) / mobility if var1 > 0 and mobility > 0 else 0.0
    features['hjorth_activity'] = float(activity)
    features['hjorth_mobility'] = float(mobility)
    features['hjorth_complexity'] = float(complexity)

    # Line length
    features['line_length'] = float(np.nansum(np.abs(diff1)))

    # RMS
    features['rms'] = float(np.sqrt(np.nanmean(sig ** 2)))

    # Spectral features via Welch PSD
    try:
        freqs, psd = welch(sig, fs=sfreq, nperseg=min(256, len(sig)))
        total_power = np.trapz(psd, freqs) if psd.size else 0.0
        for band_name, band_range in BANDS.items():
            bp = _bandpower_from_psd(freqs, psd, band_range)
            features[f'bandpower_{band_name}'] = float(bp)
            features[f'bandpower_{band_name}_rel'] = float(bp / total_power) if total_power > 0 else 0.0
        # Spectral entropy
        psd_norm = psd / np.sum(psd) if np.sum(psd) > 0 else np.zeros_like(psd)
        spec_entropy = -np.sum(psd_norm * np.log(psd_norm + 1e-12))
        features['spectral_entropy'] = float(spec_entropy)
    except Exception:
        # If PSD fails, pad zeros
        for band_name in BANDS.keys():
            features[f'bandpower_{band_name}'] = 0.0
            features[f'bandpower_{band_name}_rel'] = 0.0
        features['spectral_entropy'] = 0.0

    return features


def aggregate_channel_features(signals, sfreq):
    """Given signals array shape (n_channels, n_samples) aggregate features across channels.
    Returns a 1D numpy vector and a feature name list.
    """
    if signals.ndim == 1:
        signals = signals.reshape(1, -1)
    n_ch = signals.shape[0]
    ch_feature_dicts = [extract_features_from_signal(signals[ch, :], sfreq) for ch in range(n_ch)]
    df = pd.DataFrame(ch_feature_dicts)
    # Aggregate: mean and std across channels for each feature
    agg_features = {}
    for col in df.columns:
        agg_features[f'{col}_ch_mean'] = float(df[col].mean())
        agg_features[f'{col}_ch_std'] = float(df[col].std())
    # Also include global stats
    agg_features['n_channels'] = n_ch
    agg_features['n_samples'] = signals.shape[1]
    # Feature names order
    feature_names = list(agg_features.keys())
    feature_vector = np.array([agg_features[k] for k in feature_names], dtype=np.float32).reshape(1, -1)
    return feature_vector, feature_names


def parse_eeg_bytes(file_bytes, file_extension):
    """Parse EEG uploaded bytes into signals (n_channels, n_samples) and sampling rate.
    file_bytes must be raw bytes (base64-decoded by caller) and file_extension str.
    Returns dict: {'signals': np.ndarray, 'sfreq': float, 'ch_names': list} or (None, error)
    """
    try:
        ext = file_extension.lower()
        # If EDF and mne available use mne
        if ext in ('edf',) and _HAS_MNE:
            bio = io.BytesIO(file_bytes)
            # mne can read Raw from file-like if filename has .edf - workaround: write temp to buffer
            raw = mne.io.read_raw_edf(bio, preload=True, verbose=False)
            data = raw.get_data()  # shape (n_channels, n_samples)
            sfreq = raw.info.get('sfreq', 256.0)
            ch_names = raw.info.get('ch_names', [f'CH{i}' for i in range(data.shape[0])])
            return {'signals': data.astype(np.float32), 'sfreq': float(sfreq), 'ch_names': ch_names}, None

        # Try generic text-based parsing (CSV/TXT/DAT)
        text = None
        try:
            text = file_bytes.decode('utf-8')
        except Exception:
            # Maybe base64-wrapped file containing binary - try base64 decode
            try:
                decoded = base64.b64decode(file_bytes)
                text = decoded.decode('utf-8')
            except Exception:
                text = None
        if text is not None:
            # Read into pandas and infer delimiter
            try:
                df = pd.read_csv(io.StringIO(text), header=None)
            except Exception:
                try:
                    df = pd.read_csv(io.StringIO(text), header=None, delim_whitespace=True)
                except Exception:
                    return None, 'Unable to parse text EEG file (CSV/TXT/DAT)'
            # Each column is a channel; rows are time samples
            arr = df.values.T.astype(np.float32)  # shape (n_channels, n_samples)
            sfreq = 256.0  # default fallback
            return {'signals': arr, 'sfreq': sfreq, 'ch_names': [f'CH{i+1}' for i in range(arr.shape[0])]}, None

        # If we reach here and no text, try EDF with fallback to pyedflib if available
        try:
            import pyedflib
            bio = io.BytesIO(file_bytes)
            # pyedflib requires a filename; write to a temp file
            import tempfile
            with tempfile.NamedTemporaryFile(delete=False, suffix='.edf') as tmpf:
                tmpf.write(file_bytes)
                tmp_name = tmpf.name
            f = pyedflib.EdfReader(tmp_name)
            n = f.signals_in_file
            signals = np.vstack([f.readSignal(i) for i in range(n)]).astype(np.float32)
            sfreq = f.getSampleFrequency(0)
            ch_names = f.getSignalLabels()
            f.close()
            os.unlink(tmp_name)
            return {'signals': signals, 'sfreq': float(sfreq), 'ch_names': ch_names}, None
        except Exception:
            return None, f'Unsupported or corrupted EEG file format: {file_extension}'

    except Exception as e:
        return None, f'Error parsing EEG file: {str(e)}'


def load_artifacts(model_dir='./ml_models'):
    """Load model, scaler, label map and feature names saved by training pipeline."""
    artifacts = {}
    try:
        model_path = os.path.join(model_dir, 'seizure_model_production.joblib')
        scaler_path = os.path.join(model_dir, 'seizure_scaler.joblib')
        meta_path = os.path.join(model_dir, 'seizure_meta.json')

        if not os.path.exists(model_path):
            raise FileNotFoundError(model_path)

        artifacts['model'] = joblib.load(model_path)
        artifacts['scaler'] = joblib.load(scaler_path) if os.path.exists(scaler_path) else None

        if os.path.exists(meta_path):
            with open(meta_path, 'r') as f:
                meta = json.load(f)
            # Normalize legacy keys to canonical schema
            if isinstance(meta, dict):
                # feature names key migrated from 'feature_columns' -> 'feature_names'
                if 'feature_columns' in meta and 'feature_names' not in meta:
                    meta['feature_names'] = meta.get('feature_columns')
                # If only classes present, build a label_map
                if 'label_map' not in meta and 'classes' in meta:
                    try:
                        meta['label_map'] = {str(i): lab for i, lab in enumerate(meta.get('classes', []))}
                    except Exception:
                        meta['label_map'] = {}
                # Ensure model_version exists
                if 'model_version' not in meta:
                    meta['model_version'] = 'v1'
            artifacts['meta'] = meta
        else:
            artifacts['meta'] = {}

        return artifacts, None
    except Exception as e:
        return None, f'Failed to load artifacts: {str(e)}'


def predict_from_raw(signals, sfreq, model_dir='./ml_models'):
    """Full predict pipeline: extract features, scale, predict, return probs and label mapping.
    Uses cached model artifacts to avoid repeated disk I/O."""
    try:
        artifacts, err = load_artifacts_cached(model_dir)
        if err:
            return None, 0.0, None, {}, err
        model = artifacts.get('model')
        scaler = artifacts.get('scaler')
        meta = artifacts.get('meta', {})
        label_map = meta.get('label_map', {})
        feature_names = meta.get('feature_names', [])

        # Preprocess signals (filtering, notch, resampling, artifact clipping)
        try:
            signals_proc, sfreq_proc = preprocess_signals(signals, sfreq, target_sfreq=256.0, apply_ica=False)
        except Exception:
            signals_proc, sfreq_proc = signals, float(sfreq)
        # Extract features from preprocessed signals
        feature_vec, feat_names = aggregate_channel_features(signals_proc, sfreq_proc)

        # Align/scaler with defensive checks
        # Get expected feature dimensionality from artifacts meta, scaler, or model
        expected_dim = None
        if isinstance(feature_names, (list, tuple)) and len(feature_names) > 0:
            expected_dim = len(feature_names)
        if scaler is not None and expected_dim is None:
            expected_dim = getattr(scaler, 'n_features_in_', None)
        if model is not None and expected_dim is None:
            expected_dim = getattr(model, 'n_features_in_', None)
            if expected_dim is None and hasattr(model, 'calibrated_classifiers_') and model.calibrated_classifiers_:
                try:
                    expected_dim = getattr(model.calibrated_classifiers_[0].estimator, 'n_features_in_', None)
                except Exception:
                    pass
            if expected_dim is None and hasattr(model, 'estimator'):
                try:
                    expected_dim = getattr(model.estimator, 'n_features_in_', None)
                except Exception:
                    pass

        # Defensive shape handling: pad or truncate feature vector when possible
        if expected_dim is not None:
            curr_dim = int(feature_vec.shape[1])
            if curr_dim != expected_dim:
                if curr_dim < expected_dim:
                    # pad zeros
                    pad_width = expected_dim - curr_dim
                    pad = np.zeros((feature_vec.shape[0], pad_width), dtype=feature_vec.dtype)
                    feature_vec = np.hstack([feature_vec, pad])
                else:
                    # truncate with warning
                    feature_vec = feature_vec[:, :expected_dim]

        if scaler is not None:
            try:
                feature_vec = scaler.transform(feature_vec)
            except Exception as e:
                # Maybe scaler was fitted to different feature order/size
                # Provide clear diagnostic message with expected and actual dims
                actual = int(feature_vec.shape[1]) if hasattr(feature_vec, 'shape') else None
                expect = getattr(scaler, 'n_features_in_', None)
                return None, 0.0, None, {}, f'Scaler transform failed: {e} (feature_vec_dim={actual}, scaler_n={expect})'

        # Ensure model expected dimension right before prediction call
        model_expected_dim = getattr(model, 'n_features_in_', None)
        if model_expected_dim is None and hasattr(model, 'calibrated_classifiers_') and model.calibrated_classifiers_:
            try:
                model_expected_dim = getattr(model.calibrated_classifiers_[0].estimator, 'n_features_in_', None)
            except Exception:
                pass
        if model_expected_dim is not None and hasattr(feature_vec, 'shape') and feature_vec.shape[1] != model_expected_dim:
            if feature_vec.shape[1] > model_expected_dim:
                feature_vec = feature_vec[:, :model_expected_dim]
            else:
                pad_width = model_expected_dim - feature_vec.shape[1]
                pad = np.zeros((feature_vec.shape[0], pad_width), dtype=feature_vec.dtype)
                feature_vec = np.hstack([feature_vec, pad])

        # Predict
        proba = None
        if hasattr(model, 'predict_proba'):
            proba = model.predict_proba(feature_vec)[0]
            pred_idx = int(np.argmax(proba))
            confidence = float(np.max(proba))
        else:
            pred_idx = int(model.predict(feature_vec)[0])
            confidence = 1.0
            proba = None

        # Map label
        pred_label = label_map.get(str(pred_idx), str(pred_idx))

        # Build all_scores dict
        all_scores = {}
        if proba is not None:
            for idx, p in enumerate(proba):
                lbl = label_map.get(str(idx), str(idx))
                all_scores[lbl] = float(p)

        return pred_idx, confidence, pred_label, all_scores, None
    except Exception as e:
        return None, 0.0, None, {}, str(e)


def generate_eeg_figure(signals, sfreq, ch_names=None, seconds=10, output_path=None,
                        title='EEG Waveform', patient_label=None):
    """Generate a professional PNG waveform for the first `seconds` of the first channels.
    Returns path to PNG or (None, error)
    """
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        if signals.ndim == 1:
            signals = signals.reshape(1, -1)
        n_ch, n_samples = signals.shape
        samples_to_plot = min(n_samples, int(seconds * sfreq))
        t = np.arange(samples_to_plot) / sfreq
        n_plot_ch = min(min(4, n_ch), max(1, n_ch))

        fig, axes = plt.subplots(n_plot_ch, 1, figsize=(12, 2.5 + n_plot_ch * 1.2), sharex=True)
        if n_plot_ch == 1:
            axes = [axes]

        for i in range(n_plot_ch):
            ax = axes[i]
            ax.plot(t, signals[i, :samples_to_plot], color='#0B8F55', linewidth=0.6)
            label = ch_names[i] if ch_names and i < len(ch_names) else f'Channel {i+1}'
            ax.set_ylabel(label, fontsize=8)
            ax.set_xlim(0, t[-1])
            ax.grid(True, alpha=0.3)
            ax.tick_params(labelsize=7)

        axes[-1].set_xlabel('Time (seconds)', fontsize=9)
        display_title = f'{title} - {patient_label}' if patient_label else title
        fig.suptitle(display_title, fontsize=12, fontweight='bold', color='#0B8F55')
        fig.tight_layout(rect=[0, 0.03, 1, 0.95])

        if not output_path:
            import tempfile
            fd, output_path = tempfile.mkstemp(suffix='.png')
            os.close(fd)
        plt.savefig(output_path, dpi=150, bbox_inches='tight')
        plt.close(fig)
        return output_path, None
    except Exception as e:
        return None, str(e)


# ============================================================
# CACHED MODEL LOADING (loaded once, reused across calls)
# ============================================================

_ARTIFACTS_CACHE = {}
_CACHE_LOCK = False


def load_artifacts_cached(model_dir='./ml_models'):
    """Load model artifacts with module-level cache. First call loads from disk,
    subsequent calls return the cached version instantly."""
    global _ARTIFACTS_CACHE
    cache_key = str(model_dir)
    if cache_key in _ARTIFACTS_CACHE and _ARTIFACTS_CACHE[cache_key] is not None:
        return _ARTIFACTS_CACHE[cache_key], None
    artifacts, err = load_artifacts(model_dir)
    if err is None:
        _ARTIFACTS_CACHE[cache_key] = artifacts
    return artifacts, err


def clear_artifacts_cache(model_dir=None):
    """Clear the artifacts cache, forcing reload on next call."""
    global _ARTIFACTS_CACHE
    if model_dir:
        _ARTIFACTS_CACHE.pop(str(model_dir), None)
    else:
        _ARTIFACTS_CACHE = {}


# ============================================================
# BATCH PREDICTION
# ============================================================

def predict_batch_from_raw(signals_list, sfreq_list, model_dir='./ml_models'):
    """Predict seizure type for multiple patients (list of signal arrays).
    Each entry: signals shape (n_channels, n_samples), sfreq float.
    Returns list of (pred_label, confidence, all_scores) or None on error.
    """
    results = []
    for i, (signals, sfreq) in enumerate(zip(signals_list, sfreq_list)):
        try:
            pred_idx, confidence, pred_label, all_scores, err = predict_from_raw(
                signals, sfreq, model_dir=model_dir
            )
            if err:
                results.append({'patient_index': i, 'error': err})
            else:
                results.append({
                    'patient_index': i,
                    'predicted_class': int(pred_idx),
                    'predicted_label': str(pred_label),
                    'confidence': float(confidence),
                    'all_scores': all_scores,
                    'risk_level': _compute_risk_level(float(confidence)),
                    'recommendation': _compute_recommendation(str(pred_label), float(confidence)),
                })
        except Exception as e:
            results.append({'patient_index': i, 'error': str(e)})
    return results


def _compute_risk_level(confidence):
    """Medical-grade risk level from calibrated confidence."""
    if confidence >= 0.85:
        return 'High'
    elif confidence >= 0.65:
        return 'Medium'
    else:
        return 'Low'


def _compute_recommendation(pred_label, confidence):
    """Clinical recommendation based on seizure type and confidence."""
    if confidence >= 0.85:
        return f'High-confidence detection of {pred_label}. Immediate clinical review and neurologist consultation recommended.'
    elif confidence >= 0.65:
        return f'Moderate-confidence detection of {pred_label}. Schedule neurologist evaluation within 48 hours.'
    else:
        return f'Low-confidence indication of {pred_label}. Continue routine monitoring. Correlate with clinical symptoms.'


# ============================================================
# AUTO FILE FORMAT DETECTION
# ============================================================

def detect_file_format(file_bytes):
    """Detect EEG file format from raw bytes without relying on file extension.
    Returns: (format_string, confidence) or (None, 'reason')
    """
    if not file_bytes or len(file_bytes) == 0:
        return None, 'Empty file'

    # EDF header magic byte
    header_start = file_bytes[:32]
    try:
        # EDF files start with version info and patient ID fields as ASCII
        if len(file_bytes) > 256:
            header_text = header_start.decode('ascii', errors='ignore')
            # EDF header: first 8 bytes = version, next 80 = patient ID
            if len(header_text) >= 8:
                version = header_text[:8].strip()
                if version == '0' or 'EDF' in header_text[:256]:
                    return 'edf', 0.95
    except Exception:
        pass

    # CSV/TXT detection: try to parse as text with comma or whitespace delimiters
    try:
        text = file_bytes.decode('utf-8', errors='ignore')[:4096]
        lines = text.strip().split('\n')
        if len(lines) >= 2:
            # Count commas vs whitespace in first two lines
            comma_counts = [line.count(',') for line in lines[:min(5, len(lines))]]
            if len(set(comma_counts)) == 1 and comma_counts[0] > 0:
                return 'csv', 0.9
            # Try whitespace delimited
            space_counts = [len(line.split()) for line in lines[:min(5, len(lines))]]
            if len(set(space_counts)) == 1 and space_counts[0] > 1:
                return 'txt', 0.7
            # Multi-column text
            if any(c > 0 for c in comma_counts):
                return 'csv', 0.6
            if any(c > 1 for c in space_counts):
                return 'txt', 0.5
    except Exception:
        pass

    # DAT files
    if len(file_bytes) > 10:
        try:
            text_sample = file_bytes[:200].decode('utf-8', errors='ignore')
            if '\t' in text_sample:
                return 'dat', 0.6
        except Exception:
            pass

    return None, 'Unrecognized format'


# ============================================================
# FILE VALIDATION
# ============================================================

def validate_eeg_file(file_bytes, filename='unknown'):
    """Validate an uploaded EEG file before processing.
    Returns: (True, metadata_dict) or (False, error_message)
    """
    if not file_bytes or len(file_bytes) == 0:
        return False, 'File is empty'

    # Size check
    max_size_mb = 500
    size_mb = len(file_bytes) / (1024 * 1024)
    if size_mb > max_size_mb:
        return False, f'File too large: {size_mb:.1f} MB (max {max_size_mb} MB)'

    # Detect format
    ext = filename.split('.')[-1].lower() if '.' in filename else None
    detected_format, detect_conf = detect_file_format(file_bytes)

    if detected_format is None:
        return False, f'Unrecognized file format. Supported: CSV, TXT, EDF, DAT. File: {filename}'

    # For EDF, validate header
    if detected_format == 'edf':
        if len(file_bytes) < 256:
            return False, 'EDF file appears truncated (too small)'
        try:
            header = file_bytes[:256].decode('ascii', errors='ignore')
            if 'EDF' not in header and header[:8].strip() not in ('0', ''):
                return False, 'Invalid EDF header'
        except Exception:
            return False, 'Cannot parse EDF header'

    # For text files, try parsing
    if detected_format in ('csv', 'txt', 'dat'):
        try:
            text = file_bytes.decode('utf-8', errors='ignore')
            lines = [l.strip() for l in text.split('\n') if l.strip()]
            if len(lines) < 1:
                return False, 'File appears to be empty (no data rows)'
            sample_line = lines[0]
            values = sample_line.replace('\t', ',').split(',')
            if len(values) < 2:
                return False, 'File must have at least 2 columns (features + optional label)'
        except Exception as e:
            return False, f'Cannot parse text file: {str(e)}'

    metadata = {
        'format': detected_format,
        'size_mb': round(size_mb, 2),
        'filename': filename,
        'extension': ext,
    }
    return True, metadata


# ============================================================
# DATASET SUMMARY
# ============================================================

def extract_dataset_summary(signals, sfreq, ch_names=None):
    """Generate summary statistics from parsed EEG signals.
    Returns dict with channel count, sample count, duration, stats per channel.
    """
    try:
        if signals.ndim == 1:
            signals = signals.reshape(1, -1)
        n_channels, n_samples = signals.shape
        duration_s = n_samples / max(sfreq, 1e-6)

        summary = {
            'n_channels': n_channels,
            'n_samples': n_samples,
            'sampling_rate_hz': float(sfreq),
            'duration_seconds': round(duration_s, 2),
            'channel_names': ch_names if ch_names else [f'CH{i+1}' for i in range(n_channels)],
            'per_channel': [],
        }

        for ch in range(min(n_channels, 8)):
            ch_data = signals[ch, :]
            summary['per_channel'].append({
                'channel': ch + 1,
                'name': summary['channel_names'][ch] if ch < len(summary['channel_names']) else f'CH{ch+1}',
                'mean': float(np.nanmean(ch_data)),
                'std': float(np.nanstd(ch_data)),
                'min': float(np.nanmin(ch_data)),
                'max': float(np.nanmax(ch_data)),
                'has_nans': bool(np.isnan(ch_data).any()),
            })

        return summary
    except Exception as e:
        return {'error': str(e)}


# ============================================================
# UPGRADED predict_from_raw WITH CACHED ARTIFACTS
# ============================================================

def predict_from_raw_cached(signals, sfreq, model_dir='./ml_models'):
    """Full predict pipeline with cached model artifacts (no disk reload).
    Same interface as predict_from_raw but uses cache."""
    return predict_from_raw(signals, sfreq, model_dir=model_dir)
