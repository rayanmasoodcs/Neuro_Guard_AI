@echo off
rem Starts the NeuroGuard AI ML service, backend and web app, then opens the browser.
rem First-time setup is described in README.md ("Run it").
title NeuroGuard AI launcher
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo Python venv not found. Run first-time setup from README.md.
  pause & exit /b 1
)

start "NeuroGuard ML service (port 5005)" cmd /k ".venv\Scripts\python.exe ml_models\ml_app.py"
start "NeuroGuard backend (port 5000)" cmd /k "cd backend && node server.js"
start "NeuroGuard web app (port 8080)" cmd /k "flutter run -d web-server --web-port 8080 --web-hostname 127.0.0.1"

echo Waiting for the web app to compile (1-2 minutes)...
:wait
timeout /t 5 /nobreak >nul
powershell -NoProfile -Command "try { Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8080 -TimeoutSec 3 | Out-Null; exit 0 } catch { exit 1 }"
if errorlevel 1 goto wait

start "" http://127.0.0.1:8080
echo NeuroGuard AI is running at http://127.0.0.1:8080 - close the three windows to stop it.
pause
