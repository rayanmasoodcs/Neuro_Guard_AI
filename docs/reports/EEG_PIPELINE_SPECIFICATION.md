# EEG Pipeline Specification — NeuroGuard AI

**Version:** 1.0  
**Date:** September 3, 2026  
**Status:** Approved & Verified (Mission 23)  
**Implementation Package:** [`ml_models/research/`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/ml_models/research/)

---

## 1. SUPPORTED DATASETS & FILE FORMATS

### 1.1 Supported Datasets
1. **CHB-MIT Scalp EEG Database** (`dataset_id: "chbmit"`)
   - Pediatric population (23 patients, ages 1.5–22)
   - Sampling Frequency: 256 Hz
   - Channels: 23 Bipolar Pairs
   - Annotations: Relative second offsets in summary files
2. **Siena Scalp EEG Dataset** (`dataset_id: "siena"`)
   - Adult population (14 patients, ages 20–71)
   - Sampling Frequency: 512 Hz
   - Channels: 29 Monopolar EEG + 2 EKG
   - Annotations: Clock-time timestamps (`HH.MM.SS`) in seizure lists

### 1.2 Supported & Verified File Formats
- **European Data Format (`.edf`)**: Native binary header parsing and per-channel signal reading implemented in pure Python (`ml_models/research/eeg_io.py`) without third-party C library bindings.
- **Summary Annotation Files (`.txt`)**:
  - CHB-MIT format (`chbXX-summary.txt`): Seconds offset parser.
  - Siena format (`Seizures-list-PNXX.txt`): Clock-time parser with relative start time alignment.

---

## 2. INGESTION ARCHITECTURE

The pipeline ingests raw EDF files and converts them into a documented **Canonical EEG Record (CER)** structure before any filtering, windowing, or feature extraction.

```
RAW EDF FILE + ANNOTATION TXT
         │
         ▼
 ┌───────────────────────────┐
 │ Dataset Adapter          │
 │ (CHBMITReader/SienaReader)│
 └─────────────┬─────────────┘
               │
               ▼
 ┌───────────────────────────┐
 │ Metadata & Quality Check  │
 │ (Channels, Sfreq, NaN/Var)│
 └─────────────┬─────────────┘
               │
               ▼
 ┌───────────────────────────┐
 │ Canonical EEG Record      │
 │ (CER Python Dictionary)   │
 └─────────────┬─────────────┘
               │
               ▼
 ┌───────────────────────────┐
 │ Preprocessing Engine      │
 │ (Clip -> Resample -> BP)  │
 └─────────────┬─────────────┘
               │
               ▼
 ┌───────────────────────────┐
 │ Segmentation Module       │
 │ (4s Windows, 50% Overlap) │
 └─────────────┬─────────────┘
               │
      ┌────────┴────────┐
      ▼                 ▼
 Classical ML      Raw Sequence
 Feature Matrix    Window Array
 (38 Features)     (N, Ch, Samples)
```

---

## 3. METADATA SCHEMA & CANONICAL EEG RECORD (CER)

Every ingested EEG file produces a CER object with the following fields:

```python
CER_SCHEMA = {
    "dataset_id":    str,        # "chbmit" | "siena"
    "recording_id":  str,        # e.g., "chb01_03"
    "patient_id":    str,        # e.g., "chb01"
    "source_path":   str,        # Absolute path to source EDF file
    "sfreq":         float,      # Sampling frequency as read from EDF header (e.g. 256.0)
    "n_channels":    int,        # Number of active EEG channels retained
    "ch_names":      list[str],  # Selected channel labels
    "signals":       np.ndarray, # Shape (n_channels, n_samples), float32
    "duration_s":    float,      # Total duration in seconds
    "seizures":      list[dict], # [{"onset_s": float, "offset_s": float}]
    "label_type":    str,        # "binary"
    "warnings":      list[str]   # List of non-fatal ingestion warnings
}
```

---

## 4. CHANNEL STRATEGY

### 4.1 Within-Dataset Mode (Mode A)
- **CHB-MIT**: Retains all 23 native bipolar montage channels (e.g., `FP1-F7`, `F7-T7`, `T7-P7`). Non-EEG channels (ECG/EMG/Stim) are automatically excluded by string matching.
- **Siena**: Retains 29 monopolar EEG channels. Non-EEG channels (`EKG 1`, `EKG 2`) are strictly excluded.

### 4.2 Cross-Dataset Mode (Mode B)
- Signals are mapped to the 10-20 International System common subset: `FP1, FP2, F3, F4, C3, C4, P3, P4, O1, O2, F7, F8, T3, T4, T5, T6, FZ, CZ, PZ`.
- Bipolar CHB-MIT pairs are mapped or re-referenced to equivalent scalp regions.

---

## 5. SAMPLING RATE & RESAMPLING STRATEGY

