# NeuroGuard AI — Backend Stabilization Report

**Mission:** Backend Stabilization (Round 3, Pre-Mission)  
**Date:** September 3, 2026  
**Scope:** Flask backend structural stabilization — no Firebase migration, no ML training, no Flutter UI changes  
**Status:** ✅ COMPLETE

---

## IMPORTANT: Framework Clarification

> The user's request refers to "Django backend." **The NeuroGuard AI backend is Flask, not Django.** There is no `manage.py`, no Django ORM, no Django serializers, and no Django apps. This was confirmed in `BACKEND_AUDIT.md` and re-verified during this mission's pre-modification inspection. All stabilization work was applied to the actual Flask backend.

---

## 1. BACKEND STRUCTURE BEFORE CHANGES

### Architecture
- **Framework:** Flask 2.x/3.x with `flask-cors`
- **Entry points:**
  - `run_server.py` (production launcher)
  - `lib/screens/auth/app.py` (1,810 lines — core Flask app)
  - `lib/screens/auth/seizure_prediction_api.py` (1,691 lines — Blueprint at `/api/seizure`)
  - `lib/screens/auth/db_fallback.py` (169 lines — dual-mode MySQL/SQLite adapter)
  - `lib/screens/auth/notification_scheduler.py` (347 lines — threaded background daemon)
  - `ml_models/production_pipeline.py` (DSP, feature extraction, inference wrapper)

### Pre-Change Problems Identified (14 total)

| # | Problem | Severity |
|---|---------|----------|
| 1 | Hardcoded database credentials (`host`, `user`, `password`) in source | 🟠 High |
| 2 | `debug=True` hardcoded in both `run_server.py` and `app.py` | 🟠 High |
| 3 | Wildcard CORS `CORS(app)` — no origin restriction | 🟠 High |
| 4 | No `MAX_CONTENT_LENGTH` — unlimited upload size (OOM risk) | 🟠 High |
| 5 | `str(e)` returned raw in error responses — internal path/SQL leakage | 🟠 High |
| 6 | Password hash slice + user email printed to console at line 1103 | 🟠 High |
| 7 | Deferred ML imports (`pandas`, `numpy`, `joblib`, `sklearn`) appear **after** blueprint registration | 🟡 Medium |
| 8 | No health/readiness endpoint | 🟡 Medium |
| 9 | `.gitignore` missing `.env`, `*.db`, `*.joblib`, `*.pkl`, `__pycache__`, report JSON | 🟠 High |
| 10 | `neuroguard_ai_fallback.db` tracked in Git (binary patient data in VCS) | 🟠 High |
| 11 | No `python-dotenv` in `requirements.txt` | 🟡 Medium |
| 12 | No standard API response contract — endpoints inconsistently structured | 🟡 Medium |
| 13 | `/train_model` uses naive `train_test_split` (ML_RESEARCH_RULES violation) | 🟡 Medium |
| 14 | `InconsistentVersionWarning` on sklearn joblib artifacts at startup | 🟡 Medium |

---

## 2. PROBLEMS LEFT UNCHANGED (OUT OF SCOPE)

| Problem | Reason |
|---------|--------|
| Universal IDOR / missing JWT auth | Scoped to Mission 1 (JWT Hardening) |
| `/train_model` naive random split | Scoped to Mission 4/5 (ML pipeline) |
| `InconsistentVersionWarning` on joblib artifacts | Scoped to Mission 5 (Model Re-Serialization) |
| Raw `str(e)` in individual route handlers | Scoped to Mission 2 (API Sanitization); existing API contracts preserved |
| Passive consent flags unenforced | Requires Firebase + RBAC from Missions 7+ |
| Missing audit log table | Schema addition — requires explicit approval |

---

## 3. CHANGES MADE

### `lib/screens/auth/app.py` — 7 changes

1. **Configuration externalization:** Replaced hardcoded `db_config` with `os.environ.get()` for `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` — local defaults preserved.
2. **CORS configuration:** Replaced `CORS(app)` with env-var-driven `CORS_ORIGINS` (defaults to `*`; set specific origins in production).
3. **Upload size limit:** Added `app.config['MAX_CONTENT_LENGTH'] = 52428800` (50 MB) from `MAX_CONTENT_LENGTH` env var.
4. **Global error handlers:** Added handlers for 400, 404, 413, 500 returning generic JSON messages; internal details logged server-side only.
5. **API response helpers:** Added `api_success()` and `api_error()` factory functions for consistent response contracts in new endpoints.
6. **Hash debug logging removed:** Removed lines printing `hash_prefix={stored_password[:10]}` and user email to console.
7. **Import ordering fix:** Moved `pandas`, `numpy`, `joblib`, `sklearn` imports from deferred position (line 1763) to module top.

### `run_server.py` — 2 changes
- Added `python-dotenv` `load_dotenv()` call.
- Replaced hardcoded `host`, `port`, `debug` with env-var values (`FLASK_HOST`, `FLASK_PORT`, `FLASK_DEBUG`).

