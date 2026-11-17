# NeuroGuard AI — Forensic Flutter Codebase Audit

**Audit Date:** September 3, 2026  
**Scope:** Complete Flutter Mobile & Web Frontend (`lib/`)  
**Mission Type:** Forensic Read-Only Audit (No Code/UI Modifications)

---

## 1. ARCHITECTURE SUMMARY

- **Framework & SDK:** Flutter SDK (Dart SDK `^3.12.2`).
- **Entry Point:** [`lib/main.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/main.dart) wraps [`NeuroGuardAI`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/main.dart#L12) with [`ListenableBuilder`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/main.dart#L18) listening to [`LanguageProvider`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/services/language_service.dart), rendering [`LoginScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/login_screen.dart).
- **Navigation & Routing:** Imperative navigation (`Navigator.push`, `Navigator.pushReplacement`, `MaterialPageRoute`). No declarative router (like `go_router`) is configured. Bottom navigation bars use `IndexedStack` inside [`PatientMainDashboard`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/patient_main_dashboard.dart) and [`DoctorDashboard`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/doctor_dashboard.dart).
- **State Management:** Local `StatefulWidget` / `setState()` alongside singletons (`SensorDataService`, `AlertsService`, `PredictionService`, `LanguageProvider`, and `GlobalRefreshNotifier`).
- **Data & API Layer:** Direct HTTP calls using `package:http` via [`ApiService`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/database/api_service.dart) and inline `http.get` / `http.post` requests targeting the Flask backend on `http://127.0.0.1:5000`.
- **Localization:** Flutter localization using `AppLocalizations` across English, Arabic, and Urdu (`l10n.yaml`, `lib/l10n/`).
- **Responsiveness:** Dedicated [`Responsive`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/responsive/responsive.dart) helper utility supporting Watch, Mobile, Tablet, and Desktop breakpoints.

---

## 2. COMPLETE SCREEN INVENTORY (37 DART SCREEN FILES)

### A. Authentication Screens (`lib/screens/auth/`)
1. [`LoginScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/login_screen.dart) — Multi-role authentication (Patient / Doctor login with language toggle).
2. [`SignupScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/signup_screen.dart) — Account registration with role selection, validation, and auto-navigation.

### B. Patient Screens (`lib/screens/patient/`)
3. [`PatientMainDashboard`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/patient_main_dashboard.dart) — Shell with App Bar, Drawer, and Bottom Navigation Bar.
4. [`PatientHomeScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/patient_dashboard.dart) — Patient home overview, health summary cards, quick action tiles.
5. [`PredictionAndSensorDashboard`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/prediction_and_sensor_dashboard.dart) — Live seizure prediction & sensor telemetry telemetry cards.
6. [`RealTimeSensorDataScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/realtime_sensor_data_screen.dart) — Real-time BLE sensor graph & metric streaming.
7. [`PatientBluetoothScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/bluetooth_screen.dart) — BLE device scanning, pairing, and status indicators.
8. [`CallScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/call_screen.dart) — Emergency SOS calling (1122/911) & emergency family contacts manager.
9. [`ChatbotScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/chatbot_screen.dart) — Patient educational conversational assistant (local knowledge base).
10. [`MedicalHistoryScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/history_screen.dart) — Patient clinical timeline and diagnosis logs.
11. [`RemindersScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/reminder_screen.dart) — Medication & doctor appointment reminder list with creation dialogs.
12. [`ViewMedicationScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/view_medication.dart) — Prescribed medicines list with schedule cards & add-medication modal.
13. [`ViewHealthReportScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/view_healthreport.dart) — Health parameter tabular summary.
14. [`PatientProfileScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/patient_profile.dart) — Account details, language selector, security settings, logout.
15. [`EditProfileScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/edit_profile.dart) — Form to update patient contact details and personal info.
16. [`PatientChangePasswordScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/change_password.dart) — Password change form with old/new validation.
17. [`PrivacyAndSecurityScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/privacy_security.dart) — Data privacy policy, encryption notices, permission audits.
18. [`NotificationSettingsScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/notification_setting.dart) — Push notification and emergency alert preferences.

