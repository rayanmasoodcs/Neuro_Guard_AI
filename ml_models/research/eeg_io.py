"""
NeuroGuard AI Research Pipeline — EEG I/O Module
=================================================
Provides dataset-specific readers that produce a documented
Canonical EEG Record (CER) for downstream processing.

Canonical EEG Record (CER) schema
-----------------------------------
{
    "dataset_id":    str,           # "chbmit" | "siena"
    "recording_id":  str,           # e.g. "chb01_03"
    "patient_id":    str,           # e.g. "chb01" | "PN00"
    "source_path":   str,           # absolute path to EDF file
    "sfreq":         float,         # sampling frequency in Hz AS READ FROM FILE
    "n_channels":    int,           # channel count after channel selection
    "ch_names":      list[str],     # selected channel labels
    "signals":       np.ndarray,    # shape (n_channels, n_samples), float32
    "duration_s":    float,         # total recording duration in seconds
    "seizures":      list[dict],    # [{"onset_s": float, "offset_s": float}]
    "label_type":    str,           # "binary" only at this stage
    "warnings":      list[str],     # non-fatal issues found during ingestion
}

Errors are raised as EEGIngestionError for hard failures.
Warnings are accumulated in record["warnings"] for soft issues.
"""

import os
import re
import struct
import datetime
import numpy as np
from typing import Optional

# ---------------------------------------------------------------------------
# CHANNEL CONSTANTS
# ---------------------------------------------------------------------------

# 10-20 International System electrode names common to BOTH datasets.
# CHB-MIT uses bipolar PAIRS (e.g. "FP1-F7"); Siena uses monopolar labels (e.g. "Fp1").
# For Mode A (within-dataset), we preserve each dataset's native channels.
# For Mode B (cross-dataset), we map to this common monopolar subset.
COMMON_10_20_MONOPOLAR = frozenset([
    "FP1","FP2","F3","F4","C3","C4","P3","P4","O1","O2",
    "F7","F8","T3","T4","T5","T6","FZ","CZ","PZ",
    # Aliases used in some EDF files
    "Fp1","Fp2","Fz","Cz","Pz","T7","T8","P7","P8",
])

# CHB-MIT bipolar pairs that can be converted to monopolar difference.
CHBMIT_BIPOLAR_TO_MONOPOLAR = {
    "FP1-F7": ("FP1", "F7"),
    "F7-T7":  ("F7",  "T7"),
    "T7-P7":  ("T7",  "P7"),
    "P7-O1":  ("P7",  "O1"),
    "FP1-F3": ("FP1", "F3"),
    "F3-C3":  ("F3",  "C3"),
    "C3-P3":  ("C3",  "P3"),
    "P3-O1":  ("P3",  "O1"),
    "FP2-F4": ("FP2", "F4"),
    "F4-C4":  ("F4",  "C4"),
    "C4-P4":  ("C4",  "P4"),
    "P4-O2":  ("P4",  "O2"),
    "FP2-F8": ("FP2", "F8"),
    "F8-T8":  ("F8",  "T8"),
    "T8-P8":  ("T8",  "P8"),
    "P8-O2":  ("P8",  "O2"),
    "FZ-CZ":  ("FZ",  "CZ"),
    "CZ-PZ":  ("CZ",  "PZ"),
}

# Siena non-EEG channels to always exclude
SIENA_EXCLUDE_CHANNELS = frozenset(["EKG 1", "EKG 2", "EKG1", "EKG2"])


class EEGIngestionError(Exception):
    """Hard failure during EEG ingestion. Recording is unusable."""


# ---------------------------------------------------------------------------
# LOW-LEVEL EDF PARSER (no external dependencies)
# ---------------------------------------------------------------------------

