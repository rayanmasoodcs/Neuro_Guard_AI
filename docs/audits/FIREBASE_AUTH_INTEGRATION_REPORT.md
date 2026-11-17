# NeuroGuard AI — Firebase Authentication Integration & Identity Mapping Report

**Mission:** Mission 17 — Firebase Authentication Integration & Secure Identity Mapping  
**Date:** September 3, 2026  
**Status:** Completed  
**Governance Framework:** `SECURITY_RULES.md`, `FIREBASE_MIGRATION_ARCHITECTURE.md`, `MASTER_IMPLEMENTATION_MAP.md`

---

## 1. AUTHENTICATION ARCHITECTURE & IDENTITY CHAIN

Mission 17 established a verified identity chain connecting Flutter mobile clients, Firebase Authentication, and Flask backend RBAC authorization middleware:

```
+-------------------+      1. Login / Register     +-----------------------+
|  Flutter Client   | ───────────────────────────► | Firebase Auth Service |
+-------------------+                              +-----------------------+
          │                                                    │
          │ 2. Obtains Firebase ID Token                       │ Returns ID Token
          ▼                                                    ▼
+--------------------------------------------------------------------------+
| Attach Header: Authorization: Bearer <firebase_id_token>                 |
+--------------------------------------------------------------------------+
          │
          │ 3. Send HTTPS REST Request
          ▼
+--------------------------------------------------------------------------+
| Flask Backend API Middleware (@require_auth)                             |
|   ├─► Verify Firebase ID Token via firebase_admin SDK                    |
|   ├─► Extract verified `uid` & `email` (Client UID claims never trusted) |
|   ├─► Query / Map to Django `users.firebase_uid`                         |
|   ├─► Populate context: g.user_id, g.role, g.token_name, g.firebase_uid   |
|   └─► Enforce Role Authorization (@require_role) & IDOR Protection       |
+--------------------------------------------------------------------------+
```

---

## 2. SUMMARY OF CHANGES

### Flutter Client Changes
- Created [`lib/services/firebase_auth_helper.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/services/firebase_auth_helper.dart): Provides unified authentication token retrieval (`getAuthHeaders()`) and local token storage management. Automatically injects `Authorization: Bearer <token>` into HTTP REST requests.

### Backend Python / Flask Changes
- Created [`lib/services/firebase_auth_service.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/services/firebase_auth_service.py):
  - Server-side ID token verification using `firebase_admin.auth.verify_id_token()`.
  - Deterministic user account mapping (`get_or_create_mapped_user`).
  - Automatic Custom Claim synchronization (`set_custom_user_claims(uid, {'role': role, 'django_id': user_id})`).
- Updated [`lib/screens/auth/app.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/app.py):
  - Schema extension: Added `firebase_uid` column to `users` table DDL (MySQL and SQLite).
  - Hybrid `@require_auth` decorator: Attempts Firebase ID token verification first, falling back to local HS256 server JWTs for seamless backward compatibility.

---

## 3. TOKEN VERIFICATION & IDENTITY MAPPING STRATEGY

1. **Server-Side Token Verification:** Flask never trusts a `user_id` or `role` passed as plain request text. The `@require_auth` decorator decodes and verifies signature, expiration, and audience using `firebase_admin.auth.verify_id_token()`.
2. **Deterministic Account Mapping:**
   - **Step 1:** Lookup `users` table by `firebase_uid`. Return existing record if mapped.
   - **Step 2:** Lookup `users` table by verified `email`. If match found, update `users.firebase_uid = firebase_uid` (linking legacy accounts without creating duplicate rows).
   - **Step 3:** If no match, provision a new user account in `users` table storing `firebase_uid`, `email`, `name`, `role`, and a high-entropy random placeholder password hash.

---

## 4. ROLE AND RBAC PRESERVATION

- **Authoritative Role Store:** User roles (`patient` / `doctor`) remain authoritatively managed in the Django `users` database table.
- **Custom Claims Sync:** Roles are synchronized from Django to Firebase Auth Custom Claims via `firebase_admin.auth.set_custom_user_claims()`. Client applications cannot tamper with Custom Claims.
- **Endpoint Protection:** `@require_role('doctor')` and object-level ownership checks (`check_user_owns`, `check_doctor_owns_patient`) continue enforcing strict access boundaries.

---

## 5. AUTOMATED TEST RESULTS

Automated test suite [`run_firebase_auth_tests.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/run_firebase_auth_tests.py) executed:

| Test Case | Description | Result |
| :--- | :--- | :---: |
| **Test 1** | Schema Check: `users` table contains `firebase_uid` column | **PASS** |
| **Test 2.1** | Deterministic Mapping: New user creation with `firebase_uid` | **PASS** |
| **Test 2.2** | Legacy Account Linking: Matches existing email without duplicate rows | **PASS** |
| **Test 2.3** | Re-mapping: Querying existing `firebase_uid` returns identical user | **PASS** |
| **Test 3** | Invalid Token Rejection: Malformed token returns `401 Unauthorized` | **PASS** |
| **Test 4** | Expired Token Rejection: Expired token returns `401 Unauthorized` | **PASS** |
| **Test 5** | Missing Token Guard: Protected endpoint returns `401 Unauthorized` | **PASS** |
| **Test 6.1** | RBAC Enforcement: Patient accessing Doctor endpoint returns `403 Forbidden` | **PASS** |
| **Test 6.2** | IDOR Defense: Patient A reading Patient B data returns `403 Forbidden` | **PASS** |
| **Test 7** | Backward Compatibility: Existing HS256 JWTs work 100% seamlessly | **PASS** |

**Overall Score:** **100% PASS (10/10 Verification Tests Passed)**

---

## 6. KNOWN LIMITATIONS & ROLLBACK STRATEGY

- **Offline Dev Mode:** When `firebase_credentials.json` is missing, `firebase_auth_service` operates in deferred mode, allowing local HS256 JWT verification to maintain full developer velocity and test execution.
- **Rollback Strategy:** If Firebase Authentication fails in production, environment variable `AUTH_PROVIDER` can be switched from `firebase` to `jwt`. The `@require_auth` decorator will fallback to verifying local HS256 JWTs using existing bcrypt password hashes in the `users` database table.