### C. Doctor Screens (`lib/screens/doctor/`)
19. [`DoctorDashboard`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/doctor_dashboard.dart) — Doctor navigation shell (App Bar, Drawer, Bottom Nav).
20. [`HomeScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/home_screen.dart) — Clinical counters, AI summary, recent patient cards, quick actions.
21. [`PatientsScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/patients_screen.dart) — Searchable patient registry, condition status filters.
22. [`PatientRecordScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/patient_record.dart) — Full patient medical chart, medications, EEG history.
23. [`AddPatientScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/add_patient_screen.dart) — Clinical registration form for new patients under doctor care.
24. [`UpdatePatientScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/update_patient_screen.dart) — Form to update patient condition, last EEG, and clinical notes.
25. [`DoctorMedicationScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/medication_screen.dart) — Form for doctors to prescribe medications to specific patients.
26. [`UploadEEGScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/upload_eeg_screen.dart) — Multi-format EEG file upload (`.csv`, `.edf`, `.dat`), ML inference trigger, waveform summary.
27. [`ReportsScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/reports_screen.dart) — Clinical report catalog and report processing statistics.
28. [`ExportPdfScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/export_pdf_screen.dart) — PDF export configuration screen with section toggles.
29. [`DoctorChatbotScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/doctor_chatbot_screen.dart) — Clinical assistant chatbot with quick diagnostic command prompts.
30. [`DoctorBluetoothScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/bluetooth_screen.dart) — BLE clinical device scanner and pair interface.
31. [`MedicalHistoryScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/history_screen.dart) — Doctor view of patient historical timeline.
32. [`DoctorNotificationSettingsScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/notification_settings_screen.dart) — Doctor alert preferences.
33. [`DoctorPrivacyAndSecurityScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/privacy_and_security_screen.dart) — Regulatory compliance and security terms.
34. [`ProfileScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/profile_screen.dart) — Doctor profile card, clinic info, password change link.
35. [`DoctorEditProfileScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/edit_profile_screen.dart) — Profile editor for doctors.
36. [`DoctorChangePasswordScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/change_password_screen.dart) — Doctor password update form.
37. [`AddProfileScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/add_profile_screen.dart) — Secondary doctor profile configuration form.

---

## 3. FEATURE REALITY TABLE

| Feature Module | Screen(s) | Reality Status | Data Source | Notes / Findings |
| :--- | :--- | :--- | :--- | :--- |
| **Authentication & Signup** | `login_screen.dart`, `signup_screen.dart` | **WORKING** | Real Backend (`/login`, `/signup`) | Full validation, bcrypt password hashing, dynamic role redirection. |
| **Doctor Dashboard Stats** | `doctor/home_screen.dart` | **PARTIAL** | Backend API + Hardcoded | Total patients & emergency alerts are real; "EEG Reports (89)" & "AI Accuracy (97%)" are hardcoded strings. |
| **Patient List & Search** | `doctor/patients_screen.dart` | **WORKING** | Real Backend (`/get_all_patients`) | Real live filtering by name and condition; connects to backend. |
| **Patient Record Detail** | `doctor/patient_record.dart` | **WORKING** | Real Backend (`/get_patient_details`) | Fetches full demographics, last EEG notes, and active medicines. |
| **Add / Update Patient** | `add_patient_screen.dart`, `update_patient_screen.dart`| **WORKING** | Real Backend (`/update_or_add_patient`) | Form validates inputs and updates patient record in database. |
| **Medication Management** | `patient/view_medication.dart`, `doctor/medication_screen.dart`| **WORKING** | Real Backend (`/get_medications`, `/add_medication`) | Real creation, database storage, and listing. |
| **EEG Upload & Prediction**| `doctor/upload_eeg_screen.dart` | **WORKING** | Real Backend (`/api/seizure/predict_seizure_from_eeg`) | Base64 encodes `.csv`/`.edf` files, executes ML inference pipeline, returns confidence scores. |
| **EEG Reports Overview** | `doctor/reports_screen.dart` | **DUMMY** | Hardcoded Mock Data | Recent report cards ("Ali Raza", "Fatima Noor", "Ahmed Khan") and processed count (89) are hardcoded mocks. |
| **PDF Report Export** | `doctor/export_pdf_screen.dart` | **DUMMY** | Simulated UI State | Checkboxes toggle state, but "Export as PDF" only sets `pdfGenerated = true`; "Download PDF" displays a "will be connected later" snackbar. |
| **Patient Chatbot** | `patient/chatbot_screen.dart` | **PARTIAL** | Local Hardcoded Knowledge Base | Static keyword matcher with extensive text definitions; fallback to API not fully active. |
| **Doctor Chatbot** | `doctor/doctor_chatbot_screen.dart` | **PARTIAL** | Local Knowledge Base + Backend API | Pattern-matching medical assistant that saves history to `/save_chat_message`. |
| **Emergency SOS Call** | `patient/call_screen.dart` | **WORKING** | System URL Launcher + Real Backend | Real `tel:1122` launcher; family contacts loaded from and saved to `/get_family_contacts`. |
| **Reminders System** | `patient/reminder_screen.dart` | **WORKING** | Real Backend (`/get_reminders`, `/add_reminder`) | Real creation and deletion with background Python scheduler. |
| **Live Sensor Streaming**| `realtime_sensor_data_screen.dart` | **PARTIAL** | BLE Streams / Fallback Simulation | Reads BLE characteristics if connected; falls back to simulated sensor values when unpaired. |
| **Patient Health Report** | `patient/view_healthreport.dart` | **DUMMY** | Empty Placeholders | Health parameter table values are hardcoded empty strings `_tableCell("")`. |
| **Notification Settings** | `notification_setting.dart`, `doctor/notification_settings_screen.dart` | **WORKING** | Real Backend (`/save_notification_settings`) | Toggles persist to user settings table in DB. |

