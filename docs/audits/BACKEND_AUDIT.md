# NeuroGuard AI — Forensic Backend Codebase Audit

**Audit Date:** September 3, 2026  
**Scope:** Python Backend Services (`lib/screens/auth/app.py`, `seizure_prediction_api.py`, `db_fallback.py`, `notification_scheduler.py`, and `ml_models/`)  
**Mission Type:** Forensic Read-Only Audit (No Code/Logic Modifications)

---

## 1. BACKEND ARCHITECTURE & FRAMEWORK IDENTITY

### A. Framework Classification
- **Framework:** **Python Flask** (`Flask 2.x/3.x` with `CORS`).
- **Architectural Note:** There is **no Django framework** in this repository (no `manage.py`, `django.contrib`, Django models, serializers, or Django ORM migrations). The backend is an asynchronous/threaded WSGI Flask server executed via [`run_server.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/run_server.py) and [`lib/screens/auth/app.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/app.py).

### B. Core Architectural Components
1. **Primary REST Service (`app.py`):** Handles core authentication, user profile management, doctor-patient clinical directory, medication prescriptions, and reminders.
2. **Seizure & Telemetry Blueprint (`seizure_prediction_api.py`):** Mounted at `/api/seizure`, handling EEG signal parsing, real-time sensor ingestion, ML inference, alert acknowledgment, and PDF report generation.
3. **Dual-Mode Database Adaptor (`db_fallback.py`):** Custom database shim detecting MySQL connectivity on `127.0.0.1:3306` with automatic graceful fallback to local SQLite (`neuroguard_ai_fallback.db`).
4. **Background Task Scheduler (`notification_scheduler.py`):** Threaded daemon running periodic checks (default 300s interval) to match seizure timestamps against upcoming medication/appointment schedules.
5. **Machine Learning Pipeline (`ml_models/production_pipeline.py`):** Multi-channel EEG signal preprocessing, bandpass filtering, feature extraction, and calibrated SVC classifier execution.

---

## 2. COMPLETE API INVENTORY (49 ENDPOINTS)

### Core Application Routes (`app.py`)

