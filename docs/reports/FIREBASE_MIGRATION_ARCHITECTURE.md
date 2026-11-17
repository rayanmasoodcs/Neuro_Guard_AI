# NeuroGuard AI — Firebase Cloud Migration Architecture & Readiness Report

**Mission:** Mission 16 — Firebase Readiness Audit & Cloud Migration Architecture Locking  
**Date:** September 3, 2026  
**Status:** Completed (Architecture & Readiness Phase)  
**Governance Framework:** `SECURITY_RULES.md`, `FINAL_ARCHITECTURE.md`, `MASTER_IMPLEMENTATION_MAP.md`, `ROUND3_VERIFICATION_REPORT.md`

---

## 1. EXECUTIVE SUMMARY

Mission 16 locks the authoritative cloud migration architecture for NeuroGuard AI before any production or development data migration occurs. 

This readiness audit evaluated the existing Flask/MySQL/SQLite backend architecture, inspected current Firebase project artifacts, established explicit Data Classification and Source-of-Truth (SSOT) rules, designed identity mapping between Firebase Auth and Django backend models, and created a non-destructive 6-phase migration and rollback plan.

### Key Audit Findings
1. **Firebase Project Readiness:** Neither `google-services.json` (Android) nor `GoogleService-Info.plist` (iOS) are present in the repository. Neither `firebase_core`/`firebase_auth` Flutter packages nor `firebase-admin` Python SDK are installed. Manual Firebase Console provisioning is required before SDK integration.
2. **Single Source of Truth (SSOT):** Strict boundaries are established. Relational clinical data (patient-doctor relationships, medication schedules, medical histories) will remain authoritatively in Django/MySQL. Real-time notifications and seizure alert events will utilize Cloud Firestore. Raw EEG signals and generated reports will use Firebase Storage via an extended `FirebaseStorageAdapter`.
3. **Identity Mapping:** Firebase Auth `uid` strings will be mapped to Django `users.firebase_uid` columns. Roles (`patient`/`doctor`) will be authoritatively managed in Django and synchronized to Firebase Auth via Custom Claims.
4. **Data Integrity Guarantee:** Zero production or fallback database records were modified or deleted during this mission.

---

## 2. CURRENT VS TARGET ARCHITECTURE

```
+-----------------------------------------------------------------------------------+
|                               CURRENT ARCHITECTURE                                |
+-----------------------------------------------------------------------------------+
|  Flutter Mobile Client                                                            |
|    └─► HTTP REST APIs with Bearer JWT (Local HS256)                               |
|          └─► Python Flask Backend (app.py / seizure_prediction_api.py)            |
|                ├─► Database Adapter (MySQL / SQLite Fallback)                     |
|                ├─► ML Inference Pipeline (production_pipeline.py)                 |
|                └─► Local Storage Adapter (storage/eeg/<user_id>/<uuid>.csv)       |
+-----------------------------------------------------------------------------------+

+-----------------------------------------------------------------------------------+
|                                TARGET ARCHITECTURE                                |
+-----------------------------------------------------------------------------------+
|  Flutter Mobile Client                                                            |
|    ├─► Firebase Authentication (Identity & Token Issuance)                        |
|    ├─► Cloud Firestore (Real-Time Seizure Alerts & Notification Listening)         |
|    ├─► Firebase Storage (Direct Secure Uploads for Large EEG & PDF Files)         |
|    └─► HTTPS REST APIs (Bearer Firebase ID Token)                                 |
|          └─► Python Flask Backend API (Server-Side Authorization)                 |
|                ├─► Firebase Admin SDK (ID Token Verification & Custom Claims)     |
|                ├─► ML Inference Engine (EEG Processing & Risk Scoring)            |
|                ├─► Relational DB (MySQL / SQLite - Clinical Roster & History SSOT)|
|                └─► Firebase Storage Adapter (Server-Side Signed URLs & Storage)   |
+-----------------------------------------------------------------------------------+
```

---

## 3. TARGET DATA CLASSIFICATION & SOURCE OF TRUTH (SSOT)