def _read_edf_header(edf_path: str) -> dict:
    """
    Parse EDF file header and return per-signal metadata.
    Implements the EDF specification (Kemp et al., 1992).
    Does NOT load signal data — header only.
    """
    with open(edf_path, "rb") as f:
        raw_header = f.read(256)

    try:
        n_signals = int(raw_header[252:256].decode("ascii").strip())
    except (ValueError, UnicodeDecodeError) as e:
        raise EEGIngestionError(f"Cannot parse EDF signal count from header: {e}")

    if n_signals <= 0 or n_signals > 512:
        raise EEGIngestionError(f"Implausible EDF signal count: {n_signals}")

    n_signal_header_bytes = n_signals * 256
    with open(edf_path, "rb") as f:
        f.read(256)  # skip main header
        signal_header_raw = f.read(n_signal_header_bytes)

    def _field(block_size, signal_idx, field_idx, field_sizes):
        offset = sum(field_sizes[:field_idx]) * n_signals + signal_idx * field_sizes[field_idx]
        return block_size[offset: offset + field_sizes[field_idx]].decode("ascii", errors="ignore").strip()

    field_sizes = [16, 80, 8, 8, 8, 8, 8, 80, 8, 32]
    ch_names, transducers, phys_dim = [], [], []
    phys_mins, phys_maxs, dig_mins, dig_maxs = [], [], [], []
    prefilter, n_samples_per_record = [], []

    for i in range(n_signals):
        ch_names.append(_field(signal_header_raw, i, 0, field_sizes))
        transducers.append(_field(signal_header_raw, i, 1, field_sizes))
        phys_dim.append(_field(signal_header_raw, i, 2, field_sizes))
        try:
            phys_mins.append(float(_field(signal_header_raw, i, 3, field_sizes)))
            phys_maxs.append(float(_field(signal_header_raw, i, 4, field_sizes)))
            dig_mins.append(float(_field(signal_header_raw, i, 5, field_sizes)))
            dig_maxs.append(float(_field(signal_header_raw, i, 6, field_sizes)))
        except ValueError:
            phys_mins.append(-1.0); phys_maxs.append(1.0)
            dig_mins.append(-32768.0); dig_maxs.append(32767.0)
        prefilter.append(_field(signal_header_raw, i, 7, field_sizes))
        try:
            n_samples_per_record.append(int(_field(signal_header_raw, i, 8, field_sizes)))
        except ValueError:
            n_samples_per_record.append(256)

    # Parse main header fields
    version        = raw_header[0:8].decode("ascii", errors="ignore").strip()
    local_patient  = raw_header[8:88].decode("ascii", errors="ignore").strip()
    local_recording= raw_header[88:168].decode("ascii", errors="ignore").strip()
    start_date_str = raw_header[168:176].decode("ascii", errors="ignore").strip()
    start_time_str = raw_header[176:184].decode("ascii", errors="ignore").strip()
    n_header_bytes = int(raw_header[184:192].decode("ascii", errors="ignore").strip() or "0")
    n_records      = int(raw_header[236:244].decode("ascii", errors="ignore").strip() or "-1")
    record_duration= float(raw_header[244:252].decode("ascii", errors="ignore").strip() or "1")

    # Infer sfreq from first EEG channel (samples/record / record_duration)
    sfreq = n_samples_per_record[0] / record_duration if record_duration > 0 else 256.0

    return {
        "version":        version,
        "local_patient":  local_patient,
        "local_recording":local_recording,
        "start_date":     start_date_str,
        "start_time":     start_time_str,
        "n_records":      n_records,
        "record_duration":record_duration,
        "n_signals":      n_signals,
        "ch_names":       ch_names,
        "phys_min":       phys_mins,
        "phys_max":       phys_maxs,
        "dig_min":        dig_mins,
        "dig_max":        dig_maxs,
        "n_samples_per_record": n_samples_per_record,
        "sfreq":          sfreq,
        "n_header_bytes": n_header_bytes,
    }


