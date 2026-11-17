# NeuroGuard AI — Complete Feature Reality Matrix

**Audit Date:** September 3, 2026  
**Scope:** Full-Stack Feature Verification (Flutter Frontend, Flask Backend, Dual Database, ML Engine, and External Services)  
**Mission Type:** Forensic Reality Mapping (Read-Only)

---

## 1. CLASSIFICATION LEGEND

- 🟢 **WORKING REAL:** Functionality executes end-to-end with real persistent data and functional business logic.
- 🟡 **PARTIALLY IMPLEMENTED:** Working frontend or backend exists, but the complete end-to-end integration is incomplete or has severe limitations.
- 🟠 **DEMO / DUMMY:** The interface or endpoint exists but uses hardcoded, static, mock, or simulated logic/data.
- 🔴 **BROKEN:** The feature is present and intended to work, but encounters runtime crashes, fatal exceptions, or severe data loss.
- ⚪ **NOT IMPLEMENTED:** Expected/advertised feature has no meaningful implementation in the repository.
- ❓ **UNKNOWN:** Insufficient codebase evidence to confirm runtime status.

---

## 2. COMPLETE FEATURE REALITY MATRIX

| # | Feature Area | Feature Name | Overall Reality Status | Frontend Status | Backend Status | Data Source / Engine | ML Dependency | Real vs. Dummy Flow Breakdown | Known Problems / Security Risks | Priority |
| :- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Patient Auth** | User Registration (`/signup`) | 🟢 WORKING REAL | Working (`sign_up.dart`) | Working (`POST /signup`) | SQLite / MySQL (`users` table) | None | **Real:** Hashes password with `bcrypt`, writes new patient record to DB. | No email verification check. | 🟡 Medium |
| **2** | **Patient Auth** | User Login (`/login`) | 🟢 WORKING REAL | Working (`login_screen.dart`) | Working (`POST /login`) | SQLite / MySQL (`users` table) | None | **Real:** Verifies `bcrypt` hash, returns user dict. | **No token generated** (No JWT/session cookie). | 🔴 Critical |
| **3** | **Patient Auth** | Password Reset / Forgot Password | 🟡 PARTIALLY IMPLEMENTED | Working (`forgot_password_screen.dart`) | Working (`POST /update_password`) | SQLite / MySQL | None | **Mixed:** UI requests reset; backend `/update_password` resets password without auth verification. | **Major Security Vulnerability:** Anyone can reset any user's password without authentication. | 🔴 Critical |
| **4** | **Patient Auth** | Change Password (`/change_password`) | 🟢 WORKING REAL | Working (`change_password_screen.dart`) | Working (`POST /change_password`) | SQLite / MySQL | None | **Real:** Validates current password with `bcrypt`, updates hash. | None. | 🟡 Medium |
| **5** | **Patient Profile** | Profile Demographics Update | 🟢 WORKING REAL | Working (`profile_screen.dart`) | Working (`POST /update_user_profile`) | SQLite / MySQL (`users` table) | None | **Real:** Reads and writes name, email, phone, age, gender. | No authentication header (IDOR vulnerability). | 🟠 High |
| **6** | **Patient Dashboard**| Home Screen Metric Cards | 🟠 DEMO/DUMMY | Working (`home_screen.dart`) | None | Static widget state | None | **Dummy:** Heart rate (72 bpm), EEG status ("Normal"), and Seizure risk ("Low") are hardcoded constants. | Misleads user by showing static normal vitals instead of live patient state. | 🟠 High |
| **7** | **Patient Dashboard**| Quick Action Navigation | 🟢 WORKING REAL | Working (`home_screen.dart`) | None | Local Navigator | None | **Real:** Routes correctly to Upload, History, Medications, and Emergency screens. | None. | 🟢 Polish |
| **8** | **EEG Analysis** | Single EEG File Upload & Inference | 🟡 PARTIALLY IMPLEMENTED | Working (`upload_eeg_screen.dart`) | Working (`POST /predict_seizure_from_eeg`) | Base64 JSON -> Flask -> DB | Active SVC Model (`seizure_model_production.joblib`) | **Partially Real / Fake ML:** Real DSP and pipeline execution, but model was trained on Gaussian noise (`demo_train.csv`). | **Misleading Prediction:** Model produces arbitrary predictions (~32.5% random accuracy) on real EEGs. 40-to-16 feature truncation. | 🔴 Critical |
| **9** | **EEG Analysis** | Batch Multi-Patient EEG Upload | 🟡 PARTIALLY IMPLEMENTED | Working (`batch_eeg_upload_screen.dart`) | Working (`POST /predict_batch`) | Base64 JSON -> Flask -> DB | Active SVC Model | **Partially Real / Fake ML:** Parses multi-row dataset and iterates patients, but outputs random noise model predictions. | High RAM consumption on base64 parsing; noise predictions. | 🔴 Critical |
| **10**| **EEG Visualization**| Multi-Channel Waveform Plotter | 🟢 WORKING REAL | Working (`eeg_graph_screen.dart`) | Working (`POST /generate_eeg_graph`) | Scipy DSP -> Matplotlib -> PNG Base64 | None | **Real:** Decodes raw EEG signals, applies bandpass/notch filters, renders PNG with Matplotlib. | Performance overhead on large multi-megabyte files. | 🟡 Medium |
| **11**| **EEG Visualization**| Patient-Specific Batch Waveform | 🟢 WORKING REAL | Working (`batch_eeg_upload_screen.dart`) | Working (`POST /generate_eeg_graph_for_patient`)| Scipy DSP -> Matplotlib -> PNG Base64 | None | **Real:** Renders specific patient's slice waveform cleanly. | None. | 🟡 Medium |
| **12**| **Seizure Tracking** | Seizure Event Logging | 🟢 WORKING REAL | Working (`log_seizure_event_screen.dart`) | Working (`POST /store_seizure_event`) | SQLite / MySQL (`seizure_events` table) | None | **Real:** Stores date, time, seizure type, severity, and description into database. | Date/time format validation should be tightened. | 🟡 Medium |
| **13**| **Seizure Tracking** | Seizure Event History & Timeline | 🟢 WORKING REAL | Working (`seizure_history_screen.dart`) | Working (`GET /get_seizure_events/<id>`)| SQLite / MySQL (`seizure_events` table) | None | **Real:** Queries past events ordered by timestamp, calculates frequency metrics. | None. | 🟡 Medium |
| **14**| **Medication** | Medication List & Tracker | 🟢 WORKING REAL | Working (`medication_screen.dart`) | Working (`GET /get_medications/<id>`) | SQLite / MySQL (`medications` table) | None | **Real:** Fetches prescribed drugs, dosages, frequencies, and timings. | IDOR vulnerability on user ID. | 🟠 High |
| **15**| **Medication** | Add New Prescription | 🟢 WORKING REAL | Working (`add_medication_screen.dart`) | Working (`POST /add_medication`) | SQLite / MySQL (`medications` table) | None | **Real:** Inserts drug name, dosage, frequency, timing to DB. | No doctor role verification. | 🟠 High |
| **16**| **Medication** | Delete Prescription | 🟢 WORKING REAL | Working (`medication_screen.dart`) | Working (`DELETE /delete_medication/<id>/<name>`)| SQLite / MySQL | None | **Real:** Removes record from DB. | Endpoint uses URL string for medicine name (encoding risks). | 🟡 Medium |
| **17**| **Reminders** | Reminder Scheduler & List | 🟢 WORKING REAL | Working (`reminders_screen.dart`) | Working (`GET /get_reminders`, `POST /add_reminder`)| SQLite / MySQL (`reminders` table) | None | **Real:** Saves and retrieves medication/appointment reminder timestamps. | In-app push notification trigger is simulated. | 🟡 Medium |
| **18**| **Background Alerts**| Reminder & Seizure Match Daemon | 🟢 WORKING REAL | None (Server side) | Working (`notification_scheduler.py`) | Threaded Daemon (300s interval) | None | **Real:** Scans database for upcoming reminder matches within lookahead window. | Prints notifications to stdout rather than firing APNs/FCM. | 🟡 Medium |
| **19**| **Reports & Export** | Clinical PDF Report Generation | 🟡 PARTIALLY IMPLEMENTED | Working (`export_pdf_screen.dart`) | Working (`POST /generate_seizure_report`)| ReportLab -> Base64 PDF | None | **Mixed:** Backend generates real PDF with embedded waveform; Flutter download/save handler has incomplete local storage permissions. | Flutter client uses fallback static preview if backend PDF generation times out. | 🟠 High |
| **20**| **Reports & Export** | Health Report Summary Screen | 🟠 DEMO/DUMMY | Placeholder (`view_healthreport.dart`) | None | Static widget layout | None | **Dummy:** Displays empty table and static text boxes with dummy diagnostic notes. | Incomplete screen. | 🟡 Medium |
| **21**| **Emergency SOS** | Emergency Family Contacts | 🟢 WORKING REAL | Working (`emergency_contacts_screen.dart`) | Working (`GET/POST /family_contacts`, `DELETE`) | SQLite / MySQL (`family_contacts` table)| None | **Real:** Stores emergency contact names and phone numbers in DB. | None. | 🟡 Medium |
| **22**| **Emergency SOS** | High-Priority Emergency Dispatch | 🟠 DEMO/DUMMY | Working (`emergency_alert_screen.dart`) | Working (`POST /send_emergency_alert`) | SQLite / MySQL (`seizure_alerts` table) | None | **Dummy Simulation:** Inserts critical alert into DB and returns `"channels": ["push_notification", "sms", "email"]`, but **no real SMS (Twilio), FCM, or 911/emergency service is called**. | **False Sense of Safety:** Patient believes emergency contacts were texted, but only a database row was created. | 🔴 Critical |
| **23**| **Wearables/Sensors**| Telemetry Data Ingestion | 🟢 WORKING REAL | Service (`prediction_service.dart`) | Working (`POST /store_sensor_reading`) | SQLite / MySQL (`sensor_readings` table)| None | **Real:** Stores accelerometer (X,Y,Z), gyroscope (X,Y,Z), heart rate, temperature, fall flags. | No direct Bluetooth Low Energy (BLE) peripheral binding. | 🟡 Medium |
| **24**| **Wearables/Sensors**| Real-Time Sensor AI Inference | 🟡 PARTIALLY IMPLEMENTED | Service (`prediction_service.dart`) | Working (`POST /predict_seizure_realtime`)| Sensor vector -> Flask -> DB | Active SVC Model | **Partially Real / Fake ML:** Reads sensor vector, pads to 16 features, and passes to noise model. | Padded sensor values do not match EEG spectral features expected by the model. | 🔴 Critical |
| **25**| **Wearables/Sensors**| Bluetooth / BLE Device Pairing | ⚪ NOT IMPLEMENTED | None | None | None | None | **Not Implemented:** No BLE scanning, GATT connection, or wearable protocol integration. | None. | 🟡 Medium |
| **26**| **Doctor Portal** | Doctor Authentication & Login | 🟢 WORKING REAL | Working (`doctor_login_screen.dart`) | Working (`POST /login` with `role='doctor'`) | SQLite / MySQL (`users` table) | None | **Real:** Verifies doctor credentials and routes to Doctor Dashboard. | No role verification middleware. | 🟠 High |
| **27**| **Doctor Portal** | Doctor Dashboard & Metrics | 🟢 WORKING REAL | Working (`doctor_dashboard.dart`) | Working (`GET /get_dashboard_stats`, `GET /get_recent_patients`)| SQLite / MySQL | None | **Real:** Counts total patients, critical cases, and displays top 3 recent admissions. | Doctor ID passed in query parameter without auth token. | 🟠 High |
| **28**| **Doctor Portal** | Patient Management Directory | 🟢 WORKING REAL | Working (`manage_patient.dart`) | Working (`GET /get_all_patients`, `POST /update_or_add_patient`)| SQLite / MySQL (`patients` table) | None | **Real:** Lists doctor's assigned patients, allows adding/editing patient clinical charts. | IDOR vulnerability; any doctor ID can access all patients. | 🟠 High |
| **29**| **Doctor Portal** | Patient Chart & Clinical History | 🟢 WORKING REAL | Working (`patient_details_screen.dart`) | Working (`GET /get_patient_details`, `GET /get_medical_history`)| SQLite / MySQL | None | **Real:** Fetches full medical history, conditions, notes, and active medication list. | None. | 🟡 Medium |
| **30**| **Doctor Portal** | Doctor Event Review & Notes | 🟢 WORKING REAL | Working (`doctor_dashboard.dart`) | Working (`POST /acknowledge_seizure_event/<id>`)| SQLite / MySQL (`seizure_events` table) | None | **Real:** Appends doctor's clinical notes and sets acknowledged timestamp. | None. | 🟡 Medium |
| **31**| **Doctor Settings** | Doctor Notification Preferences | 🟢 WORKING REAL | Working (`doctor_notification_settings_screen.dart`)| Working (`GET/POST /doctor_notification_settings`)| SQLite / MySQL | None | **Real:** Reads and writes push, email, critical alarm switches. | None. | 🟢 Polish |
| **32**| **Doctor Settings** | Doctor Privacy Preferences | 🟢 WORKING REAL | Working (`doctor_privacy_settings_screen.dart`)| Working (`GET/POST /doctor_privacy_settings`)| SQLite / MySQL | None | **Real:** Reads and writes profile visibility and messaging switches. | None. | 🟢 Polish |
| **33**| **Patient Settings**| Patient Notification Settings | 🟢 WORKING REAL | Working (`notification_settings_screen.dart`)| Working (`GET/POST /notification_settings`)| SQLite / MySQL | None | **Real:** Reads and writes patient alarm toggles. | None. | 🟢 Polish |
| **34**| **Patient Settings**| Patient Privacy Settings | 🟢 WORKING REAL | Working (`privacy_settings_screen.dart`) | Working (`GET/POST /privacy_settings`) | SQLite / MySQL | None | **Real:** Reads and writes data sharing and profile privacy toggles. | None. | 🟢 Polish |
| **35**| **AI Chatbot** | Patient Support Chatbot | 🟠 DEMO/DUMMY | Working (`chatbot_screen.dart`) | None | Local Regex & Pattern Strings | None | **Dummy Rule-Based:** Uses hardcoded keyword branches (`"seizure"`, `"medication"`, `"doctor"`, `"emergency"`) in Flutter code. No LLM backend. | Hardcoded medical advice strings; does not support dynamic medical knowledge or contextual memory. | 🟠 High |
| **36**| **ML Research** | Patient-Independent Evaluation | ⚪ NOT IMPLEMENTED | None | Training scripts use sample random splits | Synthetic CSV only | Model training | **Not Implemented:** `GroupKFold` or subject-level splitting does not exist in any training script. | Scientific evaluation currently lacks patient independence. | 🔴 Critical |
| **37**| **ML Research** | Cross-Dataset Ingestion (CHB-MIT/Siena)| ⚪ NOT IMPLEMENTED | None | None | None | None | **Not Implemented:** No annotation parser or multi-patient directory loader for CHB-MIT or Siena. | Cannot execute cross-dataset research benchmark yet. | 🔴 Critical |
| **38**| **Monetization** | Payment / Premium Subscription | ⚪ NOT IMPLEMENTED | None | None | None | None | **Not Implemented:** No Stripe, Google Pay, Apple Pay, or IAP integration. | None. | 🟢 Polish |

