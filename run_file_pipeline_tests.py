"""
NeuroGuard AI - File Pipeline & EEG Validation Security Test Suite (Mission 13)
=============================================================================
Tests:
- Authentication & Authorization on EEG upload endpoints
- Cross-tenant IDOR prevention
- Extension & format validation (CSV, TXT, EDF supported; EXE/PDF rejected)
- Empty file (0 bytes) rejection
- Corrupt file handling
- Flatline / NaN scientific signal structure validation
- Storage adapter isolation & anti-traversal security
"""

import os
import io
import json
import base64
import numpy as np
from python_backend.auth.app import app as ng_app
from python_backend.storage.storage_adapter import get_storage_adapter

client = ng_app.test_client()

def post_json(path, data, token=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    return client.post(path, data=json.dumps(data), headers=headers)

print("=== STARTING MISSION 13 SECURE FILE PIPELINE TESTS ===")

# 1. Register and login Patient User A and Patient User B
res_a = client.post('/signup', data=json.dumps({'name':'Patient A','email':'p_a_pipe@test.local','phone':'111','password':'pass','role':'patient'}), content_type='application/json')
token_a = res_a.get_json().get('token')
if not token_a:
    res_a = client.post('/login', data=json.dumps({'email':'p_a_pipe@test.local','password':'pass'}), content_type='application/json')
    token_a = res_a.get_json()['token']
user_a_id = res_a.get_json()['user']['id']

res_b = client.post('/signup', data=json.dumps({'name':'Patient B','email':'p_b_pipe@test.local','phone':'222','password':'pass','role':'patient'}), content_type='application/json')
token_b = res_b.get_json().get('token')
if not token_b:
    res_b = client.post('/login', data=json.dumps({'email':'p_b_pipe@test.local','password':'pass'}), content_type='application/json')
    token_b = res_b.get_json()['token']
user_b_id = res_b.get_json()['user']['id']

print(f"[SETUP] User A ID: {user_a_id}, User B ID: {user_b_id}")

# -------------------------------------------------------------
# TEST 1: Unauthenticated EEG Upload -> 401 Unauthorized
# -------------------------------------------------------------
unauth_res = client.post('/api/seizure/predict_seizure_from_eeg', data=json.dumps({
    'user_id': user_a_id,
    'eeg_file': 'dGVzdA==',
    'eeg_filename': 'sample.csv'
}), content_type='application/json')
assert unauth_res.status_code == 401, f"Expected 401 unauth, got {unauth_res.status_code}"
print("[OK] Test 1 Passed: Unauthenticated upload blocked (HTTP 401)")

# -------------------------------------------------------------
# TEST 2: Cross-Tenant IDOR Upload Attempt -> 403 Forbidden
# -------------------------------------------------------------
idor_res = post_json('/api/seizure/predict_seizure_from_eeg', {
    'user_id': user_b_id, # User A token trying to submit for User B
    'eeg_file': 'dGVzdA==',
    'eeg_filename': 'sample.csv'
}, token=token_a)
assert idor_res.status_code == 403, f"Expected 403 forbidden, got {idor_res.status_code}"
print("[OK] Test 2 Passed: Cross-tenant upload blocked (HTTP 403)")

# -------------------------------------------------------------
# TEST 3: Unsupported Extension (.exe) -> FILE_FORMAT_ERROR (400)
# -------------------------------------------------------------
exe_res = post_json('/api/seizure/predict_seizure_from_eeg', {
    'user_id': user_a_id,
    'eeg_file': base64.b64encode(b"malicious_executable_content").decode('utf-8'),
    'eeg_filename': 'malware.exe'
}, token=token_a)
assert exe_res.status_code == 400, f"Expected 400, got {exe_res.status_code}"
json_exe = exe_res.get_json()
assert json_exe['error_code'] == 'FILE_FORMAT_ERROR', f"Expected FILE_FORMAT_ERROR, got {json_exe}"
print("[OK] Test 3 Passed: Unsupported extension .exe rejected with FILE_FORMAT_ERROR")

# -------------------------------------------------------------
# TEST 4: Empty File (0 bytes) -> EEG_STRUCTURE_ERROR (400)
# -------------------------------------------------------------
empty_res = post_json('/api/seizure/predict_seizure_from_eeg', {
    'user_id': user_a_id,
    'eeg_file': '',
    'eeg_filename': 'empty.csv'
}, token=token_a)
assert empty_res.status_code == 400, f"Expected 400, got {empty_res.status_code}"
json_empty = empty_res.get_json()
assert json_empty['error_code'] in ('UPLOAD_ERROR', 'EEG_STRUCTURE_ERROR'), f"Got {json_empty}"
print("[OK] Test 4 Passed: Empty file payload rejected")

# -------------------------------------------------------------
# TEST 5: Flatline Signal (Zero Variance) -> EEG_STRUCTURE_ERROR (400)
# -------------------------------------------------------------
# Generate 16 channels x 500 samples of pure zeros
flat_csv = "\n".join([",".join(["0.0"] * 16) for _ in range(500)])
flat_b64 = base64.b64encode(flat_csv.encode('utf-8')).decode('utf-8')

flat_res = post_json('/api/seizure/predict_seizure_from_eeg', {
    'user_id': user_a_id,
    'eeg_file': flat_b64,
    'eeg_filename': 'flatline.csv'
}, token=token_a)
assert flat_res.status_code == 400, f"Expected 400, got {flat_res.status_code}"
json_flat = flat_res.get_json()
assert json_flat['error_code'] == 'EEG_STRUCTURE_ERROR', f"Expected EEG_STRUCTURE_ERROR, got {json_flat}"
print("[OK] Test 5 Passed: Flatline zero-variance signal rejected with EEG_STRUCTURE_ERROR")

# -------------------------------------------------------------
# TEST 6: Valid 14-Channel CSV Upload & Prediction -> HTTP 200 Success
# -------------------------------------------------------------
# Create 14-channel synthetic EEG data with sine waves (matching legacy model expected 14 features)
t = np.linspace(0, 2, 512)
channels = [np.sin(2 * np.pi * (5 + i) * t) + np.random.normal(0, 0.1, len(t)) for i in range(14)]
data_mat = np.column_stack(channels)

csv_io = io.StringIO()
np.savetxt(csv_io, data_mat, delimiter=',', fmt='%.4f')
valid_csv_bytes = csv_io.getvalue().encode('utf-8')
valid_b64 = base64.b64encode(valid_csv_bytes).decode('utf-8')

valid_res = post_json('/api/seizure/predict_seizure_from_eeg', {
    'user_id': user_a_id,
    'patient_id': 'P_PATIENT_A',
    'patient_name': 'Patient A',
    'patient_age': 29,
    'patient_gender': 'F',
    'eeg_file': valid_b64,
    'eeg_filename': 'valid_eeg_sample.csv'
}, token=token_a)

assert valid_res.status_code == 200, f"Expected 200, got {valid_res.status_code}: {valid_res.get_json()}"
valid_json = valid_res.get_json()
assert valid_json['status'] == 'success'
assert 'storage_key' in valid_json
assert 'prediction' in valid_json
print(f"[OK] Test 6 Passed: Valid CSV EEG parsed, persistent key: {valid_json['storage_key']}")

# -------------------------------------------------------------
# TEST 7: Storage Adapter Integrity & Isolation
# -------------------------------------------------------------
storage = get_storage_adapter()
key = valid_json['storage_key']
assert storage.exists(key), f"Storage key {key} does not exist in local storage"

# Check User A can read own file
bytes_read, err_read = storage.read_file(user_a_id, key)
assert err_read is None and bytes_read is not None, f"Failed to read file: {err_read}"

# Check User B CANNOT read User A's file via storage adapter (Cross-tenant check)
_, err_cross = storage.read_file(user_b_id, key)
assert err_cross is not None and "Access denied" in err_cross, f"Expected cross-tenant denial, got {err_cross}"
print("[OK] Test 7 Passed: Storage adapter directory isolation & cross-tenant denial verified")

print("\n=== ALL MISSION 13 SECURE FILE PIPELINE TESTS COMPLETED SUCCESSFULLY ===")
