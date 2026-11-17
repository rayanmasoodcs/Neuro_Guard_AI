# NeuroGuard AI — Architecture Decision Records (ADR)

**Document Status:** 🔒 **LOCKED**  
**Date:** September 3, 2026  
**Companion Document:** [`FINAL_ARCHITECTURE.md`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/FINAL_ARCHITECTURE.md)

---

## ADR-01: Hybrid Backend Architecture (Python Backend + Firebase Cloud Services)

- **Decision:** Retain the Python backend service for heavy compute operations (Digital Signal Processing, ML model serving, ReportLab PDF compilation) while delegating user identity, real-time client state, object file storage, and push notifications to Firebase Cloud Services (Auth, Firestore, Storage, FCM).
- **Reason:** Signal processing filters (Butterworth bandpass, Welch PSD, Hjorth parameters) and ML model inference require high-performance scientific Python libraries (scipy, numpy, scikit-learn, mne) that cannot run inside client-side Flutter or lightweight Firestore cloud functions without severe latency and overhead.
- **Evidence from Audits:** `BACKEND_AUDIT.md` and `ML_AUDIT.md` confirm that `production_pipeline.py` relies heavily on scipy DSP filters and joblib model artifacts. `FEATURE_REALITY_MATRIX.md` confirmed that direct client-side ML heuristics in Dart are overly simplistic and inaccurate.
- **Risk:** Requires maintaining dual communication pathways (Flutter $\leftrightarrow$ Firebase for state, Flutter $\leftrightarrow$ Python Backend for compute).
- **Alternative Considered:** *100% Pure Firebase Architecture (Serverless).* Rejected because executing continuous 24-channel EEG signal processing on Firebase Cloud Functions is computationally cost-prohibitive, introduces cold-start latency, and exceeds Cloud Function memory limits.

---

## ADR-02: Stateless JWT Authentication & Role-Based Access Control (RBAC)

- **Decision:** Transition from unauthenticated client-supplied user IDs to stateless JSON Web Tokens (JWT) issued by Firebase Auth / Backend Auth Gateway. Attach `Authorization: Bearer <token>` to all HTTP requests and validate caller UID and role (`patient` vs `doctor`) via backend middleware.
- **Reason:** Prevent universal Insecure Direct Object References (IDOR / BOLA) and ensure patient health records (PHI) are strictly accessible only to the owning patient and assigned doctor.
- **Evidence from Audits:** `SECURITY_PRIVACY_AUDIT.md` identified that all 49 backend routes accept naked IDs (e.g., `/get_patient_details/<patient_id>`) without session verification, allowing any user to read or modify any other user's records.
- **Risk:** Minor refactoring required in Flutter HTTP services to attach bearer tokens to existing API calls.
- **Alternative Considered:** *Server-side State Sessions with Cookies.* Rejected because mobile and cross-platform Flutter clients operate much more reliably with stateless Bearer JWTs across distributed endpoints.

---

## ADR-03: Direct Binary Cloud Storage for EEG Files via Signed URLs

- **Decision:** Eliminate Base64-in-JSON EEG file ingestion. Require Flutter clients to upload raw `.edf` and `.csv` files directly to Firebase Storage using pre-signed, short-lived URLs (15-minute expiration), passing only the storage reference key to the backend for DSP and inference.
- **Reason:** Base64 encoding inflates payload size by ~33% and forces multi-megabyte clinical recordings to be loaded into Flask worker RAM synchronously, risking Out-Of-Memory (OOM) denial-of-service crashes.
- **Evidence from Audits:** `DATABASE_MIGRATION_AUDIT.md` and `SECURITY_PRIVACY_AUDIT.md` noted high memory overhead on multi-patient batch uploads and lack of streaming support.
- **Risk:** Requires cloud storage bucket configuration and network permission setup.
- **Alternative Considered:** *Multipart Form-Data directly to Flask.* Viable as a transitional step, but direct cloud storage offloads all bandwidth and upload contention from the core backend API.