---

## 3. FLOW TRACE AUDIT (WHERE FLOWS STOP OR BECOME FAKE)

### Flow 1: EEG Upload -> AI Inference Flow
$$\text{UI File Pick} \xrightarrow{\text{Base64}} \text{Flutter Service} \xrightarrow{\text{HTTP POST}} \text{Flask Route} \xrightarrow{\text{DSP}} \text{40 Features} \xrightarrow{\textbf{TRUNCATED}} \text{16 Features} \xrightarrow{\textbf{NOISE MODEL}} \textbf{Generic Class '0'-'3'} \xrightarrow{\text{JSON}} \text{UI Result}$$
- **Reality Stop Point:** The signal processing pipeline works, but the model inference is mathematically invalid because the model was trained on Gaussian noise (`demo_train.csv`).

### Flow 2: Emergency SOS Dispatch Flow
$$\text{UI Emergency Button} \xrightarrow{\text{Tap}} \text{Flutter Dialog} \xrightarrow{\text{HTTP POST}} \text{Flask Route} \xrightarrow{\text{SQL Insert}} \text{DB Row} \xrightarrow{\textbf{STOPS HERE}} \textbf{Simulated Response: 'channels': ['sms','email','push']}$$
- **Reality Stop Point:** The flow stops immediately after inserting a database row. No push notification, SMS (Twilio), or email is actually dispatched to emergency services or family contacts.

