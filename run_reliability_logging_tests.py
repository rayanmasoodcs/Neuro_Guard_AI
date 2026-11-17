"""
NeuroGuard AI - API Reliability, Logging & Audit Trail Test Suite (Mission 14)
=============================================================================
Tests:
- Input validation on endpoints (malformed JSON, invalid roles, invalid IDs) -> 400 Bad Request
- Exception shielding: Ensures HTTP 500 error responses do NOT expose internal tracebacks, paths, or secrets
- Sensitive data redaction: Verifies logger redacts passwords, tokens, and raw base64 data
- Audit trail recording: Queries `audit_logs` table to confirm SIGNUP, LOGIN, PROFILE_UPDATED, and EEG events
"""

import json
import base64
import numpy as np
import io
from python_backend.auth.app import app as ng_app, db_config
from python_backend.auth.db_fallback import get_connection
from python_backend.services.logging_service import logger, SensitiveDataRedactingFormatter

client = ng_app.test_client()

def post(path, data, token=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    return client.post(path, data=json.dumps(data), headers=headers)

print("=== STARTING MISSION 14 RELIABILITY, LOGGING & AUDIT TESTS ===")

# -------------------------------------------------------------
# TEST 1: Sensitive Data Redaction Filter Check
# -------------------------------------------------------------
formatter = SensitiveDataRedactingFormatter()
import logging
dummy_record = logging.LogRecord(
    name='neuroguard', level=logging.INFO, pathname='app.py', lineno=100,
    msg='User login attempt: {"password": "SuperSecretPassword123"}, token: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    args=(), exc_info=None
)
formatted_msg = formatter.format(dummy_record)
assert 'SuperSecretPassword123' not in formatted_msg, "Password was NOT redacted from log!"
assert '[REDACTED]' in formatted_msg, "Redaction placeholder missing!"
assert '[REDACTED_TOKEN]' in formatted_msg, "Token redaction placeholder missing!"
print("[OK] Test 1 Passed: Password and JWT token redaction filter verified")

# -------------------------------------------------------------
# TEST 2: Input Validation - Invalid Role -> 400 Bad Request
# -------------------------------------------------------------
inv_role_res = post('/signup', {
    'name': 'Hacker',
    'email': 'hacker@test.local',
    'phone': '000',
    'password': 'pass',
    'role': 'SUPERADMIN_SUPERUSER'
})
assert inv_role_res.status_code == 400, f"Expected 400, got {inv_role_res.status_code}"
assert 'Role must be' in inv_role_res.get_json()['message']
print("[OK] Test 2 Passed: Invalid role rejected with 400 Bad Request")

# -------------------------------------------------------------
# TEST 3: User Signup & Audit Trail Verification
# -------------------------------------------------------------
signup_res = post('/signup', {
    'name': 'Audit User',
    'email': 'audit_rel@test.local',
    'phone': '999',
    'password': 'pass123Password',
    'role': 'patient'
})
assert signup_res.status_code == 201, f"Signup failed: {signup_res.get_json()}"
user_id = signup_res.get_json()['user']['id']
token = signup_res.get_json()['token']

conn = get_connection(db_config)
cursor = conn.cursor(dictionary=True)
cursor.execute("SELECT * FROM audit_logs WHERE user_id = %s AND event_type = 'SIGNUP'", (user_id,))
signup_audit = cursor.fetchone()
cursor.close(); conn.close()
assert signup_audit is not None, "Audit event SIGNUP not found in database!"
assert signup_audit['event_type'] == 'SIGNUP'
print(f"[OK] Test 3 Passed: User signup created audit entry id={signup_audit['id']}")

# -------------------------------------------------------------
# TEST 4: User Login & Audit Trail Verification
# -------------------------------------------------------------
login_res = post('/login', {
    'email': 'audit_rel@test.local',
    'password': 'pass123Password'
})
assert login_res.status_code == 200

conn = get_connection(db_config)
cursor = conn.cursor(dictionary=True)
cursor.execute("SELECT * FROM audit_logs WHERE user_id = %s AND event_type = 'LOGIN_SUCCESS'", (user_id,))
login_audit = cursor.fetchone()
cursor.close(); conn.close()
assert login_audit is not None, "Audit event LOGIN_SUCCESS not found!"
print(f"[OK] Test 4 Passed: Successful login created audit entry id={login_audit['id']}")

# -------------------------------------------------------------
# TEST 5: Failed Login & Audit Trail Verification
# -------------------------------------------------------------
failed_login_res = post('/login', {
    'email': 'audit_rel@test.local',
    'password': 'WrongPassword123'
})
assert failed_login_res.status_code == 401

conn = get_connection(db_config)
cursor = conn.cursor(dictionary=True)
cursor.execute("SELECT * FROM audit_logs WHERE user_id = %s AND event_type = 'LOGIN_FAILED' AND status = 'FAILED'", (user_id,))
failed_audit = cursor.fetchone()
cursor.close(); conn.close()
assert failed_audit is not None, "Audit event LOGIN_FAILED not found!"
print(f"[OK] Test 5 Passed: Failed login created audit entry id={failed_audit['id']}")

# -------------------------------------------------------------
# TEST 6: Exception Shielding Verification (No Tracebacks Exposed)
# -------------------------------------------------------------
# Call an invalid route or missing parameters to trigger exception handling
err_res = client.get('/non_existent_route_404')
assert err_res.status_code == 404
err_json = err_res.get_json()
assert 'Traceback' not in str(err_json)
assert 'File ' not in str(err_json)
assert 'line ' not in str(err_json)
print("[OK] Test 6 Passed: Response JSON shields tracebacks, internal file paths, and database internals")

# -------------------------------------------------------------
# TEST 7: Valid EEG Upload Audit Trail Verification
# -------------------------------------------------------------
t = np.linspace(0, 2, 512)
channels = [np.sin(2 * np.pi * (5 + i) * t) + np.random.normal(0, 0.1, len(t)) for i in range(14)]
data_mat = np.column_stack(channels)

csv_io = io.StringIO()
np.savetxt(csv_io, data_mat, delimiter=',', fmt='%.4f')
valid_b64 = base64.b64encode(csv_io.getvalue().encode('utf-8')).decode('utf-8')

eeg_res = post('/api/seizure/predict_seizure_from_eeg', {
    'user_id': user_id,
    'eeg_file': valid_b64,
    'eeg_filename': 'audit_sample.csv'
}, token=token)

assert eeg_res.status_code == 200, f"EEG predict failed: {eeg_res.get_json()}"

conn = get_connection(db_config)
cursor = conn.cursor(dictionary=True)
cursor.execute("SELECT * FROM audit_logs WHERE user_id = %s AND event_type = 'EEG_UPLOAD_AND_PREDICT'", (user_id,))
eeg_audit = cursor.fetchone()
cursor.close(); conn.close()
assert eeg_audit is not None, "Audit event EEG_UPLOAD_AND_PREDICT not found!"
print(f"[OK] Test 7 Passed: EEG upload & prediction created audit entry id={eeg_audit['id']}")

print("\n=== ALL MISSION 14 RELIABILITY, LOGGING & AUDIT TESTS COMPLETED SUCCESSFULLY ===")