---

## 4. BUTTON & ACTION AUDIT

| Screen | Control / Action | Action Type | Classification | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **LoginScreen** | "Login" button | Form Submission | **WORKING** | Authenticates credentials, sets language, routes to role dashboard. |
| **Doctor HomeScreen** | "View AI Analysis" button | Navigation / Action | **DUMMY** | Has empty callback `onPressed: () {}`. |
| **Doctor HomeScreen** | "Update" quick action | Navigation | **WORKING** | Opens `UpdatePatientScreen` and refreshes dashboard on pop. |
| **Doctor HomeScreen** | "Upload EEG" quick action | Navigation | **WORKING** | Opens `UploadEEGScreen`. |
| **Doctor ReportsScreen**| Report item tile | List Item Tap | **DUMMY** | Has empty callback `onTap: () {}`. |
| **ExportPdfScreen** | "Export as PDF" button | Action | **DUMMY** | Sets mock boolean `pdfGenerated = true` without PDF compilation. |
| **ExportPdfScreen** | "Download PDF" button | Action | **BROKEN / DUMMY**| Displays "Download functionality will be connected later" snackbar. |
| **Patient HomeScreen** | "View Health Report" | Navigation | **PARTIAL** | Opens `ViewHealthReportScreen` (which contains empty table cells). |
| **Patient HomeScreen** | "Live Sensors" | Navigation | **WORKING** | Opens `RealTimeSensorDataScreen`. |
| **Patient HomeScreen** | "Chat with AI" | Navigation | **WORKING** | Opens `ChatbotScreen`. |
| **Patient CallScreen** | "Emergency 1122" | Phone Call Trigger | **WORKING** | Launches device phone dialer via `url_launcher`. |
| **Patient CallScreen** | "Add Contact" button | Modal Form Submission| **WORKING** | Saves contact to backend API and updates list. |
| **UploadEEGScreen** | "Select EEG File" | File Picker | **WORKING** | Opens native file browser for `.csv`, `.edf`, `.dat`. |
| **UploadEEGScreen** | "Analyze EEG" | API Trigger | **WORKING** | Dispatches EEG payload to Flask ML inference endpoint. |

---

## 5. DATA REALITY AUDIT

1. **Real Backend Integration (SQLite / Flask):**
   - User authentication (`/login`, `/signup`, `/change_password`)
   - Patient registry (`/get_all_patients`, `/get_patient_details`, `/update_or_add_patient`)
   - Prescriptions & medications (`/get_medications`, `/add_medication`)
   - Reminders (`/get_reminders`, `/add_reminder`, `/delete_reminder`)
   - Emergency contacts (`/get_family_contacts`, `/add_family_contact`, `/delete_family_contact`)
   - ML inference (`/api/seizure/predict_seizure_from_eeg`, `/api/seizure/predict_batch`)
   - Notification settings (`/get_notification_settings`, `/save_notification_settings`)
2. **Hardcoded / Dummy Data:**
   - Doctor dashboard static counter cards ("89 EEG Reports", "97% AI Accuracy").
   - Doctor reports catalog (`reports_screen.dart` static list items: "Ali Raza", "Fatima Noor", "Ahmed Khan").
   - Patient tabular parameters in `view_healthreport.dart` (empty string values).
   - Chatbot knowledge dictionaries (extensive hardcoded string templates in `chatbot_screen.dart`).
3. **Firebase Cloud Storage / Firestore:**
   - **Zero active connections.** Firebase references in comments/docs only. No `firebase_core` initialization or live Firebase SDK calls exist in Flutter.

---

## 6. UX STATE & RESILIENCE AUDIT