---

## ADR-04: Strict Isolation of ML Research Benchmarking from Real-Time Inference

- **Decision:** Physically isolate the research experiment pipeline (`ml_models/research/`) from the production inference service (`ml_models/production_pipeline.py`). Research scripts will perform patient-independent cross-validation (`GroupKFold` / `LeaveOneGroupOut`) on clinical benchmarks (CHB-MIT, Siena Scalp EEG) across 5–7 candidate models, producing version-locked model artifacts (`.joblib` / `.pt`) registered into `seizure_meta.json`.
- **Reason:** Research pipelines require multi-epoch batch training, heavy metric calculation (FPR/h, latency, PR-AUC), and parameter searches that must never execute inside real-time API worker threads.
- **Evidence from Audits:** `ML_AUDIT.md` revealed that the active model was trained on Gaussian random noise (`demo_train.csv`) with 16 features, while the inference DSP pipeline calculates 40 features, resulting in silent truncation and ~32.5% random guess accuracy.
- **Risk:** Requires maintaining two distinct code modules.
- **Alternative Considered:** *Single Unified Script for Training and Inference.* Rejected because it leads to global scaler leakage, variable namespace pollution, and runtime memory bloat in production servers.

---

## ADR-05: Strict Data Decoupling between AI Predictions and Clinician Annotations

- **Decision:** Create independent database schemas and UI representations for automated `AIPredictionEntry` and manual `ClinicianAnnotationEntry`. Neither shall overwrite or replace the other.
- **Reason:** Medical safety compliance dictates that automated AI outputs must never be masqueraded as confirmed diagnoses, and clinician chart adjustments must be immutably attributed to verified medical practitioners.
- **Evidence from Audits:** `MEDICAL_SAFETY_RULES.md` and `FEATURE_REALITY_MATRIX.md` require clear visual labeling (`AI ASSISTED - NOT CLINICAL DIAGNOSIS`) and auditable doctor review history.
- **Risk:** Slightly higher database document count per seizure event.
- **Alternative Considered:** *Single Combined 'status' Field on Seizure Record.* Rejected because overwriting AI predictions with doctor notes destroys the training/audit ground truth needed to evaluate AI model accuracy over time.

---

## ADR-06: Rule-Bound AI Chatbot with Hard Emergency SOS Intercept

- **Decision:** Proxy all chatbot interactions through a backend LLM gateway with strict system prompt boundaries. If user inputs indicate severe distress, status epilepticus (>5 min seizure), or physical injury, the chatbot must immediately halt text generation and trigger the Emergency SOS modal.
- **Reason:** Protect patient safety by preventing hallucinations, drug prescription advice, or dosage modifications.
- **Evidence from Audits:** `FEATURE_REALITY_MATRIX.md` found that the current chatbot is a static Dart regex rule without safety guardrails or active emergency interception.
- **Risk:** Requires fine-tuning system prompts and latency optimization.
- **Alternative Considered:** *Direct Unrestricted Client-to-OpenAI API Calls.* Rejected because exposing API keys in Flutter and bypassing server guardrails violates HIPAA, GDPR, and medical safety rules.

---

## ADR-07: Real Multi-Channel Emergency SOS Dispatch

- **Decision:** Upgrade the emergency workflow from a local database log to a real multi-channel dispatch engine combining Twilio SMS (with GPS coordinates) to family contacts, high-priority FCM push to assigned doctors, and native hardware phone dialer intents.
- **Reason:** Eliminate the false sense of security where patients believe an emergency alert was sent when only a local database row was created.
- **Evidence from Audits:** `FEATURE_REALITY_MATRIX.md` identified the simulated emergency response (`"channels": ["sms", "email", "push"]`) as a critical misleading flow.
- **Risk:** Requires third-party SMS gateway credentials and location permissions.
- **Alternative Considered:** *Client-Side Direct SMS Dispatch.* Rejected because mobile background OS restrictions often block silent background SMS sending without explicit user interaction.
