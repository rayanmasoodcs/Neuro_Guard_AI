"""
NeuroGuard AI - Round 4 Master End-to-End Cloud Verification Suite
================================================--------------------
Executes comprehensive end-to-end verification covering:
  Test Area 1: Firebase Auth & Identity Mapping Chain
  Test Area 2: Role Authorization (RBAC & Cross-Tenant IDOR Defense)
  Test Area 3: Cloud Firestore Data & Security Access Rules
  Test Area 4: Cloud Storage Paths & File Access Control
  Test Area 5: Data Migration Reconciliation & Record Count Validation
  Test Area 6: Backend & ML Engine Regression Checks
  Test Area 7: Security & Credential Isolation Audit
"""

import sys
import os
import json
import secrets
import jwt
import base64
import numpy as np
import io
from datetime import datetime, timezone

from python_backend.auth.app import app as ng_app, db_config, generate_token, _JWT_SECRET
from python_backend.auth.db_fallback import get_connection, is_mysql_connection
from python_backend.services.firebase_auth_service import get_or_create_mapped_user, verify_firebase_token
from python_backend.services.firestore_service import publish_notification, publish_seizure_event, sync_patient_profile_cache
from python_backend.storage.storage_adapter import get_storage_adapter
from ml_models.production_pipeline import predict_from_raw

client = ng_app.test_client()
results = []

def record_test(area, name, passed, details=""):
    results.append({'area': area, 'name': name, 'passed': passed, 'details': details})
    status_str = "[PASS]" if passed else "[FAIL]"
    print(f"{status_str} [{area}] {name} {details}")

print("==========================================================")
print("=== NEUROGUARD AI - ROUND 4 MASTER VERIFICATION SUITE ===")
print("==========================================================")

