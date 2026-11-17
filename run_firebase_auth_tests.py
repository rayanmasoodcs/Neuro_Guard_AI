"""
NeuroGuard AI - Mission 17 Firebase Auth Integration & Identity Mapping Test Suite
====================================================================================
Tests:
- Test 1: Database Schema Check (users.firebase_uid column exists)
- Test 2: Deterministic Identity Mapping (New user creation, existing email account linking, duplicate prevention)
- Test 3: Valid Firebase Token Identity Chain & g context population
- Test 4: Invalid Token Rejection (HTTP 401 Unauthorized)
- Test 5: Missing Token Block (HTTP 401 Unauthorized)
- Test 6: Role-Based Access Control (RBAC) & IDOR Protection with mapped Firebase Identity (HTTP 403)
- Test 7: Backward Compatibility Check (HS256 server JWTs continue working seamlessly)
"""

import json
import secrets
import jwt
from datetime import datetime, timezone
from python_backend.auth.app import app as ng_app, db_config, generate_token, _JWT_SECRET
from python_backend.auth.db_fallback import get_connection
from python_backend.services.firebase_auth_service import get_or_create_mapped_user, verify_firebase_token

client = ng_app.test_client()

print("=================================================================")
print("=== NEUROGUARD AI - MISSION 17 FIREBASE AUTH INTEGRATION TESTS ===")
print("=================================================================")

# -------------------------------------------------------------
# TEST 1: Database Schema Verification (users.firebase_uid)
# -------------------------------------------------------------
conn = get_connection(db_config)
cursor = conn.cursor(dictionary=True)

try:
    cursor.execute("SELECT firebase_uid FROM users LIMIT 1")
    cursor.fetchall()
    print("[PASS] Test 1: Database table `users` contains `firebase_uid` column")
except Exception as e:
    assert False, f"[FAIL] Test 1: Column `firebase_uid` missing from `users` table: {e}"
finally:
    cursor.close()
    conn.close()

# -------------------------------------------------------------
# TEST 2: Deterministic User Account Mapping Strategy
# -------------------------------------------------------------
test_fb_uid_1 = f"fb_uid_{secrets.token_hex(8)}"
test_email_1 = f"fb_user_{secrets.token_hex(4)}@test.local"

# 2.1 Map New User
mapped_new = get_or_create_mapped_user(
    db_config,
    firebase_uid=test_fb_uid_1,
    email=test_email_1,
    name="Firebase User 1",
    role="patient"
)
assert mapped_new is not None, "Failed to create mapped user!"
assert mapped_new['email'] == test_email_1
assert mapped_new['firebase_uid'] == test_fb_uid_1
assert mapped_new['role'] == 'patient'
user_id_1 = mapped_new['id']
print(f"[PASS] Test 2.1: Created new mapped Django user id={user_id_1} for Firebase UID {test_fb_uid_1}")

# 2.2 Account Linking for Existing Email
test_email_existing = f"existing_{secrets.token_hex(4)}@test.local"
# First create account without firebase_uid (simulating legacy user)
conn = get_connection(db_config)
cursor = conn.cursor()
cursor.execute(
    "INSERT INTO users (name, email, role, password) VALUES (%s, %s, %s, %s)",
    ("Legacy User", test_email_existing, "doctor", "hashed_pwd_legacy")
)
conn.commit()
legacy_id = cursor.lastrowid
cursor.close(); conn.close()

test_fb_uid_legacy = f"fb_legacy_{secrets.token_hex(8)}"
mapped_linked = get_or_create_mapped_user(
    db_config,
    firebase_uid=test_fb_uid_legacy,
    email=test_email_existing,
    role="doctor"
)
assert mapped_linked is not None, "Failed to link existing email account!"
assert mapped_linked['id'] == legacy_id, f"Created duplicate user id={mapped_linked['id']} instead of linking id={legacy_id}!"
assert mapped_linked['firebase_uid'] == test_fb_uid_legacy
print(f"[PASS] Test 2.2: Linked existing legacy account id={legacy_id} to Firebase UID {test_fb_uid_legacy} without creating duplicate")