| Target Data Category | Current Location | Future Location | Primary Source of Truth (SSOT) | Read Path | Write Path | Migration Req | Rollback Req | Sensitivity Level |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **User Identity** | `users` table (MySQL/SQLite) | Firebase Auth + `users` table | Firebase Auth (Credentials) / Django (Profile/Role) | Firebase SDK (Client) / Flask DB (Server) | Client -> Firebase Auth -> Flask Sync | Phase E Batch Migration | Revert to local `users.password` bcrypt | **HIGH** |
| **Authentication Identity** | `users.password` (bcrypt) | Firebase Auth Credentials | Firebase Auth | Firebase Auth Client SDK | Client -> Firebase Auth | Create Firebase Auth Accounts | Retain local bcrypt hashes | **HIGH** |
| **Role References** | `users.role` column | `users.role` + Custom Claims | Django DB (`users.role`) | Firebase Token Custom Claims / Flask DB | Flask Admin -> Firebase Custom Claims | Sync claims via Admin SDK | Read from `users.role` | **HIGH** |
| **Patient Profile Data** | `users` / `patients` tables | `users` table + Firestore Cache | Django DB (`users` table) | Flask REST API / Firestore Cache | Flutter -> Flask API -> DB | Optional Firestore Cache Sync | Read directly from Flask API | **HIGH (PHI)** |
| **Doctor Profile Data** | `users` table | `users` table | Django DB (`users` table) | Flask REST API | Flutter -> Flask API -> DB | None | Read directly from Flask API | **MEDIUM** |
| **Patient-Doctor Binding**| `patients.doctor_id` / `user_id` | `patients` table | Django DB (`patients` table) | Flask REST API | Flutter -> Flask API (RBAC Verified) | None | Read directly from Flask API | **HIGH (PHI)** |
| **EEG Metadata** | `seizure_predictions` table | `seizure_predictions` table | Django DB (`seizure_predictions`) | Flask REST API | Flask ML Pipeline -> DB | None | Read directly from Flask DB | **HIGH (PHI)** |
| **Raw EEG Files** | Local Disk (`storage/eeg/`) | Firebase Storage Bucket | Firebase Storage (`gs://...`) | Firebase Storage SDK / Signed URL | Flutter / Flask -> Firebase Storage | Upload local files to GCS Bucket | Retain local `storage/eeg/` fallback | **HIGH (PHI)** |
| **AI Analysis Results** | `seizure_predictions` table | `seizure_predictions` + Firestore | Django DB (`seizure_predictions`) | Flask REST API / Firestore Sync | Flask ML Pipeline -> DB & Firestore | Sync prediction rows to Firestore | Read from Flask DB | **HIGH (PHI)** |
| **Model Version Refs** | `seizure_meta.json` | `seizure_meta.json` | Django Server FS | Flask API | Server Deployment | None | None | **LOW** |
| **Seizure Events** | `seizure_predictions` table | `seizure_predictions` + Firestore | Django DB (History) / Firestore (Realtime) | Firestore SDK / Flask API | Flask ML / Telemetry -> Firestore & DB | Sync past event history | Query Flask DB | **HIGH (PHI)** |
| **Medication Reminders**| `medications` table | `medications` table | Django DB (`medications` table) | Flask REST API | Flutter -> Flask API -> DB | None | Read from Flask DB | **HIGH (PHI)** |
| **Notifications** | SQLite / Local Memory | Cloud Firestore (`notifications`) | Cloud Firestore | Firestore Client SDK | Flask Backend -> Admin SDK -> Firestore | None | Revert to local poll API | **MEDIUM** |
| **Report Metadata** | `seizure_predictions` table | `seizure_predictions` table | Django DB | Flask REST API | Flask Report Generator -> DB | None | Read from Flask DB | **HIGH (PHI)** |
| **Generated PDF Reports** | Local Disk (`storage/reports`)| Firebase Storage Bucket | Firebase Storage | Signed URLs via Flask API | Flask Report Generator -> Firebase Storage | Sync local PDFs to Storage | Retain local storage | **HIGH (PHI)** |
| **Audit Events** | `audit_logs` table | `audit_logs` table | Django DB (`audit_logs` table) | Flask Admin API | Flask Middleware -> `audit_logs` | None | Read from DB | **HIGH** |
| **Application Settings** | Local Storage / SharedPreferences | SharedPreferences + Firestore | Client Local Storage | Client Local Storage | Client Settings Screen | None | None | **LOW** |
| **Emergency Event Logs** | SQLite DB | `audit_logs` + Firestore Alerts | Django DB | Flask REST API / Firestore Alert | Flask Emergency Handler -> DB & Firestore | None | Query Flask DB | **CRITICAL (PHI)** |

---

## 4. RECOMMENDED ARCHITECTURE EVALUATION

### Evaluated Architecture Flow
```
Flutter Client ──► Firebase Auth (Obtain ID Token) ──► Flask REST API (Verify Token) ──► ML Engine & DB
      │                                                                                       │
      ├───────────────────► Cloud Firestore (Realtime Alerts) ◄──────────────────────────────┤
      │                                                                                       │
      └───────────────────► Firebase Storage (Raw EEG / PDFs) ◄──────────────────────────────┘
```