def _read_edf_signals(edf_path: str, hdr: dict,
                       channel_indices: Optional[list] = None) -> np.ndarray:
    """
    Load EDF signal data for selected channel indices.
    Returns ndarray shape (n_selected_channels, n_total_samples), float32.
    Physical units applied via gain/offset from header.
    """
    n_signals   = hdr["n_signals"]
    n_records   = hdr["n_records"]
    n_spr       = hdr["n_samples_per_record"]    # samples per record per channel
    n_hdr_bytes = hdr["n_header_bytes"]
    phys_min    = np.array(hdr["phys_min"], dtype=np.float64)
    phys_max    = np.array(hdr["phys_max"], dtype=np.float64)
    dig_min     = np.array(hdr["dig_min"], dtype=np.float64)
    dig_max     = np.array(hdr["dig_max"], dtype=np.float64)

    gain   = (phys_max - phys_min) / (dig_max - dig_min)
    offset = phys_max / gain - dig_max

    if channel_indices is None:
        channel_indices = list(range(n_signals))

    total_samples = [n_spr[i] * n_records for i in range(n_signals)]
    buffers = {i: np.empty(total_samples[i], dtype=np.float32)
               for i in channel_indices}
    record_sample_pos = {i: 0 for i in channel_indices}

    bytes_per_record = sum(n_spr[i] * 2 for i in range(n_signals))

    with open(edf_path, "rb") as f:
        f.seek(n_hdr_bytes)
        for _ in range(n_records):
            for sig_idx in range(n_signals):
                raw_bytes = f.read(n_spr[sig_idx] * 2)
                if sig_idx not in channel_indices:
                    continue
                n = n_spr[sig_idx]
                raw_int = np.frombuffer(raw_bytes, dtype=np.int16).astype(np.float64)
                physical = (raw_int + offset[sig_idx]) * gain[sig_idx]
                pos = record_sample_pos[sig_idx]
                buffers[sig_idx][pos:pos + n] = physical.astype(np.float32)
                record_sample_pos[sig_idx] += n

    # Stack in channel_indices order
    result = np.vstack([buffers[i] for i in channel_indices])  # (n_ch, n_samples)
    return result


# ---------------------------------------------------------------------------
# ANNOTATION PARSERS
# ---------------------------------------------------------------------------

def _parse_chbmit_summary(summary_path: str) -> dict:
    """
    Parse CHB-MIT *-summary.txt file.
    Returns dict keyed by filename: {num_seizures, seizures: [(onset_s, offset_s)]}
    """
    if not os.path.exists(summary_path):
        return {}

    with open(summary_path, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    info = {}
    current_file = None
    for line in lines:
        line = line.strip()
        if line.startswith("File Name:"):
            current_file = line.split(":")[-1].strip()
            info[current_file] = {"num_seizures": 0, "seizures": []}
        elif current_file and "Number of Seizures in File:" in line:
            try:
                info[current_file]["num_seizures"] = int(line.split(":")[-1].strip())
            except ValueError:
                pass
        elif current_file and "Seizure" in line and "Start Time:" in line:
            m = re.search(r"(\d+)", line.split(":")[-1])
            if m:
                info[current_file]["_onset"] = int(m.group(1))
        elif current_file and "Seizure" in line and "End Time:" in line:
            m = re.search(r"(\d+)", line.split(":")[-1])
            if m and "_onset" in info[current_file]:
                info[current_file]["seizures"].append(
                    {"onset_s": float(info[current_file].pop("_onset")),
                     "offset_s": float(m.group(1))}
                )
    return info


def _parse_siena_seizure_file(seizure_txt_path: str, recording_start_time: str = "") -> dict:
    """
    Parse Siena 'Seizures-list-PN*.txt' file.
    Returns dict keyed by EDF basename: {seizures: [(onset_s, offset_s)]}
    Clock-time strings (HH.MM.SS) are converted to second offsets relative to
    the EDF recording start time extracted from the EDF header.
    """
    if not os.path.exists(seizure_txt_path):
        return {}

    with open(seizure_txt_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    def clock_to_s(t_str: str) -> Optional[float]:
        """Convert HH.MM.SS to seconds."""
        parts = t_str.strip().replace(":", ".").split(".")
        try:
            if len(parts) == 3:
                return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])
            elif len(parts) == 2:
                return int(parts[0]) * 60 + int(parts[1])
        except ValueError:
            return None
        return None

    info = {}
    current_file = None
    reg_start_s  = None

    for line in content.splitlines():
        line = line.strip()
        if line.startswith("File name:") or line.startswith("File Name:"):
            current_file = line.split(":")[-1].strip()
            info.setdefault(current_file, {"seizures": []})
            reg_start_s = None
        elif current_file and ("Registration start time:" in line or "Reg. start time:" in line):
            t_str = line.split(":", 1)[-1].strip()
            reg_start_s = clock_to_s(t_str)
        elif current_file and "Seizure start time:" in line:
            t_str = line.split(":", 1)[-1].strip()
            onset_abs = clock_to_s(t_str)
            if onset_abs is not None and reg_start_s is not None:
                onset_rel = onset_abs - reg_start_s
                # Handle midnight rollover
                if onset_rel < 0:
                    onset_rel += 86400
                info[current_file]["_onset_rel"] = onset_rel
        elif current_file and "Seizure end time:" in line:
            t_str = line.split(":", 1)[-1].strip()
            offset_abs = clock_to_s(t_str)
            if offset_abs is not None and reg_start_s is not None:
                offset_rel = offset_abs - reg_start_s
                if offset_rel < 0:
                    offset_rel += 86400
                if "_onset_rel" in info[current_file]:
                    onset_rel = info[current_file].pop("_onset_rel")
                    if offset_rel > onset_rel:
                        info[current_file]["seizures"].append(
                            {"onset_s": float(onset_rel), "offset_s": float(offset_rel)}
                        )
    return info