### `requirements.txt` — 1 addition
- Added `python-dotenv>=1.0.0`.

### `.gitignore` — extended
- Added exclusions for: `.env`, `__pycache__/`, `*.py[cod]`, `*.db`, `*.sqlite`, `*.joblib`, `*.pkl`, `report.*.json`, Firebase credential files.

### `.env.example` — NEW FILE
- Safe template documenting all environment variables with local-dev defaults.
- No real credentials included. Committed to VCS.

### `GET /health` — NEW ENDPOINT
Returns:
```json
{"status": "ok", "database": {"connected": true, "backend": "sqlite"}, "scheduler": {"running": true}}
```
HTTP 200 when database reachable, HTTP 503 when degraded. Exposes zero secrets or patient data.

---

## 4. FILES CHANGED

| File | Action | Summary |
|------|--------|---------|
| `lib/screens/auth/app.py` | Modified | Env config, CORS, size limit, error handlers, helpers, /health, hash print removal, import fix |
| `run_server.py` | Modified | Env-var host/port/debug, dotenv loading |
| `requirements.txt` | Modified | Added `python-dotenv>=1.0.0` |
| `.gitignore` | Modified | Backend-specific exclusion rules added |
| `.env.example` | Created | Safe configuration template |
| `BACKEND_STABILIZATION_REPORT.md` | Created | This document |

---

## 5. API CONTRACTS CHANGED

**None.** All 49 existing endpoint paths, HTTP methods, request schemas, and response field structures are unchanged. The new `GET /health` endpoint has no existing Flutter consumer.

---

## 6. TESTS PERFORMED

### Baseline (before changes)
- **Command:** `python run_api_tests.py`
- All 11 API test operations passed (HTTP 200/201/409 as expected) ✅

### Post-Change Verification
- `GET /health` → HTTP 200, `{status, database.connected, scheduler.running}` ✅
- `MAX_CONTENT_LENGTH == 52428800` confirmed in `app.config` ✅
- `GET /nonexistent` → HTTP 404 `{"status":"error","message":"Resource not found."}` ✅
- `POST /login` → HTTP 200 `{"status":"success","user":{...}}` ✅ (regression)
- Hash debug print removed — verified by code inspection ✅

### Regression (after changes)
- **Command:** `python run_api_tests.py`
- All 11 original test operations passed — identical responses to baseline ✅

---

## 7. TESTS NOT PERFORMED

| Test | Reason |
|------|--------|
| HTTP 413 payload end-to-end | Cannot easily generate 50+ MB payload in local test client |
| CORS origin restriction | Requires browser cross-origin request; defaults to `*` locally |
| `FLASK_DEBUG=false` mode | Requires live server process |
| `python-dotenv` `.env` loading | Package not yet installed; graceful skip path confirmed |
| MySQL env-var connection | MySQL unavailable at `127.0.0.1:3306`; SQLite fallback used |
| Seizure prediction endpoints | No EEG files available; endpoints untouched by this mission |

---

## 8. REMAINING BACKEND RISKS

| Risk | Severity | Mission |
|------|----------|---------|
| Universal IDOR — 49 endpoints accept arbitrary user IDs without auth | 🔴 Critical | Mission 1 |
| No JWT / session token on login | 🔴 Critical | Mission 1 |
| `/update_password` accepts naked user ID without auth | 🔴 Critical | Mission 1 |
| Raw `str(e)` still in individual route `except` blocks | 🟠 High | Mission 2 |
| `InconsistentVersionWarning` on sklearn artifacts at startup | 🟡 Medium | Mission 5 |
| `/train_model` naive random split violates ML_RESEARCH_RULES | 🟡 Medium | Mission 4/5 |
| `neuroguard_ai_fallback.db` still in Git index | 🟠 High | Requires `git rm --cached` with explicit approval |
| Passive unenforced consent flags | 🟡 Medium | Mission 7 |
| No PHI audit log | 🟡 Medium | Mission 7 |
| Emergency SOS — simulated only, no real dispatch | 🔴 Critical | Mission 8 |

> **Note on `*.db` Git removal:** The new `.gitignore` will prevent future commits of the SQLite file, but the existing `neuroguard_ai_fallback.db` is already tracked in Git index and needs `git rm --cached neuroguard_ai_fallback.db` to untrack it. This will NOT delete the file from disk. Awaiting explicit user approval before executing.

---

## 9. RECOMMENDED NEXT MISSION

**Mission 1: Backend Security & JWT Authentication Hardening**

Per `MASTER_IMPLEMENTATION_MAP.md`:
1. Add `PyJWT>=2.8.0` to `requirements.txt`.
2. Implement `generate_token(user_id, role, secret)` issued on `/login` and `/signup`.
3. Implement `@require_auth` decorator verifying signature, expiration, ownership, and role.
4. Eliminate `/update_password` unauthenticated bypass.
5. Apply `@require_auth` to all 47 protected endpoints.
6. Update `run_api_tests.py` to assert HTTP 401 on unauthenticated requests.