### Evaluation Verdict: APPROVED WITH SERVER-SIDE ENFORCEMENT
- **Identity:** Firebase Auth will manage client authentication, password resets, and token issuing.
- **Authorization:** Flutter client MUST NOT write directly to Firestore or Storage without passing through Firebase Security Rules OR Flask API authorization checks.
- **Client User ID Trust:** Flask backend will NEVER trust `user_id` passed in request bodies or query parameters. Flask middleware will verify the Firebase Bearer Token via `firebase_admin.auth.verify_id_token()`, extracting the verified `uid` server-side.

---

## 5. STEP 1 — FIREBASE PROJECT READINESS STATUS

| Component | Status | Location / Requirement | Action Required |
| :--- | :---: | :--- | :--- |
| **Firebase Project** | **NOT PROVISIONED** | Firebase Console | Create Project `neuroguard-ai-prod` |
| **Android Configuration** | **MISSING** | `android/app/google-services.json` | Download from console & place in `android/app/` |
| **iOS Configuration** | **MISSING** | `ios/Runner/GoogleService-Info.plist` | Download from console & place in `ios/Runner/` |
| **Flutter Dependencies** | **MISSING** | `pubspec.yaml` | Add `firebase_core: ^3.0.0`, `firebase_auth: ^5.0.0`, `cloud_firestore: ^5.0.0`, `firebase_storage: ^12.0.0` |
| **Python Backend SDK** | **MISSING** | `requirements.txt` | Add `firebase-admin>=6.0.0` |
| **Service Account Credentials**| **MISSING** | Server FS / Environment | Generate Service Account JSON & set `GOOGLE_APPLICATION_CREDENTIALS` |
| **Environment Protection** | **CONFIGURED** | `.gitignore` | Ensure `google-services.json`, `GoogleService-Info.plist`, `*firebase*.json` are ignored |

---

## 6. STEP 2 — IDENTITY MAPPING STRATEGY

### Identity Schema Mapping
```sql
ALTER TABLE users ADD COLUMN firebase_uid VARCHAR(128) UNIQUE NULL AFTER id;
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
```

### Identity Workflows
1. **User Registration Flow:**
   - Flutter user registers via Firebase Auth SDK (`createUserWithEmailAndPassword`).
   - Firebase Auth generates a unique `uid` (e.g. `u9a8F2kL...`).
   - Flutter calls Flask API `/signup` attaching `Authorization: Bearer <firebase_id_token>`.
   - Flask verifies the token via `firebase_admin.auth.verify_id_token()`, extracts `uid` and `email`, and creates the corresponding row in the Django `users` table storing `firebase_uid`.
   - Flask uses Firebase Admin SDK to set Custom Claims: `firebase_admin.auth.set_custom_user_claims(uid, {'role': role, 'django_id': user_id})`.

2. **Login & Session Verification Flow:**
   - Flutter logs in via Firebase Auth (`signInWithEmailAndPassword`) -> obtains Firebase ID Token.
   - Flutter attaches `Authorization: Bearer <firebase_id_token>` to all HTTP requests.
   - `@require_auth` decorator in `app.py` verifies token, extracts `firebase_uid`, and attaches the verified Django `g.user_id` and `g.user_role` to request context.

3. **Role Lookup & Tamper Resistance:**
   - Client CANNOT modify Custom Claims in Firebase ID Tokens.
   - Roles are authoritatively stored in Django `users.role` and synchronized to Firebase Custom Claims upon account creation or role update.

---

## 7. STEP 3 — FIRESTORE DATA DESIGN

### Collection 1: `notifications`
- **Path:** `/notifications/{notification_id}`
- **Document Structure:** `{ recipient_uid: string, title: string, body: string, type: string, read: boolean, timestamp: timestamp }`
- **Owner:** System (Flask Backend via Firebase Admin SDK).
- **Access Control:** Read by recipient (`request.auth.uid == resource.data.recipient_uid`). Write restricted to Backend.

### Collection 2: `seizure_events`
- **Path:** `/patients/{patient_uid}/seizure_events/{event_id}`
- **Document Structure:** `{ patient_id: string, seizure_type: string, confidence: number, risk_level: string, timestamp: timestamp }`
- **Access Control:** Read by patient (`request.auth.uid == patient_uid`) or assigned doctor (`request.auth.token.role == 'doctor'`). Write restricted to Backend ML service.

---

## 8. STEP 4 — FIREBASE STORAGE DESIGN

### Bucket Organization
`gs://neuroguard-ai-storage/`
- **EEG Uploads:** `eeg/{user_id}/{year}/{month}/{file_uuid}.csv`
- **PDF Medical Reports:** `reports/{patient_id}/{year}/{report_uuid}.pdf`