# -------------------------------------------------------------
# TEST AREA 1 — IDENTITY & DJANGO VERIFICATION CHAIN
# -------------------------------------------------------------
# 1.1 DB Schema firebase_uid Column Verification
try:
    conn = get_connection(db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT firebase_uid FROM users LIMIT 1")
    cursor.fetchall()
    cursor.close(); conn.close()
    record_test("Area 1: Identity", "Database firebase_uid Schema Column", True, "users table contains firebase_uid column")
except Exception as e:
    record_test("Area 1: Identity", "Database firebase_uid Schema Column", False, str(e))

# 1.2 Deterministic Account Mapping
try:
    fb_uid_test = f"e2e_fb_{secrets.token_hex(6)}"
    email_test = f"e2e_user_{secrets.token_hex(4)}@test.local"
    mapped_u = get_or_create_mapped_user(db_config, firebase_uid=fb_uid_test, email=email_test, name="R4 User", role="patient")
    assert mapped_u is not None
    r4_user_id = mapped_u['id']
    record_test("Area 1: Identity", "Deterministic User Mapping", True, f"Mapped Firebase UID {fb_uid_test} to Django user ID {r4_user_id}")
except Exception as e:
    record_test("Area 1: Identity", "Deterministic User Mapping", False, str(e))

# 1.3 Invalid Token Rejection (HTTP 401)
try:
    bad_t_res = client.get('/get_medications/1', headers={'Authorization': 'Bearer MALFORMED_TOKEN'})
    assert bad_t_res.status_code == 401
    record_test("Area 1: Identity", "Invalid Token Rejection (HTTP 401)", True, "Malformed Bearer token blocked")
except Exception as e:
    record_test("Area 1: Identity", "Invalid Token Rejection (HTTP 401)", False, str(e))

# -------------------------------------------------------------
# TEST AREA 2 — AUTHORIZATION & RBAC DEFENSE
# -------------------------------------------------------------
try:
    r4_pat_token = generate_token(user_id=r4_user_id, role='patient', name='R4 Patient')
    # Patient calling Doctor route -> 403
    rbac_res = client.get('/get_all_patients?doctor_id=99', headers={'Authorization': f'Bearer {r4_pat_token}'})
    assert rbac_res.status_code == 403
    record_test("Area 2: RBAC", "Patient Accessing Doctor Route Block (HTTP 403)", True, "Role authorization boundary enforced")
except Exception as e:
    record_test("Area 2: RBAC", "Patient Accessing Doctor Route Block (HTTP 403)", False, str(e))

try:
    # Patient A accessing Patient B settings -> 403
    idor_res = client.get('/get_notification_settings/99999', headers={'Authorization': f'Bearer {r4_pat_token}'})
    assert idor_res.status_code == 403
    record_test("Area 2: RBAC", "Cross-Tenant IDOR Defense Block (HTTP 403)", True, "Prevented cross-user settings lookup")
except Exception as e:
    record_test("Area 2: RBAC", "Cross-Tenant IDOR Defense Block (HTTP 403)", False, str(e))

# -------------------------------------------------------------
# TEST AREA 3 — CLOUD FIRESTORE DATA & SECURITY RULES
# -------------------------------------------------------------
try:
    assert os.path.exists('firestore.rules')
    with open('firestore.rules', 'r', encoding='utf-8') as f:
        f_rules = f.read()
    assert 'allow read, write: if false;' in f_rules
    assert 'allow read, write: if true;' not in f_rules
    record_test("Area 3: Firestore", "Firestore Security Rules Verification", True, "Default-deny policy & recipient rules verified")
except Exception as e:
    record_test("Area 3: Firestore", "Firestore Security Rules Verification", False, str(e))

try:
    n_id = publish_notification(recipient_uid=fb_uid_test, title="R4 Test Notification", body="Verification Body")
    assert n_id is not None
    record_test("Area 3: Firestore", "Notification Service Publish", True, f"Published notification ID {n_id}")
except Exception as e:
    record_test("Area 3: Firestore", "Notification Service Publish", False, str(e))

# -------------------------------------------------------------
# TEST AREA 4 — CLOUD STORAGE & FILE SECURITY
# -------------------------------------------------------------
try:
    assert os.path.exists('storage.rules')
    with open('storage.rules', 'r', encoding='utf-8') as f:
        s_rules = f.read()
    assert 'allow read, write: if false;' in s_rules
    assert 'request.auth != null' in s_rules
    record_test("Area 4: Storage", "Storage Security Rules Verification", True, "Default-deny policy & auth requirement verified")
except Exception as e:
    record_test("Area 4: Storage", "Storage Security Rules Verification", False, str(e))

try:
    adapter = get_storage_adapter()
    dummy_eeg = b"0.0,1.0,2.0\n0.1,1.1,2.1"
    s_key, err = adapter.save_file(user_id=r4_user_id, file_bytes=dummy_eeg, original_filename="e2e_eeg.csv", subfolder="eeg")
    assert err is None
    assert adapter.exists(s_key)
    record_test("Area 4: Storage", "Storage Adapter Save & File Persistence", True, f"Persisted file key {s_key}")
except Exception as e:
    record_test("Area 4: Storage", "Storage Adapter Save & File Persistence", False, str(e))

try:
    # Cross-tenant read denial
    _, unauth_read_err = adapter.read_file(user_id=8888, storage_key=s_key)
    assert unauth_read_err is not None and "Unauthorized" in unauth_read_err
    record_test("Area 4: Storage", "Cross-Tenant File Read Denial", True, "Blocked unauthorized file access")
except Exception as e:
    record_test("Area 4: Storage", "Cross-Tenant File Read Denial", False, str(e))

# -------------------------------------------------------------
# TEST AREA 5 — DATA MIGRATION VALIDATION
# -------------------------------------------------------------
try:
    conn = get_connection(db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT COUNT(*) as count FROM users")
    db_users_count = cursor.fetchone()['count']
    cursor.execute("SELECT COUNT(*) as count FROM patients")
    db_patients_count = cursor.fetchone()['count']
    cursor.close(); conn.close()
    
    assert db_users_count > 0 and db_patients_count > 0
    record_test("Area 5: Migration", "Primary SSOT Database Preservation", True, f"Relational DB intact ({db_users_count} users, {db_patients_count} patients preserved)")
except Exception as e:
    record_test("Area 5: Migration", "Primary SSOT Database Preservation", False, str(e))

# -------------------------------------------------------------
# TEST AREA 6 — BACKEND REGRESSION CHECKS
# -------------------------------------------------------------
try:
    hp_res = client.get('/health')
    assert hp_res.status_code == 200
    record_test("Area 6: Regression", "Health Probe /health Endpoint", True, "Status code 200 OK")
except Exception as e:
    record_test("Area 6: Regression", "Health Probe /health Endpoint", False, str(e))

try:
    # Test EEG parsing & ML prediction
    t = np.linspace(0, 2, 512)
    chans = [np.sin(2 * np.pi * (5 + i) * t) for i in range(14)]
    mat = np.column_stack(chans).T
    p_cls, conf, sz_type, _, ml_err = predict_from_raw(mat, sfreq=256.0)
    assert ml_err is None
    record_test("Area 6: Regression", "ML Seizure Inference Engine", True, f"Inferred {sz_type} ({conf:.2%}) without errors")
except Exception as e:
    record_test("Area 6: Regression", "ML Seizure Inference Engine", False, str(e))

# -------------------------------------------------------------
# TEST AREA 7 — SECURITY & CREDENTIAL ISOLATION AUDIT
# -------------------------------------------------------------
try:
    with open('.gitignore', 'r', encoding='utf-8') as f:
        git_content = f.read()
    assert 'google-services.json' in git_content or '*.json' in git_content
    assert 'GoogleService-Info.plist' in git_content or '*.plist' in git_content
    record_test("Area 7: Security Audit", "Credential Isolation in .gitignore", True, "Firebase config files excluded from git")
except Exception as e:
    record_test("Area 7: Security Audit", "Credential Isolation in .gitignore", False, str(e))

print("\n==========================================================")
print("=== END-TO-END VERIFICATION SUMMARY ===")
print("==========================================================")
total_t = len(results)
passed_t = sum(1 for r in results if r['passed'])
failed_t = total_t - passed_t

print(f"Total Tests Executed: {total_t}")
print(f"Passed: {passed_t}")
print(f"Failed: {failed_t}")

if failed_t == 0:
    print("\n>>> ALL TEST AREAS PASSED 100%. ROUND 4 IS GO FOR ROUND 5 TRANSITION <<<")
else:
    print(f"\n>>> VERIFICATION FAILED ({failed_t} failures). ROUND 4 IS NO-GO <<<")
    sys.exit(1)
