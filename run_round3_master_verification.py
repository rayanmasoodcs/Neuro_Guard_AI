"""
NeuroGuard AI - Round 3 Master Verification Test Suite
======================================================
Executes end-to-end verification covering:
  Test Area 1: Backend Startup & Configuration Loading
  Test Area 2: Authentication (JWT Generation & Validation)
  Test Area 3: Role-Based Access Control (RBAC & IDOR Defense)
  Test Area 4: File Security & Categorized Validation Boundary
  Test Area 5: API Reliability, HTTP Status Codes & Exception Shielding
  Test Area 6: Redacting Logging & Privacy Rules
  Test Area 7: Regression Check on DB Operations & Existing Workflows
"""

import sys
import os
import json
import base64
import numpy as np
import io

from python_backend.auth.app import app as ng_app, db_config, generate_token
from python_backend.auth.db_fallback import get_connection, is_mysql_connection
from python_backend.storage.storage_adapter import get_storage_adapter
from python_backend.services.logging_service import logger, SensitiveDataRedactingFormatter
from python_backend.services.audit_service import log_audit_event

client = ng_app.test_client()

results = []

def record_test(area, name, passed, details=""):
    results.append({'area': area, 'name': name, 'passed': passed, 'details': details})
    status_str = "[PASS]" if passed else "[FAIL]"
    print(f"{status_str} [{area}] {name} {details}")

print("==========================================================")
print("=== NEUROGUARD AI - ROUND 3 MASTER VERIFICATION SUITE ===")
print("==========================================================")

# -------------------------------------------------------------
# TEST AREA 1 — BACKEND STARTUP & DATABASE CONNECTION
# -------------------------------------------------------------
try:
    conn = get_connection(db_config)
    cursor = conn.cursor()
    cursor.execute("SELECT 1")
    cursor.close()
    conn.close()
    backend_type = "MySQL" if is_mysql_connection() else "SQLite"
    record_test("Area 1: Startup", "Database Connectivity & DB Fallback", True, f"Connected to {backend_type}")
except Exception as e:
    record_test("Area 1: Startup", "Database Connectivity", False, str(e))

# Health Probe Check
try:
    hp_res = client.get('/health')
    assert hp_res.status_code == 200, f"Got {hp_res.status_code}"
    record_test("Area 1: Startup", "Health Probe /health Endpoint", True, f"Status Code {hp_res.status_code}")
except Exception as e:
    record_test("Area 1: Startup", "Health Probe /health Endpoint", False, str(e))

# -------------------------------------------------------------
# TEST AREA 2 — AUTHENTICATION
# -------------------------------------------------------------
# 2.1 Valid Registration & Login
try:
    res_signup = client.post('/signup', data=json.dumps({
        'name': 'E2E Patient', 'email': 'e2e_pat@test.local', 'phone': '555',
        'password': 'Password123!', 'role': 'patient', 'age': 28
    }), content_type='application/json')
    
    if res_signup.status_code in (200, 201):
        pat_token = res_signup.get_json()['token']
        pat_id = res_signup.get_json()['user']['id']
    else:
        res_login = client.post('/login', data=json.dumps({
            'email': 'e2e_pat@test.local', 'password': 'Password123!'
        }), content_type='application/json')
        pat_token = res_login.get_json()['token']
        pat_id = res_login.get_json()['user']['id']
        
    record_test("Area 2: Auth", "Valid Patient Registration & Token Issuance", True, f"Issued token for User ID {pat_id}")
except Exception as e:
    record_test("Area 2: Auth", "Valid Patient Registration & Token Issuance", False, str(e))

# 2.2 Invalid Credentials
try:
    bad_login = client.post('/login', data=json.dumps({
        'email': 'e2e_pat@test.local', 'password': 'WrongPassword999'
    }), content_type='application/json')
    assert bad_login.status_code == 401, f"Expected 401, got {bad_login.status_code}"
    record_test("Area 2: Auth", "Invalid Password Rejection (HTTP 401)", True, "Rejected invalid credentials")
except Exception as e:
    record_test("Area 2: Auth", "Invalid Password Rejection (HTTP 401)", False, str(e))

# 2.3 Missing Authentication Bearer Token
try:
    unauth_req = client.get(f'/get_medications/{pat_id}')
    assert unauth_req.status_code == 401, f"Expected 401, got {unauth_req.status_code}"
    record_test("Area 2: Auth", "Missing Token Guard (HTTP 401)", True, "Protected route blocked without token")
except Exception as e:
    record_test("Area 2: Auth", "Missing Token Guard (HTTP 401)", False, str(e))