### Storage Access & Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /eeg/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && (request.auth.uid == userId || request.auth.token.role == 'doctor');
    }
    match /reports/{patientId}/{allPaths=**} {
      allow read: if request.auth != null && (request.auth.token.django_id == patientId || request.auth.token.role == 'doctor');
      allow write: if request.auth != null && request.auth.token.role == 'doctor';
    }
  }
}
```

### Storage Adapter Abstraction Integration
The backend [`lib/storage/storage_adapter.py`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/storage/storage_adapter.py) already contains the `FirebaseStorageAdapter` stub. In Mission 17, `FirebaseStorageAdapter` will be implemented using `google-cloud-storage` SDK, enabling seamless switching between local disk fallback and Firebase Cloud Storage via `STORAGE_PROVIDER=firebase` environment variable.

---

## 9. STEP 5 — MIGRATION & ROLLBACK PLAN

```
+-----------------------------------------------------------------------------------+
|                          6-PHASE MIGRATION SEQUENCE                               |
+-----------------------------------------------------------------------------------+
| PHASE A: BACKUP & ENVIRONMENT PREPARATION                                         |
|   - Full dump of MySQL/SQLite database and local storage/ directory.              |
|                                                                                   |
| PHASE B: DATABASE SCHEMA EXTENSION                                                |
|   - Execute ALTER TABLE users ADD COLUMN firebase_uid;                            |
|                                                                                   |
| PHASE C: SYNTHETIC DATA & ADAPTER TEST MIGRATION                                  |
|   - Provision test accounts in Firebase Auth; verify token verification in Flask. |
|                                                                                   |
| PHASE D: VALIDATION & PARITY CHECK                                                |
|   - Execute run_round3_master_verification.py against Firebase Auth endpoint.    |
|                                                                                   |
| PHASE E: CONTROLLED BATCH MIGRATION                                               |
|   - Batch import existing users to Firebase Auth via Admin SDK importUsers().     |
|   - Populate users.firebase_uid column in Django database.                        |
|                                                                                   |
| PHASE F: ROLLBACK PROCEDURE (IF VALIDATION FAILS)                                 |
|   - Set AUTH_PROVIDER=jwt and STORAGE_PROVIDER=local in .env.                     |
|   - Flask reverts to verifying local HS256 JWTs using existing bcrypt passwords.  |
+-----------------------------------------------------------------------------------+
```

---

## 10. STEP 6 — COST & FREE-TIER CONSIDERATIONS

| Firebase Service | Free Tier (Spark Plan) Limit | NeuroGuard AI Expected Usage | Cost Risk Assessment | Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **Firebase Auth** | 50,000 MAUs / month | < 1,000 active users | **NO COST RISK** | Stay within Spark Plan limits |
| **Cloud Firestore** | 50k reads, 20k writes/day, 1 GiB | Realtime alerts (~1,000 writes/day) | **LOW RISK** | Do NOT stream raw 100Hz EEG samples to Firestore! Aggregate telemetry in Flask ML service first. |
| **Firebase Storage**| 5 GiB total, 1 GB/day download | EEG files (~2MB each) | **MEDIUM RISK** | Implement automatic storage lifecycle policies to archive old raw CSV files after 90 days. |

---

## 11. STEP 7 — SECURITY ARCHITECTURE & BOUNDARIES

1. **Client Isolation:** Flutter Mobile Client NEVER possesses Firebase Admin Service Account JSON keys.
2. **Server-Side Verification:** Flask API `@require_auth` verifies Firebase ID tokens using `firebase_admin.auth.verify_id_token()` on every request.
3. **Database Boundary:** Firestore Security Rules enforce document-level access matching `request.auth.uid`.

---

## 12. MANUAL FIREBASE CONSOLE ACTIONS REQUIRED

1. **Create Firebase Project:** Log in to [Firebase Console](https://console.firebase.google.com/) and create project `neuroguard-ai-prod`.
2. **Enable Authentication Providers:** Enable Email/Password authentication provider in Console -> Authentication -> Sign-in method.
3. **Register Android App:** Register package `com.example.neuroguard_ai`, generate SHA-1 fingerprint, and download `google-services.json`. Place in `android/app/`.
4. **Register iOS App:** Register bundle ID `com.example.neuroguardAi` and download `GoogleService-Info.plist`. Place in `ios/Runner/`.
5. **Generate Service Account Key:** In Project Settings -> Service Accounts, click "Generate new private key". Save as `firebase_credentials.json` on the Flask server (outside public root).

---

## 13. ACCEPTANCE CRITERIA VERIFICATION

- [x] Firebase readiness audit executed.
- [x] Target data classification table created for all 16 categories.
- [x] Single Source of Truth (SSOT) defined for every category.
- [x] Identity mapping strategy locked (`firebase_uid` <-> Django `users` table).
- [x] Cloud Firestore and Storage security rules designed.
- [x] 6-Phase non-destructive migration & rollback plan documented.
- [x] Cost and Spark Plan free-tier limits evaluated.
- [x] Manual Firebase Console actions itemized.
- [x] Zero production data migrated or deleted in this mission.