- **Loading States:** Well implemented on primary screens (`CircularProgressIndicator` on data fetch in `patient_dashboard.dart`, `home_screen.dart`, `patients_screen.dart`, `upload_eeg_screen.dart`).
- **Success Feedback:** Standard `ScaffoldMessenger` SnackBar alerts on login, patient creation, reminder addition, and medication addition.
- **Empty States:** Present in `patients_screen.dart` ("No patients found"), `reminders_screen.dart`, and `view_medication.dart`. Missing in `reports_screen.dart` (hardcoded list prevents empty state).
- **Error & Network Failure Handling:** Handled with try/catch blocks and user SnackBars, though timeouts occasionally swallow errors silently to avoid UI crashes.

---

## 7. UI QUALITY & DESIGN SYSTEM ASSESSMENT

- **Visual Palette:**
  - Primary color: Emerald Green (`#0B8F55`, `#22C55E`).
  - Backgrounds: Neutral clean grey/green (`#F6FAF8`, `#F5F8FA`).
  - Danger / Emergency: Orange (`#FF9800`) and Red (`#E53935`).
- **Typography & Consistency:** Typography uses standard Material 3 styles (`titleSize`, `subtitleSize` scaled through `Responsive` helper).
- **Responsiveness:** Supported across Watch, Mobile, Tablet, and Desktop using `MediaQuery` and `Responsive` breakpoints.
- **Healthcare Usability & Safety:**
  - Emergency call triggers are prominent in patient views.
  - Medical disclaimers exist in chatbots ("Educational only — NOT medical advice").

---

## 8. DEPENDENCY MAPPING

```
[Flutter UI Screen]
       ↓
[Local State / Controller]
       ↓
[Service Layer (ApiService / PredictionService / AlertsService / SensorDataService)]
       ↓
[REST HTTP Client (http://127.0.0.1:5000)]
       ↓
[Flask Backend API (app.py / seizure_prediction_api.py)]
       ↓
[SQLite Fallback DB (neuroguard_ai_fallback.db) / ML Models (production_pipeline.py)]
```

### Key Hidden Dependencies:
1. **Host-Port Binding:** Flutter screens directly hardcode `http://127.0.0.1:5000` (or `http://10.0.2.2:5000` for Android emulators). Changing backend ports will break API calls across multiple screens if not centralized in `ApiService.baseUrl`.
2. **Duplicate Class Names:** `MedicalHistoryScreen` is declared identically in both `lib/screens/patient/history_screen.dart` and `lib/screens/doctor/history_screen.dart`, creating potential namespace confusion during cross-screen refactors.
3. **Session Parameter Coupling:** Screens receive raw untyped `Map<String, dynamic>? userData` from `LoginScreen` instead of strongly-typed `UserModel` classes.

---

## 9. CRITICAL ISSUES & CLASSIFICATION

### 🔴 Critical Issues
1. **7,324 Dart Analyzer Warnings:** Widespread `override_on_non_overriding_member` warnings across stateful widget lifecycles in 30+ screens due to Flutter SDK lifecycle changes.
2. **Hardcoded API Base URLs Across Screens:** Multiple screens bypass `ApiService.baseUrl` and instantiate direct `http.get("http://127.0.0.1:5000/...")` strings, causing endpoint fragility.

### 🟠 High Priority Issues
3. **Dummy PDF Generation:** `export_pdf_screen.dart` simulates PDF creation with state booleans and placeholder snackbars rather than generating real PDF documents.
4. **Hardcoded Clinical Metrics on Doctor Home:** "89 EEG Reports" and "97% AI Accuracy" are static hardcoded strings masquerading as live metrics.
5. **Empty Table in Health Report:** `view_healthreport.dart` renders a table with empty cell strings.

### 🟡 Medium Priority Issues
6. **Class Name Collisions:** Identically named `MedicalHistoryScreen` classes in doctor and patient directories.
7. **Chatbot Knowledge Base Inlining:** 72KB of hardcoded string definitions directly in `chatbot_screen.dart` rather than externalized JSON/assets.

### 🟢 Polish & Minor
8. **UI Spacing & Alignment Nuances:** Minor margin inconsistencies between card headers across doctor and patient dashboards.

---

## 10. RECOMMENDED FUTURE UI MISSION ORDER

1. **Mission 3: Surgical Dart Analyzer & Lint Resolution** — Resolve the 7,324 analyzer warnings without altering UI layout or widget logic.
2. **Mission 4: API Endpoint Centralization** — Unify all hardcoded `http://127.0.0.1:5000` string literals into `ApiService.baseUrl` with proper environment-aware configuration.
3. **Mission 5: Real PDF Report Generator Integration** — Connect `export_pdf_screen.dart` to the real backend PDF generation service (`reportlab` / `MedicalReportGeneratorService`).
4. **Mission 6: Replace Dummy Clinical Metrics & Reports** — Wire doctor dashboard metrics and recent reports list to dynamic backend endpoints.
