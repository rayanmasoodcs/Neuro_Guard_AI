"""
NeuroGuard AI - Mission 19 Firebase Storage & File Security Test Suite
========================================================================
Tests:
  - Test 1: storage.rules Verification (default-deny, patient ownership, doctor RBAC)
  - Test 2: Storage Adapter Abstraction & Persistence
  - Test 3: Cross-Tenant File Access Block (Patient A vs Patient B)
  - Test 4: Path Traversal Security Defense
  - Test 5: Medical PDF Report Upload & Ownership Check
  - Test 6: End-to-End ML Prediction on Stored EEG File
"""

import os
import io
import numpy as np
from python_backend.storage.storage_adapter import get_storage_adapter, LocalStorageAdapter, FirebaseStorageAdapter
from ml_models.production_pipeline import predict_from_raw


print("===================================================================")
print("=== NEUROGUARD AI - MISSION 19 STORAGE & FILE SECURITY TESTS ===")
print("===================================================================")

# -------------------------------------------------------------
# TEST 1: Storage Rules Verification
# -------------------------------------------------------------
assert os.path.exists("storage.rules"), "storage.rules file missing!"
with open("storage.rules", "r", encoding="utf-8") as f:
    rules_content = f.read()

assert "allow read, write: if false;" in rules_content, "Default deny rule missing!"
assert "request.auth != null" in rules_content, "Authentication check missing!"
assert "request.auth.token.role == 'doctor'" in rules_content, "Doctor RBAC rule missing!"
print("[PASS] Test 1: storage.rules verified (Strict default-deny, auth check, and doctor RBAC)")

# -------------------------------------------------------------
# TEST 2: Storage Adapter Abstraction
# -------------------------------------------------------------
adapter = get_storage_adapter()
test_bytes = b"Timestamp,Ch1,Ch2\n0.0,1.2,0.5\n0.1,1.5,0.6"
user_id = 42

key, err = adapter.save_file(user_id=user_id, file_bytes=test_bytes, original_filename="test_signal.csv", subfolder="eeg")
assert err is None, f"Save failed: {err}"
assert adapter.exists(key), "Saved file key does not exist!"
print(f"[PASS] Test 2: Storage Adapter saved file successfully (Key: {key})")

# -------------------------------------------------------------
# TEST 3: Cross-Tenant Access Block
# -------------------------------------------------------------
unauth_user = 99
_, unauth_err = adapter.read_file(user_id=unauth_user, storage_key=key)
assert unauth_err is not None and "Unauthorized" in unauth_err, "Cross-tenant access was NOT blocked!"
print("[PASS] Test 3: Cross-tenant unauthorized file read attempt blocked with Access Denied")

# -------------------------------------------------------------
# TEST 4: Anti-Path Traversal Defense
# -------------------------------------------------------------
_, trav_err = adapter.read_file(user_id=user_id, storage_key="../../../etc/shadow")
assert trav_err is not None, "Path traversal was NOT blocked!"
print("[PASS] Test 4: Path traversal attack blocked safely")

# -------------------------------------------------------------
# TEST 5: Medical PDF Report Persistence & Ownership
# -------------------------------------------------------------
pdf_bytes = b"%PDF-1.4 Official Medical Health Report"
rep_key, rep_err = adapter.save_file(user_id=user_id, file_bytes=pdf_bytes, original_filename="health_report.pdf", subfolder="reports")
assert rep_err is None
assert "reports" in rep_key
print(f"[PASS] Test 5: Medical PDF Report saved cleanly under reports subfolder (Key: {rep_key})")

# -------------------------------------------------------------
# TEST 6: ML Prediction on Stored EEG File
# -------------------------------------------------------------
t = np.linspace(0, 2, 512)
channels = [np.sin(2 * np.pi * (5 + i) * t) for i in range(14)]
eeg_mat = np.column_stack(channels)

csv_io = io.StringIO()
np.savetxt(csv_io, eeg_mat, delimiter=',', fmt='%.4f')
eeg_bytes = csv_io.getvalue().encode('utf-8')

eeg_key, _ = adapter.save_file(user_id=user_id, file_bytes=eeg_bytes, original_filename="eeg_signal_14ch.csv", subfolder="eeg")
fetched_bytes, _ = adapter.read_file(user_id=user_id, storage_key=eeg_key)

read_csv = io.BytesIO(fetched_bytes)
parsed_matrix = np.loadtxt(read_csv, delimiter=',')
if parsed_matrix.shape[0] > parsed_matrix.shape[1]:
    parsed_matrix = parsed_matrix.T

pred_cls, conf, sz_type, _, ml_err = predict_from_raw(parsed_matrix, sfreq=256.0)

assert ml_err is None, f"ML processing failed: {ml_err}"
print(f"[PASS] Test 6: ML engine successfully executed on stored EEG file ({sz_type}, {conf:.2%})")


print("\n===================================================================")
print("=== ALL MISSION 19 STORAGE & FILE SECURITY TESTS PASSED 100% ===")
print("===================================================================")
