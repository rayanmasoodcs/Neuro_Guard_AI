# NeuroGuard AI — Baseline Project State & Checkpoint Record

**Document Date:** September 3, 2026  
**Checkpoint Purpose:** Formal state-of-the-repository capture prior to commencing functional audits and implementation missions.

---

## 1. REPOSITORY & VERSION CONTROL STATUS

- **Active Git Branch:** `main`
- **Current HEAD Commit:** `8b82fc8` (`fix(sql): make seizure_predictions/seizure_alerts DDL compatible with sqlite fallback; use alert_message column`)
- **Recent Commit History:**
  - `8b82fc8` fix(sql): make seizure_predictions/seizure_alerts DDL compatible with sqlite fallback; use alert_message column
  - `28970b7` chore: fix analyzer errors across project
  - `d231083` Complete database integration: all tables, API service, and endpoints working
  - `6529483` initial project commit
  - `762a8a5` Commit
- **Git Working Tree State:**
  - **Staged Changes in Index (Pre-existing):** Modifications across backend scripts (`lib/screens/auth/app.py`, `db_fallback.py`, `notification_scheduler.py`, `seizure_prediction_api.py`), doctor/patient UI screens, SQLite database binary (`neuroguard_ai_fallback.db`), and `requirements.txt`.
  - **Unstaged Working Tree Changes:** 30+ Dart UI files, service handlers (`alerts_service.dart`, `bluetooth_service.dart`, `medical_report_generator_service.dart`, `prediction_service.dart`), `pubspec.yaml`, `pubspec.lock`.
  - **Untracked Additions:** Project governance and safety documents (`AGENTS.md`, `ML_RESEARCH_RULES.md`, `MEDICAL_SAFETY_RULES.md`, `SECURITY_RULES.md`, `CHANGE_CONTROL_RULES.md`), localization files (`l10n.yaml`, `lib/l10n/`), ML pipeline assets (`ml_models/production_pipeline.py`, model joblib artifacts), and temporary report JSON files.

---

## 2. MAJOR ARCHITECTURAL MODULES

### A. Frontend (Flutter Mobile & Web)
- **Location:** Project root (`lib/`, `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`)
- **Key Modules:**
  - `lib/screens/patient/`: Patient dashboard, realtime sensor dashboard, medication reminders, emergency call screens, chatbot interface.
  - `lib/screens/doctor/`: Doctor dashboard, patient directory, clinical records, EEG upload interface, medical reports, doctor chatbot.
  - `lib/services/`: REST API clients (`api_service.dart`), Bluetooth sensor integration (`bluetooth_service.dart`), alerts handling (`alerts_service.dart`), report generation.
  - `lib/theme/` & `lib/widgets/`: Theme configurations and reusable telemetry/prediction cards.

### B. Backend (Python Flask REST API)
- **Location:** `run_server.py` and `lib/screens/auth/app.py`
- **Port:** `http://127.0.0.1:5000`
- **Key Capabilities:**
  - Authentication (bcrypt password hashing, signup, login, password updates).
  - Patient & clinical record management.
  - Medication scheduling & automated background notifications (`notification_scheduler.py`).
  - Seizure prediction and telemetry processing endpoint (`seizure_prediction_api.py`).

### C. Database Layer
- **Dual-Mode Persistence:**
  - Primary target: MySQL (`127.0.0.1:3306`, user: `root`, DB: `neuroguard_ai`).
  - Auto-fallback: SQLite (`neuroguard_ai_fallback.db` via `db_fallback.py`) when MySQL is unavailable.

### D. Machine Learning & Inference Pipeline
- **Location:** `ml_models/` and `lib/screens/auth/seizure_prediction_api.py`
- **Artifacts:** Calibrated Classifier (SVC), StandardScaler (`seizure_scaler.joblib`), Feature Selector (`seizure_feature_selector.joblib`), metadata configuration (`seizure_meta.json`).

---

## 3. STARTUP & EXECUTION COMMANDS

| Component | Command | Notes |
| :--- | :--- | :--- |
| **Backend Server** | `python run_server.py` | Starts Flask server on port 5000 with auto-detected DB backend |
| **Backend API Tests** | `python run_api_tests.py` | Non-destructive integration test of 11 core endpoints |
| **Flutter App (Chrome)** | `flutter run -d chrome` | Launches web interface |
| **Flutter App (Desktop/Mobile)**| `flutter run` | Target connected device or emulator |
| **Static Code Analysis** | `dart analyze` | Evaluates Dart lints and static type checks |

---

## 4. CURRENT RUNNABILITY & TEST FINDINGS

1. **Backend API Suite (`run_api_tests.py`):**
   - **Status:** **PASSED (11/11 endpoints verified)**
   - **Database:** Successfully detected SQLite fallback mode.
   - **Model Initialization:** Seizure prediction pipeline initialized successfully.
   - **Warning Noted:** Scikit-learn unpickling warning (`InconsistentVersionWarning: Trying to unpickle estimator SVC from version 1.8.0 when using version 1.9.0`).

2. **Frontend Analysis (`dart analyze`):**
   - **Status:** **Exit Code 1 (7,324 analyzer warnings/issues reported)**
   - **Primary Issue:** Widespread `override_on_non_overriding_member` warnings across stateful widget lifecycles in patient/doctor screens resulting from Flutter SDK API signature updates.
   - **Impact:** Code requires systematic, non-destructive lint cleanups in future dedicated missions.

---

## 5. DEPENDENCY INVENTORY

- **Dart / Flutter Dependencies (`pubspec.yaml`):**
  `flutter` (SDK ^3.12.2), `cupertino_icons` (^1.0.8), `file_picker` (^11.0.2), `url_launcher` (^6.3.1), `http` (^1.2.0), `flutter_blue_plus` (^1.35.0), `permission_handler` (^11.4.0), `shared_preferences` (^2.2.0), `intl` (^0.20.0).
- **Python Backend Dependencies (`requirements.txt`):**
  `flask` (>=2.0.0), `flask-cors` (>=3.0.0), `bcrypt` (>=4.0.0), `mysql-connector-python` (>=8.0.0), `numpy` (>=1.21.0), `pandas` (>=1.3.0), `scikit-learn` (>=1.0.0), `joblib` (>=1.1.0), `requests` (>=2.25.0), `scipy` (>=1.7.0), `matplotlib` (>=3.4.0), `reportlab` (>=3.6.0), `xgboost` (>=1.5.0), `lightgbm` (>=3.3.0), `catboost` (>=1.0.0), `imbalanced-learn` (>=0.9.0).

---

## 6. BASELINE RISKS & SECURITY ASSESSMENT

1. **Tracked Database Binary:** The SQLite database `neuroguard_ai_fallback.db` is currently tracked in version control, creating potential data leakage risks if actual patient or test credentials accumulate.
2. **Hardcoded Configuration Defaults:** Database host and credentials in `app.py` are hardcoded defaults rather than loaded through environment variables (`.env`).
3. **Flutter Analyzer Errors:** High count of Dart analyzer warnings requires safe, targeted correction in subsequent missions.
4. **Model Unpickle Inconsistency:** Version drift between model training environment (scikit-learn 1.8.0) and host runtime (1.9.0).

---

## 7. SAFE RECOVERY & ROLLBACK PROCEDURE

- **Snapshot Reference:** Current HEAD is commit `8b82fc8`.
- **Working Tree Preservation:** All pre-existing modified and untracked files are kept intact.
- **Rollback Command (if ever required for recovery):**
  - To view exact working tree state: `git status`
  - To create safety backup branch of working state: `git checkout -b checkpoint/baseline-pre-audit`