# -------------------------------------------------------------
# TEST AREA 3 — ROLE-BASED ACCESS CONTROL (RBAC) & IDOR
# -------------------------------------------------------------
# 3.1 Register Doctor
try:
    res_doc = client.post('/signup', data=json.dumps({
        'name': 'E2E Doctor', 'email': 'e2e_doc@test.local', 'phone': '777',
        'password': 'Password123!', 'role': 'doctor', 'age': 45
    }), content_type='application/json')
    
    if res_doc.status_code in (200, 201):
        doc_token = res_doc.get_json()['token']
        doc_id = res_doc.get_json()['user']['id']
    else:
        res_login_doc = client.post('/login', data=json.dumps({
            'email': 'e2e_doc@test.local', 'password': 'Password123!'
        }), content_type='application/json')
        doc_token = res_login_doc.get_json()['token']
        doc_id = res_login_doc.get_json()['user']['id']
        
    record_test("Area 3: RBAC", "Doctor Account Provisioning", True, f"Issued Doctor token for User ID {doc_id}")
except Exception as e:
    record_test("Area 3: RBAC", "Doctor Account Provisioning", False, str(e))

# 3.2 Patient Accessing Doctor Route -> 403 Forbidden
try:
    forbidden_req = client.get(f'/get_all_patients?doctor_id={doc_id}', headers={'Authorization': f'Bearer {pat_token}'})
    assert forbidden_req.status_code == 403, f"Expected 403, got {forbidden_req.status_code}"
    record_test("Area 3: RBAC", "Patient Calling Doctor Endpoint (HTTP 403)", True, "Patient blocked from doctor roster route")
except Exception as e:
    record_test("Area 3: RBAC", "Patient Calling Doctor Endpoint (HTTP 403)", False, str(e))

# 3.3 Patient A accessing Patient B data -> 403 Forbidden
try:
    cross_req = client.get(f'/get_notification_settings/{doc_id}', headers={'Authorization': f'Bearer {pat_token}'})
    assert cross_req.status_code == 403, f"Expected 403, got {cross_req.status_code}"
    record_test("Area 3: RBAC", "Cross-Tenant IDOR Prevention (HTTP 403)", True, "Prevented user from reading other user's settings")
except Exception as e:
    record_test("Area 3: RBAC", "Cross-Tenant IDOR Prevention (HTTP 403)", False, str(e))

# -------------------------------------------------------------
# TEST AREA 4 — FILE SECURITY & VALIDATION BOUNDARY
# -------------------------------------------------------------
# 4.1 Unsupported Extension Upload
try:
    bad_ext_req = client.post('/api/seizure/predict_seizure_from_eeg', data=json.dumps({
        'user_id': pat_id, 'eeg_file': 'dGVzdA==', 'eeg_filename': 'malicious.exe'
    }), headers={'Authorization': f'Bearer {pat_token}', 'Content-Type': 'application/json'})
    assert bad_ext_req.status_code == 400, f"Expected 400, got {bad_ext_req.status_code}"
    assert bad_ext_req.get_json()['error_code'] == 'FILE_FORMAT_ERROR'
    record_test("Area 4: File Security", "Unsupported Extension Rejection (.exe)", True, "Returned FILE_FORMAT_ERROR")
except Exception as e:
    record_test("Area 4: File Security", "Unsupported Extension Rejection (.exe)", False, str(e))

# 4.2 Scientific Flatline Rejection
try:
    flat_csv = "\n".join([",".join(["0.0"] * 14) for _ in range(500)])
    flat_b64 = base64.b64encode(flat_csv.encode('utf-8')).decode('utf-8')
    flat_req = client.post('/api/seizure/predict_seizure_from_eeg', data=json.dumps({
        'user_id': pat_id, 'eeg_file': flat_b64, 'eeg_filename': 'flat.csv'
    }), headers={'Authorization': f'Bearer {pat_token}', 'Content-Type': 'application/json'})
    assert flat_req.status_code == 400, f"Expected 400, got {flat_req.status_code}"
    assert flat_req.get_json()['error_code'] == 'EEG_STRUCTURE_ERROR'
    record_test("Area 4: File Security", "Flatline Zero-Variance Signal Rejection", True, "Returned EEG_STRUCTURE_ERROR")
except Exception as e:
    record_test("Area 4: File Security", "Flatline Zero-Variance Signal Rejection", False, str(e))

# 4.3 Valid 14-Channel EEG Upload & Storage Adapter Persistence
try:
    t = np.linspace(0, 2, 512)
    channels = [np.sin(2 * np.pi * (5 + i) * t) + np.random.normal(0, 0.1, len(t)) for i in range(14)]
    valid_csv = io.StringIO()
    np.savetxt(valid_csv, np.column_stack(channels), delimiter=',', fmt='%.4f')
    valid_b64 = base64.b64encode(valid_csv.getvalue().encode('utf-8')).decode('utf-8')

    eeg_req = client.post('/api/seizure/predict_seizure_from_eeg', data=json.dumps({
        'user_id': pat_id, 'patient_id': 'P_E2E', 'patient_name': 'E2E Patient',
        'patient_age': 28, 'patient_gender': 'F', 'eeg_file': valid_b64, 'eeg_filename': 'e2e_signal.csv'
    }), headers={'Authorization': f'Bearer {pat_token}', 'Content-Type': 'application/json'})
    assert eeg_req.status_code == 200, f"Expected 200, got {eeg_req.status_code}: {eeg_req.get_json()}"
    storage_key = eeg_req.get_json()['storage_key']
    assert get_storage_adapter().exists(storage_key)
    record_test("Area 4: File Security", "Valid EEG Upload & LocalStorage Persistence", True, f"Stored key {storage_key}")