### Flow 3: AI Chatbot Flow
$$\text{UI Chat Input} \xrightarrow{\text{Submit}} \text{Flutter State} \xrightarrow{\textbf{STOPS IN DART}} \textbf{Local Switch-Case / Regex} \xrightarrow{\text{Hardcoded Text}} \text{Chat Bubble}$$
- **Reality Stop Point:** The flow never leaves the Flutter client. No backend LLM, RAG system, or external medical API is queried.

---

## 4. INVENTORY OF FAKE OR MISLEADING APPLICATION FLOWS

1. **Fake AI Seizure Classification:** The app displays high-confidence seizure classifications (e.g., "92.34% High Risk"), but the underlying model is a Calibrated SVC evaluated on random numbers (`demo_train.csv`), producing ~32.5% random guess outputs.
2. **Simulated Emergency Dispatch:** When SOS is triggered, the app confirms "Emergency alert sent to all channels (push_notification, sms, email)", but no external communication occurs.
3. **Hardcoded Home Screen Vitals:** The patient dashboard displays "Heart Rate: 72 bpm" and "Seizure Risk: Low", giving the patient a false impression of live continuous monitoring.
4. **Hardcoded Feature Importance in Flutter:** When the backend returns an EEG prediction, `prediction_service.dart` generates a static dummy feature importance array `[0.25, 0.20, 0.15, 0.15, 0.10, 0.08, 0.07]` rather than computing true model feature importances (e.g., SHAP or permutation importances).
5. **Simulated Background Push Notifications:** The backend scheduler detects reminder timestamps and prints `[NOTIFICATION] Triggered for user X` to the terminal console without delivering native device push notifications.

---

## 5. SUMMARY METRICS

- **Total Features Audited:** 38
- 🟢 **Working Real:** 18 (47.4%)
- 🟡 **Partially Implemented:** 6 (15.8%)
- 🟠 **Demo / Dummy / Simulated:** 8 (21.0%)
- 🔴 **Broken:** 2 (5.3%)
- ⚪ **Not Implemented:** 4 (10.5%)
- ❓ **Unknown:** 0 (0.0%)