# ---------------------------------------------------------------------------
# DATASET-SPECIFIC READERS
# ---------------------------------------------------------------------------

class CHBMITReader:
    """
    Dataset-specific reader for the CHB-MIT Scalp EEG Database.

    Produces a Canonical EEG Record (CER) from a single EDF file.
    Reads annotations from the per-patient summary text file.
    """

    DATASET_ID = "chbmit"
    NATIVE_SFREQ = 256.0
    NATIVE_CHANNELS = 23

    def __init__(self, data_root: str):
        """
        Args:
            data_root: Root directory where CHB-MIT data is stored.
                       Expected structure: data_root/chb01/chb01_03.edf
        """
        self.data_root = os.path.abspath(data_root)

    def _get_patient_id(self, edf_path: str) -> str:
        basename = os.path.basename(edf_path)
        m = re.match(r"(chb\d+)_", basename)
        return m.group(1) if m else os.path.basename(os.path.dirname(edf_path))

    def _get_summary_path(self, edf_path: str, patient_id: str) -> str:
        # Try nested layout first: data_root/chb01/chb01-summary.txt
        nested = os.path.join(self.data_root, patient_id, f"{patient_id}-summary.txt")
        if os.path.exists(nested):
            return nested
        # Fall back to flat layout: data_root/chb01-summary.txt (or EDF sibling)
        flat_root = os.path.join(self.data_root, f"{patient_id}-summary.txt")
        if os.path.exists(flat_root):
            return flat_root
        # Also try same directory as the EDF file itself
        sibling = os.path.join(os.path.dirname(edf_path), f"{patient_id}-summary.txt")
        if os.path.exists(sibling):
            return sibling
        return nested  # return canonical nested path for warning message

    def read(self, edf_path: str) -> dict:
        """
        Read a CHB-MIT EDF file and return a Canonical EEG Record.
        """
        warnings = []

        # --- Validate file exists ---
        if not os.path.exists(edf_path):
            raise EEGIngestionError(f"EDF file not found: {edf_path}")
        if os.path.getsize(edf_path) < 512:
            raise EEGIngestionError(f"File too small to be valid EDF: {edf_path}")

        # --- Read EDF header ---
        hdr = _read_edf_header(edf_path)
        patient_id = self._get_patient_id(edf_path)
        recording_id = os.path.splitext(os.path.basename(edf_path))[0]

        # --- Validate sampling rate ---
        if abs(hdr["sfreq"] - self.NATIVE_SFREQ) > 1.0:
            warnings.append(
                f"Unexpected sampling rate {hdr['sfreq']} Hz (expected {self.NATIVE_SFREQ} Hz). "
                "Recording retained but must be reviewed before use."
            )

        # --- Channel selection: keep all EEG channels (exclude non-EEG by label) ---
        all_ch = hdr["ch_names"]
        selected_idx = []
        selected_names = []
        excluded_names = []
        for i, ch in enumerate(all_ch):
            ch_upper = ch.upper().strip()
            # Exclude obvious non-EEG channels
            if any(kw in ch_upper for kw in ["ECG", "EKG", "EMG", "EOG", "MARK", "STIM", "EVENT", "DC"]):
                excluded_names.append(ch)
            else:
                selected_idx.append(i)
                selected_names.append(ch)

        if excluded_names:
            warnings.append(f"Excluded non-EEG channels: {excluded_names}")
        if len(selected_idx) == 0:
            raise EEGIngestionError(f"No EEG channels remain after filtering: {edf_path}")

        # --- Load signal data ---
        signals = _read_edf_signals(edf_path, hdr, channel_indices=selected_idx)
        n_samples = signals.shape[1]
        duration_s = n_samples / hdr["sfreq"]

        # --- Signal quality checks ---
        if n_samples == 0:
            raise EEGIngestionError(f"Signal array is empty: {edf_path}")
        channel_vars = np.var(signals, axis=1)
        zero_var_channels = [selected_names[i] for i, v in enumerate(channel_vars) if v < 1e-12]
        if zero_var_channels:
            warnings.append(f"Zero-variance (flat) channels detected: {zero_var_channels}")

        # --- Load annotations ---
        summary_path = self._get_summary_path(edf_path, patient_id)
        file_annotations = _parse_chbmit_summary(summary_path)
        edf_basename = os.path.basename(edf_path)
        seizure_list = []
        if edf_basename in file_annotations:
            raw_seizures = file_annotations[edf_basename].get("seizures", [])
            for sz in raw_seizures:
                if sz["onset_s"] < 0 or sz["offset_s"] > duration_s:
                    warnings.append(
                        f"Seizure window [{sz['onset_s']}s–{sz['offset_s']}s] "
                        f"partially outside recording duration {duration_s:.1f}s. Clipped."
                    )
                    sz = {
                        "onset_s": max(0.0, sz["onset_s"]),
                        "offset_s": min(duration_s, sz["offset_s"])
                    }
                if sz["offset_s"] > sz["onset_s"]:
                    seizure_list.append(sz)
        elif not os.path.exists(summary_path):
            warnings.append(f"Summary file not found: {summary_path}. Assuming 0 seizures.")

        return {
            "dataset_id":    self.DATASET_ID,
            "recording_id":  recording_id,
            "patient_id":    patient_id,
            "source_path":   os.path.abspath(edf_path),
            "sfreq":         hdr["sfreq"],
            "n_channels":    len(selected_idx),
            "ch_names":      selected_names,
            "signals":       signals,
            "duration_s":    duration_s,
            "seizures":      seizure_list,
            "label_type":    "binary",
            "warnings":      warnings,
        }


