# NeuroGuard AI — Security & Privacy Forensic Audit

**Audit Date:** September 3, 2026  
**Scope:** Full-Stack Security Surface (Flutter Client, Flask REST API, MySQL/SQLite Datastores, ML Pipeline, and Data Flow)  
**Regulatory Context:** HIPAA PHI Compliance, GDPR Health Data Standards, and OWASP Top 10 API Security  
**Mission Type:** Forensic Read-Only Security & Privacy Audit (No Code/Logic Modifications)

---

## 1. EXECUTIVE SUMMARY & THREAT LANDSCAPE

NeuroGuard AI processes sensitive healthcare records and neural biometrics, including patient demographics, medical history, clinical seizure logs, doctor notes, prescription regimens, emergency family contacts, and raw multi-channel EEG recordings.

### Primary Threat Findings
1. **🔴 Universal Broken Object Level Authorization (BOLA / IDOR):** All 49 backend endpoints accept naked user/patient identifiers without cryptographic session verification, allowing any caller to query, alter, or delete any patient's records.
2. **🔴 Unauthenticated Password Reset Endpoint (`/update_password`):** Allows overwriting any account's password by supplying only a user ID in the request body.
3. **🔴 Missing Token/Session Architecture:** Login returns plain user dictionaries with zero session tokens, JWTs, or secure HTTP-only cookies.
4. **🟠 High-Volume In-Memory File Ingestion:** Base64 EEG file uploads lack strict file size caps, posing memory exhaustion (OOM) risks.
5. **🟠 Logging & Debug Information Disclosure:** Flask runs with `debug=True`, wildcard CORS is enabled, exception handlers return raw `str(e)`, and server logs output password hash prefixes.

---

## 2. SECRETS & CREDENTIAL EXPOSURE AUDIT

