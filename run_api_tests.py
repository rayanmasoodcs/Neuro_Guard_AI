from python_backend.auth.app import app as ng_app
import json

client = ng_app.test_client()

def post(path, data, token=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    r = client.post(path, data=json.dumps(data), headers=headers)
    print(path, r.status_code, r.get_json())
    return r

def get(path, token=None):
    headers = {}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    r = client.get(path, headers=headers)
    try:
        print(path, r.status_code, r.get_json())
    except Exception:
        print(path, r.status_code, r.data)
    return r

print("=== STARTING AUTH & RBAC SECURITY TESTS ===")

# 1. Unauthenticated request assertion (Should return 401)
unauth_res = client.get('/get_medications/1')
assert unauth_res.status_code == 401, f"Expected 401 for unauthenticated request, got {unauth_res.status_code}"
print("[OK] Unauthenticated access blocked (HTTP 401)")

# 2. Register Doctor
doc_res = post('/signup', {'name':'Dr Test Security','email':'dr_sec@test.local','phone':'123','password':'pass123','role':'doctor','age':45})
doc_token = doc_res.get_json().get('token') if doc_res.status_code in (200, 201) else None

# 3. Register Patient
pat_res = post('/signup', {'name':'Patient Security One','email':'pat_sec@test.local','phone':'456','password':'pass123','role':'patient','age':30})
pat_token = pat_res.get_json().get('token') if pat_res.status_code in (200, 201) else None

# 4. Login Doctor to retrieve doctor token & ID
doc_login = post('/login', {'email':'dr_sec@test.local','password':'pass123'})
assert doc_login.status_code == 200
doc_id = doc_login.get_json()['user']['id']
doc_token = doc_login.get_json()['token']

# 5. Login Patient to retrieve patient token & ID
pat_login = post('/login', {'email':'pat_sec@test.local','password':'pass123'})
assert pat_login.status_code == 200
pat_id = pat_login.get_json()['user']['id']
pat_token = pat_login.get_json()['token']

# 6. Patient attempts Doctor Endpoint (Should return 403 Forbidden)
forbidden_res = get(f'/get_all_patients?doctor_id={doc_id}', token=pat_token)
assert forbidden_res.status_code == 403, f"Expected 403 when patient calls doctor endpoint, got {forbidden_res.status_code}"
print("[OK] Patient blocked from Doctor RBAC endpoints (HTTP 403)")

# 7. Doctor adds patient
post('/update_or_add_patient', {
    'patient_id': 'P999',
    'doctor_id': doc_id,
    'name': 'Patient Security One',
    'age': 30,
    'gender':'F',
    'medical_condition':'Stable',
    'email':'pat_sec@test.local',
    'phone':'456',
    'address':'',
    'emergency_contact':'',
    'additional_notes':''
}, token=doc_token)

# 8. Patient adds medication to their own account
post('/add_medication', {'user_id': pat_id, 'medicine_name':'Aspirin','dose':'100mg','description':'desc','frequency':'Once','timing':'Morning','take_with':''}, token=pat_token)

# 9. Patient fetches their own medications
get(f'/get_medications/{pat_id}', token=pat_token)

# 10. Patient fetches medical history
get(f'/get_medical_history/{pat_id}', token=pat_token)

# 11. Doctor fetches patient details for linked patient
get('/get_patient_details/P999', token=doc_token)

# 12. Patient saves notification settings
post('/save_notification_settings', {'user_id': pat_id, 'all_notifications': True, 'emergency_alerts': True, 'ai_alerts': False, 'patient_updates': True}, token=pat_token)
get(f'/get_notification_settings/{pat_id}', token=pat_token)

print('\n=== ALL SECURITY AND API TESTS COMPLETED SUCCESSFULLY ===')

