# NeuroGuard AI Architecture

## Client
Flutter (`lib/`) provides the patient, doctor, authentication, wearable, reporting, and settings interfaces.

## API
The current Flutter screens use the Python Flask API exposed through `run_server.py` / `lib/screens/auth/app.py`. The API provides authentication, patient/doctor workflows, EEG processing, predictions, reports, reminders, and storage integration.

## ML
`ml_models/production_inference.py` and `ml_models/production_pipeline.py` contain the production inference path. Research experiments live under `ml_models/research/`. Production model artifacts are kept separately from source code.

## Optional Node service
`backend/` contains an Express/Mongoose/MongoDB service. It is retained for the MongoDB-oriented backend architecture, but it is not the default API target of the current Flutter client.

## Runtime data
- `storage/`: generated EEG/report files.
- `neuroguard_ai_fallback.db`: local fallback database (not included in the clean distributable archive).
- `.env`: local secrets/configuration (not included).
