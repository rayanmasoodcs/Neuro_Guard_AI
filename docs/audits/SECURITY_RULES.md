# NeuroGuard AI — Security & Data Protection Rules

Data security, patient confidentiality, and healthcare record protection are vital requirements across all components of **NeuroGuard AI**.

---

## CORE SECURITY PRINCIPLE

> **"Never expose sensitive patient data, EEG files, passwords, API keys, tokens, Firebase credentials, or secrets in logs, client-side code, screenshots, documentation, or error messages."**

---

## 1. AUTHENTICATION & CREDENTIAL HANDLING
- **Password Protection:** Passwords must always be hashed with strong, salted cryptographic algorithms (e.g., bcrypt with adequate work factor). Plaintext passwords must never be stored, logged, or returned in API responses.
- **Session & Token Management:** Use cryptographically secure tokens or session cookies with appropriate expiry, rotation, and revocation mechanisms.
- **Credential Storage:** In Flutter mobile/web clients, sensitive authentication tokens must be stored in secure platform storage (e.g., FlutterSecureStorage / Keychain / EncryptedSharedPreferences) rather than standard unencrypted SharedPreferences.

---

## 2. AUTHORIZATION & ROLE-BASED ACCESS CONTROL (RBAC)
- **Role Isolation:** Enforce strict separation between `patient`, `doctor`, and `admin` roles across all backend API routes and client screens.
- **Resource Ownership Verification:** Every request targeting patient records, EEG recordings, medical histories, or medication schedules must verify that the requesting authenticated user has legitimate authorization to access that specific patient's data.
- **Doctor-Patient Relationship Validation:** Doctors may only access records of patients explicitly linked to their clinical care registry.

---

## 3. PATIENT DATA & PHI PROTECTION
- **Protected Health Information (PHI):** Patient names, contact details, medical history, age, gender, and clinical notes must be safeguarded.
- **Anonymization & Pseudonymization:** Datasets used for ML model training, benchmarking, or research exports must be stripped of direct patient identifiers and assigned synthetic research IDs.
- **Data Minimization:** Transmit only the minimum patient data required for each specific screen or operation.

---

## 4. EEG RECORDING & BIOSIGNAL FILE PROTECTION
- **Secure File Storage:** Raw and processed EEG files (.edf, .csv, .bin, .npy) must be stored in protected, access-controlled directory trees or encrypted cloud buckets with restricted read/write permissions.
- **Path Traversal Prevention:** Any endpoint handling EEG file uploads or downloads must strictly validate and sanitize filenames to prevent directory traversal (`../`) attacks.
- **Integrity Verification:** Uploaded biosignals should be validated for size limits, valid EEG file headers, and channel format integrity prior to ingestion.

---

## 5. MEDICAL REPORT & EXPORT SECURITY
- **Generated PDF/CSV Reports:** PDF diagnostic summaries and exported CSV records containing medical history or seizure frequency must be protected behind authenticated, authorized endpoints.
- **Temporary File Purging:** Temporary export artifacts generated on the server or device must be cleaned up promptly after download/transmission.

---

## 6. SECRETS & ENVIRONMENT VARIABLE MANAGEMENT
- **No Hardcoded Secrets:** API keys, database credentials, encryption keys, and JWT secrets must never be hardcoded into source code or committed to version control.
- **Environment Configurations:** All sensitive configuration parameters must be loaded from secure `.env` files or system environment variables.
- **Git Hygiene:** Ensure `.env`, `.pem`, service account keys, and credential stores are included in `.gitignore`.

---

## 7. FIREBASE SECURITY RULES & CLOUD INFRASTRUCTURE
- **Least Privilege Access:** Cloud Firestore and Firebase Storage security rules must never use open wildcards (e.g., `allow read, write: if true;`).
- **Granular Security Rules:** Firebase security rules must validate authentication state (`request.auth != null`) and confirm user ownership or authorized doctor role on every document path.
- **Service Account Hardening:** Cloud service account JSON keys must never be bundled into client-side Flutter code or web assets.

---

## 8. API AUTHORIZATION & ENDPOINT HARDENING
- **Strict Method & Input Validation:** All API endpoints must enforce expected HTTP methods (POST, GET, PUT, DELETE) and validate payload schemas and types.
- **CORS Configuration:** Restrict Cross-Origin Resource Sharing (CORS) in production to approved frontend origins rather than permissive wildcards.
- **Rate Limiting & Abuse Prevention:** Apply rate-limiting to sensitive endpoints (login, password reset, EEG file upload, prediction inference).

---

## 9. LOGGING & ERROR MESSAGE RESTRICTIONS
- **Log Sanitization:** Application logs, debug outputs, server console logs, and stack traces must never output user passwords, authentication tokens, API keys, or raw patient records.
- **Generic Error Messages:** Client-facing error responses must provide safe, generic descriptions and avoid leaking internal system paths, database queries, or server stack traces.