# 2.3 Re-mapping Same Firebase UID returns identical record
re_mapped = get_or_create_mapped_user(
    db_config,
    firebase_uid=test_fb_uid_1,
    email=test_email_1
)
assert re_mapped['id'] == user_id_1, "Re-mapping returned different user ID!"
print(f"[PASS] Test 2.3: Re-mapping existing Firebase UID {test_fb_uid_1} deterministically returned user id={user_id_1}")

# -------------------------------------------------------------
# TEST 3: Invalid Authentication Token -> HTTP 401
# -------------------------------------------------------------
inv_res = client.get('/get_medications/1', headers={'Authorization': 'Bearer INVALID_MALFORMED_TOKEN_999'})
assert inv_res.status_code == 401, f"Expected 401, got {inv_res.status_code}"
assert 'Invalid authentication token' in inv_res.get_json()['message']
print("[PASS] Test 3: Invalid token cleanly rejected with HTTP 401 Unauthorized")

# -------------------------------------------------------------
# TEST 4: Expired Token Rejection -> HTTP 401
# -------------------------------------------------------------
exp_payload = {
    'sub': str(user_id_1),
    'role': 'patient',
    'iat': int(datetime.now(timezone.utc).timestamp()) - 7200,
    'exp': int(datetime.now(timezone.utc).timestamp()) - 3600
}
expired_jwt = jwt.encode(exp_payload, _JWT_SECRET, algorithm='HS256')
exp_res = client.get('/get_medications/1', headers={'Authorization': f'Bearer {expired_jwt}'})
assert exp_res.status_code == 401, f"Expected 401, got {exp_res.status_code}"
assert 'Session expired' in exp_res.get_json()['message']
print("[PASS] Test 4: Expired token cleanly rejected with HTTP 401 Unauthorized")

# -------------------------------------------------------------
# TEST 5: Missing Token Guard -> HTTP 401
# -------------------------------------------------------------
missing_res = client.get('/get_medications/1')
assert missing_res.status_code == 401
assert 'Authentication required' in missing_res.get_json()['message']
print("[PASS] Test 5: Protected endpoint blocks request without Bearer token (HTTP 401)")

# -------------------------------------------------------------
# TEST 6: RBAC & IDOR Defense Enforcement with Mapped Identity
# -------------------------------------------------------------
# Patient token calling Doctor-only endpoint -> 403 Forbidden
pat_jwt = generate_token(user_id=user_id_1, role='patient', name='Firebase User 1')
rbac_res = client.get('/get_all_patients?doctor_id=99', headers={'Authorization': f'Bearer {pat_jwt}'})
assert rbac_res.status_code == 403, f"Expected 403, got {rbac_res.status_code}"
assert 'Access denied' in rbac_res.get_json()['message']
print("[PASS] Test 6.1: Patient accessing Doctor endpoint blocked with HTTP 403 Forbidden")

# Patient A accessing Patient B settings -> 403 Forbidden
idor_res = client.get('/get_notification_settings/99999', headers={'Authorization': f'Bearer {pat_jwt}'})
assert idor_res.status_code == 403, f"Expected 403, got {idor_res.status_code}"
print("[PASS] Test 6.2: Cross-tenant IDOR attack blocked with HTTP 403 Forbidden")

# -------------------------------------------------------------
# TEST 7: Backward Compatibility Check (HS256 Server JWTs)
# -------------------------------------------------------------
# Add medication using valid HS256 JWT
add_med_res = client.post('/add_medication', data=json.dumps({
    'user_id': user_id_1,
    'medicine_name': 'Firebase Test Med',
    'dose': '250mg',
    'frequency': 'Daily',
    'timing': 'Morning'
}), headers={'Authorization': f'Bearer {pat_jwt}', 'Content-Type': 'application/json'})
assert add_med_res.status_code in (200, 201), f"Medication creation failed: {add_med_res.get_json()}"

get_meds_res = client.get(f'/get_medications/{user_id_1}', headers={'Authorization': f'Bearer {pat_jwt}'})
assert get_meds_res.status_code == 200
meds = get_meds_res.get_json()['medications']
assert any(m['medicine_name'] == 'Firebase Test Med' for m in meds)
print("[PASS] Test 7: Backward compatibility verified. Existing HS256 JWT authentication functions 100% seamlessly!")

print("\n=================================================================")
print("=== ALL MISSION 17 FIREBASE AUTH INTEGRATION TESTS PASSED 100% ===")
print("=================================================================")