| # | Endpoint | Method | Purpose | Auth Required | Input Payload / Params | Response Summary | Status |
| :- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | `/signup` (alias `/register`) | `POST` | User registration | None (Public) | `{name, email, phone, password, role, age, gender}` | `201` User object & success message | Working |
| 2 | `/login` | `POST` | User authentication | None (Public) | `{email, password}` | `200` User profile with role & ID | Working |
| 3 | `/update_or_add_patient` | `POST` | Create or update patient profile | None (ID in payload) | `{patient_id, doctor_id, name, age, gender, medical_condition, email, phone, ...}` | `201` Confirmation | Working |
| 4 | `/get_patient_screen_stats` | `GET` | Doctor patient metrics | None (Query param) | `?doctor_id=1` | `200` `{total, critical, stable}` | Working |
| 5 | `/get_all_patients` | `GET` | Retrieve doctor's patient list | None (Query param) | `?doctor_id=1` | `200` List of patient records | Working |
| 6 | `/get_dashboard_stats` | `GET` | Doctor dashboard summary | None (Query param) | `?doctor_id=1` | `200` Total patients & emergency counts | Working |
| 7 | `/get_recent_patients` | `GET` | Recent patient registrations | None (Query param) | `?doctor_id=1` | `200` Top 3 latest patients | Working |
| 8 | `/get_patient_details/<patient_id>`| `GET` | Detailed patient chart | None (URL param) | `patient_id` string | `200` Full patient record + medicines | Working |
| 9 | `/get_medical_history/<user_id>` | `GET` | Patient clinical history | None (URL param) | `user_id` / `patient_id` | `200` Patient history & active meds | Working |
| 10| `/update_user_profile` | `POST` | Update account demographics | None (ID in payload) | `{user_id, name, email, phone, age, gender}` | `200` Updated user object | Working |
| 11| `/update_password` | `POST` | Direct password reset | None (ID in payload) | `{user_id, new_password}` | `200` Confirmation | Working |
| 12| `/change_password` | `POST` | Authenticated password change | Password check | `{user_id, current_password, new_password}` | `200` Success / 401 Invalid Pass | Working |
| 13| `/get_notification_settings/<id>`| `GET` | Patient alert settings | None (URL param) | `user_id` integer | `200` Preferences object | Working |
| 14| `/save_notification_settings` | `POST` | Update patient alert settings | None (ID in payload) | `{user_id, all_notifications, emergency_alerts, ...}`| `200` Confirmation | Working |
| 15| `/get_privacy_settings/<id>` | `GET` | Patient privacy settings | None (URL param) | `user_id` integer | `200` Privacy preferences | Working |
| 16| `/save_privacy_settings` | `POST` | Update patient privacy | None (ID in payload) | `{user_id, share_data, public_profile, ...}` | `200` Confirmation | Working |
| 17| `/get_doctor_notification_settings/<id>`| `GET` | Doctor alert preferences | None (URL param) | `user_id` integer | `200` Doctor settings | Working |
| 18| `/save_doctor_notification_settings` | `POST` | Save doctor alert prefs | None (ID in payload) | `{user_id, push_notifications, email_notifications, ...}`| `200` Confirmation | Working |
| 19| `/get_doctor_privacy_settings/<id>` | `GET` | Doctor privacy preferences | None (URL param) | `user_id` integer | `200` Doctor privacy | Working |
| 20| `/save_doctor_privacy_settings` | `POST` | Save doctor privacy prefs | None (ID in payload) | `{user_id, profile_visibility, allow_messages, ...}` | `200` Confirmation | Working |
| 21| `/get_family_contacts/<user_id>`| `GET` | Emergency contacts list | None (URL param) | `user_id` integer | `200` List of contacts | Working |
| 22| `/add_family_contact` | `POST` | Add emergency family contact| None (ID in payload) | `{user_id, name, phone_number}` | `201` Confirmation | Working |
| 23| `/delete_family_contact/<id>` | `DELETE`| Remove emergency contact | None (URL param) | `contact_id` integer | `200` Confirmation | Working |
| 24| `/add_reminder` | `POST` | Create medication reminder | None (ID in payload) | `{user_id, title, reminder_type, reminder_date, reminder_time}`| `201` Confirmation | Working |
| 25| `/get_reminders/<user_id>` | `GET` | List user reminders | None (URL param) | `user_id` string | `200` List of reminders | Working |
| 26| `/get_medications/<user_id>` | `GET` | List active prescriptions | None (URL param) | `user_id` integer | `200` List of medications | Working |
| 27| `/add_medication` | `POST` | Prescribe new medication | None (ID in payload) | `{user_id, medicine_name, dose, frequency, timing, ...}`| `201` Confirmation | Working |
| 28| `/delete_medication/<id>/<name>`| `DELETE`| Remove medication | None (URL param) | `user_id`, `medicine_name` | `200` Confirmation | Working |
| 29| `/train_model` | `POST` | On-demand model training | None (Public) | `{features_csv_path, target_column, model_dir}`| `200` Training accuracy & path | Working |

---

### Seizure & Telemetry Blueprint Routes (`seizure_prediction_api.py` under `/api/seizure`)

