# NeuroGuard AI — Node.js + MongoDB Backend

Node.js/Express is the **primary backend** for the Flutter application and MongoDB is the persistent database. The optional Python ML service is only an inference adapter for the production EEG model; it is not the application/database backend.

## Run

1. Install Node.js 20+ and MongoDB 7+ (or use MongoDB Atlas).
2. Copy `.env.example` to `.env` and set `MONGODB_URI` and `JWT_SECRET`.
3. From this folder:

```bash
npm install
npm start
```

The API listens on `http://127.0.0.1:5000`.

## Flutter

- Android emulator: `http://10.0.2.2:5000`
- Web/Windows/macOS/Linux/iOS simulator: `http://127.0.0.1:5000`
- Physical phone: use your PC LAN address with `--dart-define=NEUROGUARD_API_URL=http://YOUR_PC_IP:5000`

## MongoDB

The schemas are in `models/`. Authentication, patients, medications, reminders, settings, chat history, telemetry, predictions, alerts and seizure events are persisted through Mongoose.

## ML

Set `ML_SERVICE_URL` only when a Python inference server is available. The Node API remains the single client-facing API.