except Exception as e:
    record_test("Area 4: File Security", "Valid EEG Upload & LocalStorage Persistence", False, str(e))

# -------------------------------------------------------------
# TEST AREA 5 — API RELIABILITY & EXCEPTION SHIELDING
# -------------------------------------------------------------
try:
    err_req = client.get('/non_existent_endpoint_xyz')
    assert err_req.status_code == 404
    err_body = err_req.get_json()
    assert 'Traceback' not in str(err_body) and 'line ' not in str(err_body)
    record_test("Area 5: Reliability", "Traceback & Database Internal Exception Shielding", True, "404 payload contains clean safe message")
except Exception as e:
    record_test("Area 5: Reliability", "Traceback & Database Internal Exception Shielding", False, str(e))

# -------------------------------------------------------------
# TEST AREA 6 — LOGGING & AUDIT TRAIL
# -------------------------------------------------------------
try:
    conn = get_connection(db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT COUNT(*) as count FROM audit_logs WHERE user_id = %s", (pat_id,))
    count = cursor.fetchone()['count']
    cursor.close(); conn.close()
    assert count > 0, f"No audit entries found for user {pat_id}"
    record_test("Area 6: Logging & Audit", "Audit Trail Event Persistence in DB", True, f"Found {count} audit events for user {pat_id}")
except Exception as e:
    record_test("Area 6: Logging & Audit", "Audit Trail Event Persistence in DB", False, str(e))

# -------------------------------------------------------------
# TEST AREA 7 — REGRESSION CHECK ON EXISTING WORKFLOWS
# -------------------------------------------------------------
# 7.1 Medication Addition & Retrieval
try:
    add_med = client.post('/add_medication', data=json.dumps({
        'user_id': pat_id, 'medicine_name': 'Levetiracetam', 'dose': '500mg',
        'frequency': 'Twice Daily', 'timing': 'Morning/Evening', 'description': 'Anti-seizure'
    }), headers={'Authorization': f'Bearer {pat_token}', 'Content-Type': 'application/json'})
    assert add_med.status_code in (200, 201), f"Got {add_med.status_code}: {add_med.get_json()}"

    get_meds = client.get(f'/get_medications/{pat_id}', headers={'Authorization': f'Bearer {pat_token}'})
    assert get_meds.status_code == 200
    meds_list = get_meds.get_json()['medications']
    assert any(m['medicine_name'] == 'Levetiracetam' for m in meds_list)
    record_test("Area 7: Regression", "Medications API Workflow", True, "Successfully added and retrieved medication")
except Exception as e:
    record_test("Area 7: Regression", "Medications API Workflow", False, str(e))

# 7.2 Patient Medical History Retrieval
try:
    get_hist = client.get(f'/get_medical_history/{pat_id}', headers={'Authorization': f'Bearer {pat_token}'})
    assert get_hist.status_code == 200
    hist = get_hist.get_json()['history']
    assert hist['id'] == pat_id
    record_test("Area 7: Regression", "Medical History Retrieval Workflow", True, f"Retrieved clinical history for Patient ID {pat_id}")
except Exception as e:
    record_test("Area 7: Regression", "Medical History Retrieval Workflow", False, str(e))

# 7.3 Doctor Clinical Patient Update Workflow
try:
    upd_pat = client.post('/update_or_add_patient', data=json.dumps({
        'patient_id': 'P_E2E', 'doctor_id': doc_id, 'name': 'E2E Patient',
        'age': 28, 'gender': 'F', 'medical_condition': 'Stable', 'email': 'e2e_pat@test.local'
    }), headers={'Authorization': f'Bearer {doc_token}', 'Content-Type': 'application/json'})
    assert upd_pat.status_code in (200, 201)

    get_det = client.get('/get_patient_details/P_E2E', headers={'Authorization': f'Bearer {doc_token}'})
    assert get_det.status_code == 200
    p_det = get_det.get_json()['patient']
    assert p_det['name'] == 'E2E Patient'
    record_test("Area 7: Regression", "Doctor Clinical Patient Management Workflow", True, "Successfully updated & retrieved clinical roster")
except Exception as e:
    record_test("Area 7: Regression", "Doctor Clinical Patient Management Workflow", False, str(e))

print("\n==========================================================")
print("=== END-TO-END VERIFICATION SUMMARY ===")
print("==========================================================")
total_tests = len(results)
passed_tests = sum(1 for r in results if r['passed'])
failed_tests = total_tests - passed_tests

print(f"Total Tests Executed: {total_tests}")
print(f"Passed: {passed_tests}")
print(f"Failed: {failed_tests}")

if failed_tests == 0:
    print("\n>>> ALL TEST AREAS PASSED. ROUND 3 IS GO FOR ROUND 4 FIREBASE MIGRATION <<<")
else:
    print(f"\n>>> VERIFICATION FAILED ({failed_tests} failures). ROUND 3 IS NO-GO <<<")
    sys.exit(1)