| # | Endpoint | Method | Purpose | Input Payload | Response Summary | Status |
| :- | :--- | :--- | :--- | :--- | :--- | :--- |
| 30| `/api/seizure/predict_seizure_from_eeg`| `POST` | EEG file ML inference | `{user_id, eeg_file (base64), eeg_filename, ...}` | `200` Prediction label, confidence, risk | Working |
| 31| `/api/seizure/predict_seizure_realtime`| `POST` | Real-time sensor ML inference| `{user_id, sensor_data: {heart_rate, temp, ...}}` | `200` Prediction & risk level | Working |
| 32| `/api/seizure/get_prediction_history` | `GET` | Historical ML inferences | `?user_id=1&limit=50` | `200` List of past prediction records | Working |
| 33| `/api/seizure/get_latest_prediction` | `GET` | Latest single prediction | `?user_id=1` | `200` Latest prediction record | Working |
| 34| `/api/seizure/store_sensor_reading` | `POST` | Persist raw sensor metrics | `{user_id, data_source, heart_rate, accel_x, ...}` | `201` Stored reading ID | Working |
| 35| `/api/seizure/store_alert` | `POST` | Store seizure alarm | `{user_id, alert_type, seizure_type, severity, ...}` | `201` Stored alert ID | Working |
| 36| `/api/seizure/get_sensor_history` | `GET` | Fetch telemetry timeline | `?user_id=1&hours=24&limit=100` | `200` Telemetry timeseries records | Working |
| 37| `/api/seizure/get_alerts` | `GET` | Fetch logged alarms | `?user_id=1&days=7&severity=HIGH` | `200` List of alert records | Working |
| 38| `/api/seizure/acknowledge_alert/<id>` | `POST` | Mark alert acknowledged | `{acknowledged_by, action_taken}` | `200` Confirmation | Working |
| 39| `/api/seizure/store_seizure_event` | `POST` | Log confirmed seizure event | `{user_id, event_date, event_time, severity, ...}` | `201` Stored event ID | Working |
| 40| `/api/seizure/get_seizure_events/<id>` | `GET` | List patient seizure events | `?days=30&limit=50` | `200` List of events | Working |
| 41| `/api/seizure/get_upcoming_alerts/<id>`| `GET` | Query scheduled alerts | `?hours_ahead=24` | `200` Upcoming reminder matches | Working |
| 42| `/api/seizure/trigger_notification` | `POST` | Dispatch push notification | `{event_id, user_id, notification_type, message}` | `200` Notification sent | Working |
| 43| `/api/seizure/send_emergency_alert` | `POST` | Dispatch high-priority alert | `{user_id, patient_id, severity, message, ...}` | `201` Emergency confirmation | Working |
| 44| `/api/seizure/acknowledge_seizure_event/<id>`| `POST` | Doctor notes on event | `{acknowledged: true, doctor_notes}` | `200` Confirmation | Working |
| 45| `/api/seizure/generate_eeg_graph` | `POST` | Render EEG waveform PNG | `{eeg_file (base64), eeg_filename}` | `200` Base64 PNG image | Working |
| 46| `/api/seizure/generate_seizure_report`| `POST` | Generate clinical PDF | `{user_id, eeg_file (base64), eeg_filename}` | `200` Base64 PDF document | Working |
| 47| `/api/seizure/predict_batch` | `POST` | Batch multi-patient EEG | `{user_id, eeg_file (base64), eeg_filename}` | `200` List of patient predictions | Working |
| 48| `/api/seizure/dataset_summary` | `POST` | EEG metadata statistics | `{eeg_file (base64), eeg_filename}` | `200` Row count, channels, classes | Working |
| 49| `/api/seizure/generate_eeg_graph_for_patient`| `POST` | Render waveform for single patient in batch | `{eeg_file (base64), eeg_filename, patient_index}`| `200` Base64 PNG image | Working |

---

## 3. AUTHENTICATION AUDIT

- **Password Hashing:** Implemented using `bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())` and verified with `bcrypt.checkpw()`.
- **CRITICAL WEAKNESS — No Session / Token Architecture:**
  - Login returns a raw user dictionary (`id`, `name`, `email`, `role`) with no JWT token, session token, or HMAC cookie.
  - Subsequent API calls require no `Authorization: Bearer <token>` header or authenticated session cookie.
- **Password Reset Vulnerability:**
  - `/update_password` (line 1074 in `app.py`) allows updating any user's password solely by supplying `{user_id: <target_id>, new_password: "..."}` with **zero verification of current password or auth token**.

---

## 4. AUTHORIZATION & ROLE-BASED ACCESS CONTROL (RBAC)

- **CRITICAL WEAKNESS — Universal IDOR (Insecure Direct Object Reference):**
  - None of the 49 endpoints verify whether the caller owns or has clinical rights to the requested `user_id` or `patient_id`.
  - Any client can query all patient details (`/get_patient_details/<patient_id>`), fetch medication charts (`/get_medications/<user_id>`), delete contacts (`/delete_family_contact/<id>`), or alter doctor preferences by providing arbitrary IDs.
- **No Role Enforcement Middleware:**
  - Role (`doctor` vs. `patient`) is stored in the database but never enforced via Flask route decorators or middleware.

---

## 5. DATABASE LAYER & PERSISTENCE RISKS

- **Dual-Mode Backend Architecture:**
  - Automatically attempts MySQL connection on `127.0.0.1:3306` with default credentials (`root` / empty password).
  - Automatically falls back to SQLite (`neuroguard_ai_fallback.db`) via `db_fallback.py` when MySQL connection fails.
- **SQL Dialect Abstraction (`db_fallback.py`):**
  - Adapts parameter markers (`%s` on MySQL vs. `?` on SQLite) and temporal functions (`NOW()` vs. `datetime('now')`).
- **Absence of Migration Framework:**
  - Database tables are initialized via raw multi-line SQL strings inside `init_db()`.
  - Schema alterations require manual SQL coordination without rollback migrations.