class SienaReader:
    """
    Dataset-specific reader for the Siena Scalp EEG Dataset.

    Produces a Canonical EEG Record from a single EDF file.
    Reads annotations from the per-patient Seizures-list-PN*.txt file.
    """

    DATASET_ID = "siena"
    NATIVE_SFREQ = 512.0
    EXCLUDE_CHANNELS = SIENA_EXCLUDE_CHANNELS

    def __init__(self, data_root: str):
        self.data_root = os.path.abspath(data_root)

    def _get_patient_id(self, edf_path: str) -> str:
        return os.path.basename(os.path.dirname(edf_path))

    def _get_seizure_file(self, patient_id: str) -> str:
        return os.path.join(self.data_root, patient_id, f"Seizures-list-{patient_id}.txt")

    def read(self, edf_path: str) -> dict:
        warnings = []

        if not os.path.exists(edf_path):
            raise EEGIngestionError(f"EDF file not found: {edf_path}")
        if os.path.getsize(edf_path) < 512:
            raise EEGIngestionError(f"File too small to be valid EDF: {edf_path}")

        hdr = _read_edf_header(edf_path)
        patient_id   = self._get_patient_id(edf_path)
        recording_id = os.path.splitext(os.path.basename(edf_path))[0]

        if abs(hdr["sfreq"] - self.NATIVE_SFREQ) > 5.0:
            warnings.append(
                f"Unexpected Siena sampling rate {hdr['sfreq']} Hz "
                f"(expected {self.NATIVE_SFREQ} Hz). "
                "Will attempt resampling in preprocessing step."
            )

        # Channel selection: exclude EKG and other non-EEG
        all_ch = hdr["ch_names"]
        selected_idx, selected_names, excluded_names = [], [], []
        for i, ch in enumerate(all_ch):
            ch_clean = ch.strip()
            if ch_clean in self.EXCLUDE_CHANNELS or ch_clean.upper() in {
                "EKG 1","EKG 2","EKG1","EKG2","ECG","EMG","EOG"
            }:
                excluded_names.append(ch_clean)
            else:
                selected_idx.append(i)
                selected_names.append(ch_clean)

        if excluded_names:
            warnings.append(f"Excluded non-EEG channels: {excluded_names}")
        if not selected_idx:
            raise EEGIngestionError(f"No EEG channels remain after filtering: {edf_path}")

        signals = _read_edf_signals(edf_path, hdr, channel_indices=selected_idx)
        n_samples  = signals.shape[1]
        duration_s = n_samples / hdr["sfreq"]

        if n_samples == 0:
            raise EEGIngestionError(f"Empty signal: {edf_path}")

        channel_vars = np.var(signals, axis=1)
        flat_ch = [selected_names[i] for i, v in enumerate(channel_vars) if v < 1e-12]
        if flat_ch:
            warnings.append(f"Zero-variance channels: {flat_ch}")

        # Annotations
        sz_file = self._get_seizure_file(patient_id)
        file_annotations = _parse_siena_seizure_file(sz_file)
        edf_basename = os.path.basename(edf_path)
        seizure_list = []
        if edf_basename in file_annotations:
            for sz in file_annotations[edf_basename].get("seizures", []):
                if sz["offset_s"] > sz["onset_s"]:
                    seizure_list.append(sz)
        elif not os.path.exists(sz_file):
            warnings.append(f"Seizure list file not found: {sz_file}. Assuming 0 seizures.")

        return {
            "dataset_id":    self.DATASET_ID,
            "recording_id":  recording_id,
            "patient_id":    patient_id,
            "source_path":   os.path.abspath(edf_path),
            "sfreq":         hdr["sfreq"],
            "n_channels":    len(selected_idx),
            "ch_names":      selected_names,
            "signals":       signals,
            "duration_s":    duration_s,
            "seizures":      seizure_list,
            "label_type":    "binary",
            "warnings":      warnings,
        }


def read_eeg_file(edf_path: str, dataset_id: str,
                  data_root: str) -> dict:
    """
    Factory function. Returns a Canonical EEG Record.
    Args:
        edf_path:   Path to a single EDF file.
        dataset_id: "chbmit" or "siena".
        data_root:  Root directory for the dataset.
    """
    if dataset_id == "chbmit":
        return CHBMITReader(data_root).read(edf_path)
    elif dataset_id == "siena":
        return SienaReader(data_root).read(edf_path)
    else:
        raise EEGIngestionError(
            f"Unknown dataset_id '{dataset_id}'. Supported: 'chbmit', 'siena'."
        )
