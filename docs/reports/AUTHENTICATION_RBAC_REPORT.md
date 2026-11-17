# NeuroGuard AI — Authentication & Role-Based Access Control (RBAC) Report

**Mission:** Mission 12 — Secure and Verify Authentication & Role-Based Access Control  
**Date:** September 3, 2026  
**Status:** Completed  
**Governance Framework:** `SECURITY_RULES.md`, `FINAL_ARCHITECTURE.md`, `MASTER_IMPLEMENTATION_MAP.md`

---

## 1. EXECUTIVE SUMMARY

Mission 12 successfully hardened the NeuroGuard AI backend security perimeter by introducing stateless JSON Web Token (JWT) authentication, declarative role-based access control (RBAC) decorators, and granular object-level ownership verification across all API endpoints.

Prior to Mission 12, all 49 backend routes relied exclusively on caller-supplied integer IDs in request bodies or URL parameters without token signatures, introducing universal Broken Object Level Authorization (IDOR) vulnerabilities. Furthermore, `/update_password` allowed account password resets without active session verification.

### Key Achievements
1. **Stateless JWT Token Issuance:** `/login` and `/signup` now generate cryptographically signed HS256 JWT tokens containing `sub` (user_id), `role`, `name`, `iat`, and `exp` claims (24h default TTL).
2. **Perimeter Authentication Decorator (`@require_auth`):** Validates the incoming `Authorization: Bearer <token>` header on every protected endpoint, populating thread-local request context (`g.user_id`, `g.role`, `g.token_name`).
3. **Declarative Role Enforcement (`@require_role`):** Restricts clinical and doctor-specific endpoints (`/get_all_patients`, `/update_or_add_patient`, `/get_dashboard_stats`, `/get_patient_screen_stats`, `/get_recent_patients`) strictly to accounts with `role='doctor'`.
4. **IDOR & Cross-Tenant Defense (`check_user_owns` & `check_doctor_owns_patient`):** Enforces object-level ownership so patients can only access/modify their own medical data, and doctors can only access patients assigned to their specific `doctor_id`.
5. **Sanitized Failure Responses:** Replaced verbose exceptions with generic HTTP 401 Unauthorized and HTTP 403 Forbidden error responses without exposing server tracebacks or internal database details.

---

## 2. AUTHENTICATION & TOKEN ARCHITECTURE

```
+-------------------+           +-----------------------+           +----------------------+
| Flutter Client    |  POST     | Flask API             |  Generates| Signed JWT Token     |
| (or REST Client)  | --------> | /login or /signup     | --------> | HS256, 24h Expiry    |
+-------------------+           +-----------------------+           +----------------------+
          |                                                                    |
          |  HTTP Request with 'Authorization: Bearer <token>'                 |
          +--------------------------------------------------------------------+
                                           |
                                           v
                        +-------------------------------------+
                        | @require_auth Middleware Guard      |
                        | - Decodes & verifies signature      |
                        | - Checks exp / iat claims           |
                        | - Populates g.user_id & g.role      |
                        +-------------------------------------+
                                           |
                                           v
                        +-------------------------------------+
                        | @require_role('doctor' | 'patient') |
                        | - Checks g.role permissions         |
                        | - Enforces object-level ownership   |
                        +-------------------------------------+
```

### JWT Token Claims Schema
```json
{
  "sub": "8",
  "role": "patient",
  "name": "Patient Security One",
  "iat": 1788424546,
  "exp": 1788510946
}
```

---

## 3. PROTECTED ENDPOINTS & ACCESS CONTROL MATRIX