- **Target Common Rate:** `256.0 Hz`
- **CHB-MIT (256 Hz):** Kept native (0 Hz resampling overhead).
- **Siena (512 Hz):** Resampled using integer polyphase resampling (`scipy.signal.resample_poly` with up=1, down=2).
- **Rationale:** Polyphase resampling applies an implicit anti-aliasing low-pass filter before decimation, preserving all frequency content up to the Nyquist limit of 128 Hz (well above the 70 Hz upper limit of clinical EEG).

---

## 6. PREPROCESSING PIPELINE

Preprocessing operations are versioned (`v1.0`) and logged per recording:

1. **Artifact Clipping (`artifact_clip_800uV`):** Amplitude hard-clipped at $\pm 800\,\mu\text{V}$ to prevent extreme pop/spike artifacts from corrupting normalization.
2. **Resampling (`resample_512Hz_to_256Hz_polyphase`):** Applied if source sampling rate deviates from 256 Hz.
3. **Bandpass Filtering (`bandpass_0.5_70.0Hz_butterworth4`):** 4th-order Butterworth bandpass filter ($0.5\,\text{Hz} - 70.0\,\text{Hz}$) applied zero-phase (`filtfilt`). Removes slow DC baseline drift ($<0.5\,\text{Hz}$) while preserving ictal fast oscillations.
4. **Notch Filtering (`notch_50Hz_60Hz_Q30`):** Narrow notch filter ($Q=30$) at $50\,\text{Hz}$ and $60\,\text{Hz}$ to eliminate powerline interference.
5. **Normalization:** Per-channel Z-score normalization is **NOT** applied to whole recordings during ingestion to prevent data leakage. Scalers are fitted exclusively on training splits.

---

## 7. SEGMENTATION & LABEL ASSIGNMENT RULES

- **Window Duration:** `4.0 seconds` ($1024$ samples at 256 Hz)
- **Window Step/Stride:** `2.0 seconds` (50% overlap for training)
- **Label Assignment Threshold (`SEIZURE_LABEL_THRESHOLD`):**
  - **Seizure (`label = 1`):** Window overlap with documented seizure interval $> 50\%$.
  - **Non-Seizure (`label = 0`):** Window overlap $= 0\%$.
  - **Transition Windows ($0\% < \text{overlap} \le 50\%$):** Excluded by default to prevent noisy boundary labels from corrupting model training.
- **Patient Provenance:** Every window explicitly retains `patient_id`, `recording_id`, and `dataset_id` to enable strict patient-independent splitting (`GroupKFold`).

---

## 8. FEATURE REPRESENTATIONS

### 8.1 Classical ML Representation
Feature matrix $X \in \mathbb{R}^{N \times 38}$ extracted per window:
- **Time-Domain (10):** Mean, Standard Deviation, Root Mean Square (RMS), Peak-to-Peak Amplitude, Line Length across channels (Mean & Std aggregation).
- **Hjorth Parameters (6):** Hjorth Activity, Mobility, and Complexity across channels (Mean & Std aggregation).
- **Spectral Domain (20):** Absolute and Relative Welch Power in Delta ($0.5-4\,\text{Hz}$), Theta ($4-8\,\text{Hz}$), Alpha ($8-13\,\text{Hz}$), Beta ($13-30\,\text{Hz}$), Gamma ($30-70\,\text{Hz}$) bands.
- **Complexity (2):** Spectral Entropy.

### 8.2 Raw Deep Learning Representation
Tensor $X_{\text{raw}} \in \mathbb{R}^{N \times C \times S}$, where $C=23$ channels and $S=1024$ samples per window ($4\,\text{s}$ at $256\,\text{Hz}$).

---

## 9. INFERENCE COMPATIBILITY RULES

Any runtime EEG file submitted for inference must pass the following validation checks prior to model evaluation:
1. **Format Validation:** Must be valid EDF structure or supported tabular format.
2. **Channel Validation:** Must contain recognizable EEG channels matchable to expected model channel inputs.
3. **Sampling Validation:** Sampling rate must be $\ge 100\,\text{Hz}$ (automatically resampled to 256 Hz if needed).
4. **Duration Validation:** Minimum signal length must be $\ge 4.0\,\text{s}$.
5. **Feature Versioning:** Feature extraction must match schema `v1.0` (38 features).

---

## 10. LIMITATIONS & KNOWN CONSTRAINTS

1. **Subtype Labels:** Neither CHB-MIT nor Siena summary files provide consistent multiclass seizure subtype annotations (e.g. Focal vs. Generalized). Task B (Multiclass) requires manual expert curation or external dataset additions.
2. **Pediatric vs. Adult Shift:** Cross-dataset evaluation (CHB-MIT $\rightarrow$ Siena) crosses age demographics (pediatric to adult), which naturally introduces domain shift in background EEG frequency.
3. **Memory Limits:** Large batch windowing of 900+ hours of continuous EEG requires lazy chunking or generator-based window loading to avoid RAM exhaustion on standard workstations.
