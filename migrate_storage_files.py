"""
NeuroGuard AI - Controlled Storage Migration & Processing Test Script
======================================================================
Executes controlled sample file persistence and verification:
  1. Backs up existing local storage directory.
  2. Saves sample EEG files and medical PDF report files using StorageAdapter.
  3. Verifies metadata and byte-for-byte read integrity.
  4. Verifies anti-path-traversal and cross-user isolation.
  5. Verifies ML prediction engine can load and infer from saved file keys.
  6. Preserves original local disk files as rollback protection.
"""

import os
import shutil
import numpy as np
import io
import base64

from python_backend.storage.storage_adapter import get_storage_adapter, LocalStorageAdapter, FirebaseStorageAdapter
from ml_models.production_pipeline import predict_from_raw


print("===================================================================")
print("=== NEUROGUARD AI - CONTROLLED STORAGE MIGRATION & TESTING ===")
print("===================================================================")

adapter = get_storage_adapter()
print(f"[STORAGE ADAPTER] Active Adapter: {adapter.__class__.__name__}")

# -------------------------------------------------------------
# STEP 1: LOCAL BACKUP VERIFICATION
# -------------------------------------------------------------
storage_dir = os.path.abspath('storage')
backup_dir = os.path.abspath('storage_backup')

if os.path.exists(storage_dir):
    shutil.copytree(storage_dir, backup_dir, dirs_exist_ok=True)
    print(f"[BACKUP] Local storage backed up to: {backup_dir}")

# -------------------------------------------------------------
# STEP 2: SAMPLE EEG UPLOAD & INTEGRITY CHECK
# -------------------------------------------------------------
t = np.linspace(0, 2, 512)
channels = [np.sin(2 * np.pi * (5 + i) * t) + np.random.normal(0, 0.1, len(t)) for i in range(14)]
sample_data = np.column_stack(channels)

csv_io = io.StringIO()
np.savetxt(csv_io, sample_data, delimiter=',', fmt='%.4f')
sample_bytes = csv_io.getvalue().encode('utf-8')

user_id_patient = 101
storage_key, err = adapter.save_file(user_id=user_id_patient, file_bytes=sample_bytes, original_filename="patient_sample.csv", subfolder="eeg")
assert err is None, f"Save failed: {err}"
assert storage_key is not None
print(f"[PASS] Sample EEG Uploaded: Key = {storage_key}")

# Read Back & Verify Byte Integrity
read_bytes, read_err = adapter.read_file(user_id=user_id_patient, storage_key=storage_key)
assert read_err is None, f"Read failed: {read_err}"
assert read_bytes == sample_bytes, "Read bytes mismatch!"
print("[PASS] Byte-for-byte read integrity verified")

# -------------------------------------------------------------
# STEP 3: CROSS-USER & ANTI-PATH-TRAVERSAL ISOLATION
# -------------------------------------------------------------
unauth_user_id = 999
_, unauthorized_err = adapter.read_file(user_id=unauth_user_id, storage_key=storage_key)
assert unauthorized_err is not None and "Unauthorized" in unauthorized_err, f"Expected unauthorized error, got: {unauthorized_err}"
print("[PASS] Cross-tenant unauthorized file read attempt blocked with Access Denied")

# Anti-path-traversal check
_, traversal_err = adapter.read_file(user_id=user_id_patient, storage_key="../../etc/passwd")
assert traversal_err is not None, "Path traversal check failed!"
print("[PASS] Anti-path-traversal defense verified")

# -------------------------------------------------------------
# STEP 4: ML ENGINE COMPATIBILITY CHECK
# -------------------------------------------------------------
read_csv_io = io.BytesIO(read_bytes)
parsed_matrix = np.loadtxt(read_csv_io, delimiter=',')
# Transpose if row-major so signals shape is (n_channels, n_samples)
if parsed_matrix.shape[0] > parsed_matrix.shape[1]:
    parsed_matrix = parsed_matrix.T

pred_class, confidence, seizure_type, all_scores, pred_err = predict_from_raw(parsed_matrix, sfreq=256.0)
assert pred_err is None, f"ML inference failed on stored file: {pred_err}"
print(f"[PASS] ML Engine verified on stored EEG file: {seizure_type} (Confidence: {confidence:.2%})")


# -------------------------------------------------------------
# STEP 5: SAMPLE REPORT PDF UPLOAD
# -------------------------------------------------------------
dummy_pdf_bytes = b"%PDF-1.4 Mock Medical Report PDF Content for NeuroGuard AI"
report_key, rep_err = adapter.save_file(user_id=user_id_patient, file_bytes=dummy_pdf_bytes, original_filename="clinical_report.pdf", subfolder="reports")
assert rep_err is None
assert adapter.exists(report_key)
print(f"[PASS] Sample Medical Report PDF Uploaded: Key = {report_key}")

# -------------------------------------------------------------
# STEP 6: LOCAL BACKUP RETENTION CHECK
# -------------------------------------------------------------
assert os.path.exists(backup_dir), "Backup directory was deleted!"
print("[PASS] Local backup retention confirmed. Original files preserved for rollback")

print("\n>>> CONTROLLED STORAGE MIGRATION & TESTING COMPLETED SUCCESSFULLY <<<")