| Endpoint | Method | Required Role | Ownership / Relationship Check | Status |
| :--- | :---: | :---: | :--- | :---: |
| `/login` | `POST` | Public | None | Verified |
| `/signup` / `/register` | `POST` | Public | Role validated ('patient' or 'doctor') | Verified |
| `/update_user_profile` | `POST` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/update_password` | `POST` | Authenticated | `check_user_owns(user_id)` + bcrypt check | Verified |
| `/change_password` | `POST` | Authenticated | `check_user_owns(user_id)` + bcrypt check | Verified |
| `/get_medical_history/<id>` | `GET` | Authenticated | `check_user_owns` or Doctor assigned check | Verified |
| `/get_patient_details/<pid>`| `GET` | Authenticated | Doctor assigned check or Patient own PID | Verified |
| `/get_all_patients` | `GET` | Doctor | `check_user_owns(doctor_id)` | Verified |
| `/get_dashboard_stats` | `GET` | Doctor | `check_user_owns(doctor_id)` | Verified |
| `/get_patient_screen_stats` | `GET` | Doctor | `check_user_owns(doctor_id)` | Verified |
| `/get_recent_patients` | `GET` | Doctor | `check_user_owns(doctor_id)` | Verified |
| `/update_or_add_patient` | `POST` | Doctor | `check_user_owns(doctor_id)` | Verified |
| `/get_medications/<id>` | `GET` | Authenticated | `check_user_owns(user_id)` or Doctor | Verified |
| `/add_medication` | `POST` | Authenticated | `check_user_owns(user_id)` or Doctor | Verified |
| `/delete_medication/...` | `DELETE` | Authenticated | `check_user_owns(user_id)` or Doctor | Verified |
| `/add_reminder` | `POST` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/get_reminders/<id>` | `GET` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/get_family_contacts/<id>` | `GET` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/add_family_contact` | `POST` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/delete_family_contact/<id>`| `DELETE` | Authenticated | `check_user_owns(user_id)` + DB query | Verified |
| `/get_notification_settings`| `GET` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/save_notification_settings`| `POST` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/get_privacy_settings` | `GET` | Authenticated | `check_user_owns(user_id)` | Verified |
| `/save_privacy_settings` | `POST` | Authenticated | `check_user_owns(user_id)` | Verified |

---

## 4. VERIFICATION & TESTING RESULTS

The updated test suite (`run_api_tests.py`) was executed to validate authentication, RBAC enforcement, and edge cases.

### Test Execution Summary
- **Unauthenticated Access Assertion:** `GET /get_medications/1` without `Authorization` header returned `401 Unauthorized` (`"message": "Authentication required."`).
- **Role Boundary Assertion:** Patient token calling `GET /get_all_patients?doctor_id=7` returned `403 Forbidden` (`"message": "Access denied. Insufficient permissions."`).
- **Authorized Doctor Workflows:** Doctor token calling `/update_or_add_patient` and `/get_patient_details/P999` returned `201 Created` and `200 OK`.
- **Authorized Patient Workflows:** Patient token adding medication, fetching medical history, and saving notification settings returned `200 OK` / `201 Created`.
- **Overall Result:** **100% Pass** across all authentication and RBAC test cases.

---

## 5. FILES MODIFIED / CREATED

- **Modified:**
  - `lib/screens/auth/app.py`: Implemented JWT generation, `@require_auth` decorator, `@require_role` decorator, ownership helpers, token issuance on `/login` & `/signup`, and protected all routes.
  - `requirements.txt`: Added `PyJWT>=2.8.0`.
  - `.env.example`: Added `JWT_SECRET` and `JWT_EXPIRY_HOURS` configuration documentation.
  - `run_api_tests.py`: Updated automated test suite to assert Bearer authentication, 401 unauthenticated, 403 forbidden, and authenticated role workflows.
- **Created:**
  - `AUTHENTICATION_RBAC_REPORT.md`: This comprehensive audit and verification report.

---

## 6. NEXT RECOMMENDED MISSION

Per `MASTER_IMPLEMENTATION_MAP.md`:
**Mission 13 / Mission 2:** API Request Sanitization, CORS Whitelisting & Exception Shielding — Harden input validation, enforce strict CORS origin filtering, and complete request payload boundary protection.