| Secret / Credential Category | Location Found | Exposure Risk | Current State | Recommendation |
| :--- | :--- | :--- | :--- | :--- |
| **Database Credentials** | [`lib/screens/auth/app.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/app.py#L15-L20) | Hardcoded in source code (`host='127.0.0.1'`, `user='root'`, `password=''`) | Low in local development; Critical if deployed | Extract into `.env` file via `python-dotenv` |
| **Password Hash Prefixes** | [`lib/screens/auth/app.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/app.py#L1103) | Printed to standard output in terminal logs | Medium Information Disclosure | Remove debug prints logging hash slices or user emails |
| **Firebase Service Account Keys** | None present | No exposed JSON service account keys found in codebase | 🟢 Clean | Maintain strict `.gitignore` rules when Firebase is introduced |
| **Cloud Storage / API Keys** | None present | No third-party LLM or cloud API keys committed | 🟢 Clean | Use secure environment secret injection |

---

## 3. AUTHENTICATION AUDIT

### A. Login & Token Management
- **Password Hashing:** Passwords are salted and hashed using `bcrypt.hashpw(..., bcrypt.gensalt())` and verified via `bcrypt.checkpw()`.
- **CRITICAL DEFECT — Absence of Authentication Tokens:**
  - When `/login` succeeds, the backend responds with `{ "status": "success", "user": { "id": 1, "email": "...", "role": "patient" } }`.
  - No JSON Web Token (JWT), session identifier, or signed cookie is issued.
  - Subsequent requests rely exclusively on client-supplied IDs in query strings or request bodies.
  - **Impact:** The backend has no mechanism to cryptographically authenticate callers or verify caller identity after login.

### B. Password Reset Vulnerability
- **Endpoint:** `/update_password` in [`app.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/app.py#L1074-L1127).
- **Vulnerability:** Although the endpoint checks `current_password` and `new_password` if both are supplied, it allows password updates solely by providing `{ "id": target_user_id, "current_password": "...", "new_password": "..." }` with no authenticated session or multi-factor token verification.
- **Impact:** An unauthorized actor can reset passwords if credentials or IDs are exposed.

---

## 4. AUTHORIZATION & ACCESS CONTROL AUDIT (RBAC & IDOR)

### A. Universal Insecure Direct Object References (IDOR / BOLA)
Every single endpoint in the application suffers from missing authorization checks:
- `/get_patient_details/<patient_id>`: Any client can view detailed medical charts, conditions, and notes for any patient ID.
- `/get_medications/<user_id>`: Any client can view all active prescriptions and dosages for any user.
- `/delete_family_contact/<contact_id>`: Any client can delete any emergency contact by cycling integer IDs.
- `/save_doctor_notification_settings`: Any client can alter any doctor's alert settings.

### B. Missing Role Enforcement Middleware
- The database distinguishes between `role='patient'` and `role='doctor'`, but **no Flask route decorator or middleware verifies roles**.
- A patient account can invoke doctor endpoints (e.g. `/get_all_patients?doctor_id=1` or `/update_or_add_patient`) without restriction.

---

## 5. FILE SECURITY & INGESTION AUDIT

| File Security Check | Finding | Risk Level | Details & Impact |
| :--- | :--- | :--- | :--- |
| **File Transmission** | Base64 strings in JSON HTTP POST bodies | 🟠 High | Memory bloat (~33% overhead); synchronous in-memory parsing risks worker thread starvation on large continuous EEG files. |
| **File Type Validation** | Extension and byte header inspection via `validate_eeg_file` | 🟡 Medium | Checks `.edf`, `.csv`, `.dat`, `.txt` extensions and ASCII/binary headers, but lacks strict MIME-type sanitization. |
| **File Size Limits** | No `MAX_CONTENT_LENGTH` enforced in Flask | 🟠 High | An oversized EEG upload (>100MB) can cause out-of-memory (OOM) crash in the Flask process. |
| **Temporary File Safety** | `tempfile.mkstemp` with `os.unlink()` cleanup | 🟢 Polish | Temporary PDF and PNG files are unlinked in `try/finally` blocks, minimizing disk leakage. |
| **Direct File URL Access** | No open static upload directory exposed | 🟢 Polish | Files are not served from an unauthenticated public static folder. |

---

## 6. API SECURITY & ATTACK SURFACE

1. **Wildcard Cross-Origin Resource Sharing (CORS):**
   - Line 11 of `app.py` specifies `CORS(app)` with default wildcard `*` origins. Any malicious web page opened in a user's browser can issue cross-origin requests to `http://127.0.0.1:5000`.
2. **Detailed Error Stack Disclosure:**
   - Error handlers return `jsonify({"status": "error", "message": str(e)})` with HTTP 500 status codes. On database syntax errors or filesystem failures, internal paths, SQL syntax, and library versions are disclosed to clients.
3. **Debug Server Execution:**
   - Server runs with `debug=True` and `host='127.0.0.1'`. If exposed to network interfaces (`0.0.0.0`), the Werkzeug interactive debugger could allow arbitrary code execution.
4. **Missing Rate Limiting:**
   - No rate-limiting (e.g., `Flask-Limiter`) exists on `/login`, `/signup`, or `/predict_seizure_from_eeg`, allowing automated credential stuffing and resource exhaustion.

---

## 7. LOGGING & SENSITIVE INFORMATION DISCLOSURE

| Log Output | Code Location | Information Disclosed | Risk Level |
| :--- | :--- | :--- | :--- |
| `[PASSWORD DEBUG] ... hash_prefix={stored_password[:10]}` | `app.py:1103` | Bcrypt salt/hash slices, user emails, user IDs | 🟠 High |
| `[SIGNUP] User registered: id=..., email=..., role=...` | `app.py:636` | User email address and assigned role | 🟡 Medium |
| `[LOGIN] User logged in: id=..., email=..., role=...` | `app.py:700` | User email address and login timestamps | 🟡 Medium |
| `[NOTIFICATION] Triggered for user X: Title - Message` | `seizure_prediction_api.py:1080` | Medication names and patient user IDs | 🟡 Medium |

---

## 8. FIREBASE READINESS & CLOUD SECURITY POSTURE

- **Current State:** Zero Firebase SDKs or configuration files are active in the codebase.
- **Future Firestore Security Rules Requirements:**
  - **Never use open rules:** `allow read, write: if true;` is strictly prohibited.
  - **User Isolation:** `users/{userId}` must enforce `request.auth.uid == userId`.
  - **Doctor RBAC:** `patients/{patientId}` must check `request.auth.token.role == 'doctor' && resource.data.doctor_id == request.auth.uid`.
- **Firebase Storage Rules Requirements:**
  - `/eeg_uploads/{userId}/{fileId}` must strictly verify `request.auth.uid == userId`.

---

## 9. CONSENT, PRIVACY, AND AUDITABILITY

1. **Consent Tracking:**
   - Database tables `patient_privacy` and `privacy_settings` contain flags (`share_health_data`, `share_research`, `emergency_access`).
   - However, **these consent flags are not checked during ML inference or data querying**, rendering consent passive rather than enforced.
2. **Access Audit Trail:**
   - There is **no audit log table** recording when a doctor reads a patient's chart, when an EEG is downloaded, or when prescriptions are modified.
3. **Account Deletion & Anonymization:**
   - No GDPR "Right to be Forgotten" endpoint or automated PHI scrubbing workflow exists. Deleting a user leaves orphaned clinical records across child tables.

---

## 10. CLASSIFIED VULNERABILITY MATRIX

| Classification | Vulnerability Description | Affected Component | Impact |
| :--- | :--- | :--- | :--- |
| 🔴 **CRITICAL** | Universal Broken Object Level Authorization (IDOR) | All 49 Backend Routes | Unauthorized access, modification, or deletion of all patient/doctor records |
| 🔴 **CRITICAL** | Missing JWT / Session Token Authentication | Authentication Gateway | Inability to authenticate API callers; spoofing of user IDs |
| 🔴 **CRITICAL** | Insecure Password Reset Handling | `/update_password` | Account takeover risk |
| 🟠 **HIGH** | Uncapped Base64 EEG File Ingestion | `/predict_seizure_from_eeg` | Denial of Service via memory exhaustion (OOM) |
| 🟠 **HIGH** | Wildcard CORS Configuration | `CORS(app)` | Cross-Site Request Forgery / Malicious cross-origin invocation |
| 🟠 **HIGH** | Password Hash Slices Logged to Console | `app.py:1103` | Sensitive credential disclosure in log streams |
| 🟡 **MEDIUM** | Verbose Exception Messages Disclosing Internal Paths | Global Error Handlers | Information disclosure aiding reconnaissance |
| 🟡 **MEDIUM** | Passive Unenforced Consent Flags | `patient_privacy` Table | Regulatory non-compliance (GDPR/HIPAA consent violations) |
| 🟡 **MEDIUM** | Missing Audit Logging for Clinical Reads | Doctor Patient Charts | Inability to trace unauthorized medical record access |
| 🟢 **IMPROVEMENT**| Hardcoded Database Credentials in Code | `app.py:15` | Configuration hygiene (extract to `.env`) |

---

## 11. RECOMMENDED SECURITY REMEDIATION ROADMAP

1. **Phase 1: Stateless JWT Authentication & Middleware Guard**  
   Implement JWT generation on `/login`, attach `Authorization: Bearer <token>` in Flutter's `http` interceptor, and add a `@require_auth` decorator verifying user IDs and roles on every Flask route.

2. **Phase 2: Password Reset Security Hardening**  
   Require verified current password or cryptographic reset tokens on `/update_password`.

3. **Phase 3: Network & Error Hardening**  
   Restrict CORS to approved client origins, disable Flask debug mode in production, enforce `MAX_CONTENT_LENGTH = 50 * 1024 * 1024` (50MB), and sanitize error messages.

4. **Phase 4: PHI Audit Logging & Consent Enforcement**  
   Implement an immutable `audit_logs` table recording all clinical record accesses and enforce `share_research` flags before including EEG records in training pipelines.