- **Database File Committed in VCS:**
  - `neuroguard_ai_fallback.db` resides in the repository root and is tracked in Git, creating potential data leakage risks.

---

## 6. EEG FILE HANDLING & INGESTION AUDIT

- **Transmission Method:** EEG files (`.csv`, `.edf`, `.txt`, `.dat`) are base64-encoded on the client and sent inside JSON HTTP request bodies.
- **Memory & Resource Risk:**
  - Base64 encoding inflates payload sizes by ~33%.
  - Entire EEG datasets are decoded in memory (`base64.b64decode`) into RAM rather than streamed through multipart chunked uploads.
  - Large clinical recordings (>50MB) risk triggering out-of-memory (OOM) crashes in the Flask process.
- **Format Validation:**
  - `ml_models/production_pipeline.py` provides `validate_eeg_file` and `detect_file_format` inspecting headers and ASCII/binary structure.
- **Temporary Files:**
  - Temporary PNG waveforms and PDF reports use `tempfile.mkstemp` and are safely unlinked in cleanup blocks.

---

## 7. MACHINE LEARNING INFERENCE & INTEGRATION AUDIT

- **Model Execution Pipeline:**
  - Production model: Calibrated Support Vector Classifier (`seizure_model_production.joblib`) with `StandardScaler` (`seizure_scaler.joblib`) and feature selection (`seizure_feature_selector.joblib`).
  - Signal processing: Bandpass filter (0.5–45 Hz), notch filter (50/60 Hz), FFT/STFT spectral band power calculation, and time-domain statistical moments.
- **Known Risk — Unpickling Version Warning:**
  - Scikit-learn outputs `InconsistentVersionWarning` on model load (`SVC` compiled in scikit-learn 1.8.0 loaded into 1.9.0).
- **Rule Violation in `/train_model` Endpoint:**
  - Line 1697 of `app.py` implements a naive `train_test_split(test_size=0.2)` on tabular rows without patient-independent cohort splitting, violating Section A of `ML_RESEARCH_RULES.md`.

---

## 8. ERROR HANDLING & LOGGING AUDIT

- **Exception Leakage:**
  - Endpoints frequently return `jsonify({'status': 'error', 'message': str(e)}), 500`. On database or library crashes, internal SQL syntax errors and filesystem paths are directly disclosed to clients.
- **Logging Sanitization:**
  - Server console logs print plain email addresses and transaction types. Passwords are not printed, but user IDs and event payloads are logged unmasked.

---

## 9. CRITICAL ISSUES & CLASSIFICATION

### 🔴 Critical Security & Integrity Issues
1. **Unauthenticated Password Reset (`/update_password`):** Allows overwriting any account's password without authentication tokens or current password verification.
2. **Missing Token-Based Authentication & Universal IDOR:** Endpoints lack JWT or session validation, allowing unauthorized cross-tenant data access.
3. **In-Memory Base64 EEG File Ingestion:** High-volume EEG data transmitted as Base64 JSON risks memory exhaustion.

### 🟠 High Priority Issues
4. **Scikit-Learn Version Drift Warning:** ML model unpickling warning across SVC and CalibratedClassifierCV artifacts.
5. **No Migration Engine:** Database DDL is hardcoded in Python startup scripts without versioned schema migrations.
6. **Tracked SQLite Database Binary:** Staged/tracked `.db` binary file in version control.

### 🟡 Medium Priority Issues
7. **Verbose Exception Messages:** Server error responses return raw `str(e)` disclosing internal paths.
8. **Unsafe Tabular Retraining Endpoint (`/train_model`):** Naive random split in `app.py` violates patient-independent evaluation rules.

### 🟢 Polish & Minor
9. **Dual Route Aliasing:** Redundant duplicate routes (`/signup` vs. `/register`, `/change_password` vs. `/change-password`).

---

## 10. RECOMMENDED STABILIZATION ORDER

1. **Mission 5: Security Hardening & Authentication Middleware** — Implement stateless JWT token validation and remove the vulnerable `/update_password` bypass.
2. **Mission 6: Request Parameter Sanitization & Exception Shielding** — Standardize API error responses to return generic error messages while logging details server-side.
3. **Mission 7: ML Pipeline Version Alignment** — Re-serialize model and scaler artifacts under the active runtime scikit-learn version without altering model mathematics or weights.
4. **Mission 8: Multipart EEG Streaming Uploads** — Upgrade base64 JSON file upload to standard multipart/form-data streaming to support large clinical recordings.
