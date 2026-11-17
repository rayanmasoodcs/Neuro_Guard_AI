# NeuroGuard AI — Official Project Risk Register

**Version:** 1.0.0 — Final  
**Status:** 🔒 **LOCKED & ACTIVELY MONITORED**  
**Date:** September 3, 2026  
**Companion Documents:** [`MASTER_IMPLEMENTATION_MAP.md`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/MASTER_IMPLEMENTATION_MAP.md) and [`FINAL_ARCHITECTURE.md`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/FINAL_ARCHITECTURE.md)

---

## 1. TOP 10 CRITICAL & HIGH PROJECT RISKS

| ID | Risk Description | Severity | Affected Component | Dependency | Mitigation Strategy | Rollback & Recovery Procedure |
| :- | :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-01** | **Universal Broken Object Level Authorization (IDOR):** Unauthenticated callers manipulate user IDs to read or alter patient medical records. | 🔴 Critical | All 49 Backend REST Endpoints | Mission 1 | Implement stateless JWT verification and an `@require_auth` decorator that checks user ownership and role on every endpoint. | Revert commit; restore previous endpoint routing with IP restrictions. |
| **RSK-02** | **Insecure Password Reset Bypass:** `/update_password` accepts naked user IDs without token or current password validation. | 🔴 Critical | Authentication Gateway (`app.py:1074`) | Mission 1 | Enforce authenticated session checks and cryptographic verification of current password on password update. | Disable `/update_password` endpoint; enforce standard `/change_password`. |
| **RSK-03** | **Production ML Model Trained on Noise:** Active model evaluated on random Gaussian noise (`demo_train.csv`) produces ~32.5% random guess outputs on clinical EEGs. | 🔴 Critical | Inference Pipeline (`ml_models/`) | Missions 3, 4, 5 | Train 5–7 model benchmark suite on real clinical benchmarks (CHB-MIT / Siena) under patient-independent splitting protocols. | Revert to legacy rule-based fallback with explicit "Model in Training" disclaimer. |
| **RSK-04** | **Patient Overlap Data Leakage:** Model validation using random sample splits mixes patient epochs across train and test folds, inflating accuracy. | 🔴 Critical | Research Training Pipeline | Mission 4 | Strictly enforce `GroupKFold` (by Patient ID) and `LeaveOneGroupOut` cross-validation preventing subject overlap. | Discard contaminated experiment results; re-run with strict patient grouping. |
| **RSK-05** | **Feature Schema Truncation Mismatch:** Production inference extracts 40 spectral/Hjorth features but silently truncates to 16 features to fit legacy schema. | 🔴 Critical | Production Pipeline (`production_pipeline.py`) | Mission 5 | Standardize feature extraction schema to 40 dimensions across both research training and live production serving. | Restore backup of feature extraction functions. |
| **RSK-06** | **Simulated Emergency Dispatch:** App claims SMS/email/push was sent on SOS trigger, but only inserts a local database row. | 🔴 Critical | Emergency Alert Module (`emergency_alert_screen.dart`) | Mission 8 | Integrate real Twilio SMS gateway (with GPS coordinates), FCM push to doctors, and native device dialer intent. | Display clear UI warning: "Automated SMS unavailable - please call emergency services directly". |
| **RSK-07** | **In-Memory Base64 Denial of Service (OOM):** High-density continuous EEG files decoded synchronously into RAM cause Flask worker crashes. | 🟠 High | File Upload Handlers (`seizure_prediction_api.py`) | Mission 6 | Upgrade upload endpoints to multipart/form-data streaming and direct signed URL uploads to Firebase Storage. | Set `MAX_CONTENT_LENGTH = 50MB` to prevent worker thread starvation. |
| **RSK-08** | **Wildcard CORS Configuration:** `CORS(app)` permits arbitrary third-party web origins to trigger local API endpoints. | 🟠 High | Flask Server Perimeter (`app.py:11`) | Mission 2 | Restrict CORS to authorized mobile and web client origins. | Revert to localhost-only binding (`127.0.0.1`). |
| **RSK-09** | **Credential & Hash Logging:** Server console outputs bcrypt hash slices (`hash_prefix={...}`) and plaintext user emails. | 🟠 High | Server Logging (`app.py:1103`) | Mission 2 | Sanitize all console logs and implement structured logging with PII/secret masking. | Immediate patch removing verbose debug print statements. |
| **RSK-10** | **Database Migration Data Loss or Downtime:** Transition from MySQL/SQLite to Firebase Firestore breaks relational joins or corrupts records. | 🟠 High | Data Persistence Layer (`db_fallback.py`) | Mission 7 | Implement dual-write data migration with cryptographic parity verification and feature flag `USE_FIREBASE_DATASTORE=false`. | Instantaneous zero-downtime rollback by toggling feature flag back to local SQLite/MySQL. |

---

## 2. SECONDARY & OPERATIONAL RISKS

| ID | Risk Description | Severity | Affected Component | Dependency | Mitigation Strategy | Rollback & Recovery Procedure |
| :- | :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-11** | **Verbose Error Stack Disclosure:** Server error responses return raw `str(e)`, disclosing internal SQL and filesystem paths in HTTP 500 JSON. | 🟡 Medium | Global Error Handlers | Mission 2 | Implement centralized error handlers returning sanitized generic error messages while logging details server-side. | Revert custom error handler. |
| **RSK-12** | **Passive Unenforced Consent Flags:** Patient privacy settings stored in database are ignored during ML training or data queries. | 🟡 Medium | Privacy Settings Module | Mission 7 | Enforce `share_research == 1` check before including any patient EEG records in research training pipelines. | Exclude all unverified records from dataset splits. |
| **RSK-13** | **Plaintext Credential Storage in Flutter:** Tokens/passwords stored in plaintext `SharedPreferences` vulnerable on rooted devices. | 🟡 Medium | Flutter Client Storage Layer | Mission 9 | Migrate sensitive tokens to `FlutterSecureStorage` (iOS Keychain / Android Keystore). | Clear corrupted cache and re-prompt user login. |
| **RSK-14** | **Unversioned Database Schema Alterations:** Lack of schema migration framework leads to schema drift between MySQL and SQLite. | 🟡 Medium | Database DDL | Mission 7 | Standardize schema definitions and implement versioned SQL migration scripts. | Re-run baseline `init_db()` DDL script. |
| **RSK-15** | **Scikit-Learn Serialization Drift:** `InconsistentVersionWarning` emitted on unpickling models across different scikit-learn versions. | 🟡 Medium | ML Model Serialization | Mission 5 | Re-serialize model and scaler artifacts under the active runtime scikit-learn version. | Pin exact scikit-learn version in `requirements.txt`. |
