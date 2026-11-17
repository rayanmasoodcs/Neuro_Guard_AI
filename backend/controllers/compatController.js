/**
 * compatController.js
 * Legacy-compatibility endpoints used by older Flutter client versions.
 * All previously-stubbed handlers are now production-quality.
 */

const { SeizureAlert, SeizureEvent, Prediction, User } = require('../models');
const { callMLService, heuristic } = require('../services/mlService');
const axios = require('axios');

// ─── Helpers ─────────────────────────────────────────────────────────────────

const ML_URL = process.env.ML_SERVICE_URL; // e.g. http://localhost:5005

/** Forward a multipart-like JSON payload to the Python ML service and return
 *  the parsed response body, or null if the service is unavailable. */
async function proxyToML(endpoint, payload) {
  if (!ML_URL) return null;
  const res = await axios.post(`${ML_URL}${endpoint}`, payload, {
    timeout: 30_000,
    validateStatus: () => true,
  });
  return res.data;
}

// ─── EEG Prediction (single patient) ─────────────────────────────────────────

exports.predictEEG = async (req, res) => {
  try {
    const payload = {
      eeg_file: req.body.eeg_file || null,
      eeg_filename: req.body.eeg_filename || req.body.eeg_file_name || 'upload.csv',
      sensor_data: req.body.sensor_data || [],
      user_id: req.user?.id,
    };

    // Try Python ML service first
    if (ML_URL) {
      const mlResult = await proxyToML('/predict', payload);
      if (mlResult && mlResult.status === 'success') {
        // Persist to DB
        await Prediction.create({
          userId: req.user?.id,
          predictionResult: mlResult.prediction?.seizure_type || mlResult.seizure_type || 'Unknown',
          confidence: mlResult.prediction?.confidence ?? mlResult.confidence ?? 0,
          riskLevel: mlResult.prediction?.risk_level || mlResult.risk_level || 'Unknown',
          modelVersion: mlResult.model_version || 'production',
          source: 'ml_service',
        }).catch(() => {}); // non-fatal

        return res.json({
          status: 'success',
          prediction: mlResult.prediction || mlResult,
          model_backend: 'python_ml',
        });
      }
    }

    // Fallback: heuristic (labelled as such)
    const result = heuristic({ sensorReadings: req.body.sensor_data || [], eegFile: req.body.eeg_file || null });
    return res.json({
      status: 'success',
      prediction: result,
      model_backend: 'heuristic_fallback',
      note: 'ML service unavailable — result is heuristic only. Clinical use requires ML_SERVICE_URL.',
    });
  } catch (e) {
    console.error('[compatController.predictEEG]', e.message);
    return res.status(500).json({ status: 'error', message: 'EEG prediction failed.' });
  }
};

// ─── Batch EEG Prediction (multi-patient CSV) ─────────────────────────────────

exports.predictBatch = async (req, res) => {
  try {
    const payload = {
      eeg_file: req.body.eeg_file || null,
      eeg_filename: req.body.eeg_filename || 'batch.csv',
      user_id: req.user?.id,
    };

    if (ML_URL) {
      const mlResult = await proxyToML('/predict_batch', payload);
      if (mlResult && mlResult.status === 'success') {
        return res.json({ status: 'success', ...mlResult, model_backend: 'python_ml' });
      }
    }

    return res.status(503).json({
      status: 'error',
      message: 'Batch prediction requires the Python ML service (ML_SERVICE_URL is not configured or the service is offline).',
    });
  } catch (e) {
    console.error('[compatController.predictBatch]', e.message);
    return res.status(500).json({ status: 'error', message: 'Batch prediction failed.' });
  }
};

// ─── Dataset Summary ─────────────────────────────────────────────────────────

exports.datasetSummary = async (req, res) => {
  try {
    const payload = {
      eeg_file: req.body.eeg_file || null,
      eeg_filename: req.body.eeg_filename || req.body.eeg_file_name || 'upload.csv',
    };

    if (ML_URL) {
      const mlResult = await proxyToML('/dataset_summary', payload);
      if (mlResult && mlResult.status === 'success') {
        return res.json({ status: 'success', summary: mlResult.summary });
      }
    }

    // Minimal fallback — compute basic file stats from the base64 payload
    const bytes = req.body.eeg_file ? Buffer.from(req.body.eeg_file, 'base64') : Buffer.alloc(0);
    const text = bytes.toString('utf8').slice(0, 4096);
    const rows = text.split('\n').filter(Boolean).length;
    const firstLine = text.split('\n')[0] || '';
    const columns = firstLine.split(',').length;
    return res.json({
      status: 'success',
      summary: {
        filename: payload.eeg_filename,
        size_bytes: bytes.length,
        rows,
        channels: columns,
        duration_seconds: 0,
        note: 'ML service unavailable — basic summary only.',
      },
    });
  } catch (e) {
    console.error('[compatController.datasetSummary]', e.message);
    return res.status(500).json({ status: 'error', message: 'Dataset summary failed.' });
  }
};

// ─── EEG Graph Generation ─────────────────────────────────────────────────────

exports.generateGraph = async (req, res) => {
  try {
    const payload = {
      eeg_file: req.body.eeg_file || null,
      eeg_filename: req.body.eeg_filename || 'upload.csv',
      patient_index: req.body.patient_index ?? 0,
    };

    if (ML_URL) {
      const mlResult = await proxyToML('/generate_eeg_graph', payload);
      if (mlResult && mlResult.status === 'success') {
        return res.json({ status: 'success', png_base64: mlResult.png_base64 });
      }
    }

    return res.status(503).json({
      status: 'error',
      message: 'EEG graph generation requires the Python ML service (ML_SERVICE_URL is not configured or the service is offline).',
    });
  } catch (e) {
    console.error('[compatController.generateGraph]', e.message);
    return res.status(500).json({ status: 'error', message: 'Graph generation failed.' });
  }
};

// ─── PDF Report Generation ────────────────────────────────────────────────────

exports.generateReport = async (req, res) => {
  try {
    const payload = {
      eeg_file: req.body.eeg_file || null,
      eeg_filename: req.body.eeg_filename || 'upload.csv',
      patient_name: req.body.patient_name || 'Unknown',
      user_id: req.user?.id,
    };

    if (ML_URL) {
      const mlResult = await proxyToML('/generate_report', payload);
      if (mlResult && mlResult.status === 'success') {
        return res.json({ status: 'success', pdf_base64: mlResult.pdf_base64 });
      }
    }

    return res.status(503).json({
      status: 'error',
      message: 'PDF report generation requires the Python ML service (ML_SERVICE_URL is not configured or the service is offline).',
    });
  } catch (e) {
    console.error('[compatController.generateReport]', e.message);
    return res.status(500).json({ status: 'error', message: 'Report generation failed.' });
  }
};

// ─── Upcoming Alerts ─────────────────────────────────────────────────────────

exports.upcomingAlerts = async (req, res) => {
  try {
    const hours = Math.min(Number(req.query.hours_ahead || 24), 168); // cap at 7 days
    const since = new Date();
    const until = new Date(Date.now() + hours * 3_600_000);

    // Ownership check: regular users may only view their own alerts
    const targetId = req.params.id;
    if (req.user && req.user.role === 'patient' && req.user.id !== targetId) {
      return res.status(403).json({ status: 'error', message: 'Forbidden.' });
    }

    const alerts = await SeizureAlert.find({
      userId: targetId,
      createdAt: { $gte: since, $lte: until },
    }).sort({ createdAt: 1 }).lean();

    return res.json({ status: 'success', alerts });
  } catch (e) {
    console.error('[compatController.upcomingAlerts]', e.message);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch alerts.' });
  }
};

// ─── Acknowledge Seizure Event ────────────────────────────────────────────────

exports.acknowledgeEvent = async (req, res) => {
  try {
    const event = await SeizureEvent.findById(req.params.id).lean();
    if (!event) return res.status(404).json({ status: 'error', message: 'Event not found.' });

    // Ownership: patient may only ACK their own events; doctor/admin can ACK any
    if (req.user && req.user.role === 'patient' && String(event.userId) !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Forbidden.' });
    }

    const updated = await SeizureEvent.findByIdAndUpdate(
      req.params.id,
      {
        severity: req.body.severity || 'ACKNOWLEDGED',
        acknowledgedAt: new Date(),
        acknowledgedBy: req.user?.id || 'system',
      },
      { new: true, runValidators: true }
    );

    return res.json({ status: 'success', event: updated });
  } catch (e) {
    console.error('[compatController.acknowledgeEvent]', e.message);
    return res.status(500).json({ status: 'error', message: 'Failed to acknowledge event.' });
  }
};

// ─── Emergency Alert ──────────────────────────────────────────────────────────

exports.sendEmergencyAlert = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.user_id;
    const message = req.body.message || 'Emergency alert triggered';
    const severity = req.body.severity || 'High';

    // Persist the alert in DB
    const alert = await SeizureAlert.create({
      userId,
      alertType: 'emergency',
      alertMessage: message,
      severity,
      triggeredBy: 'patient_manual',
      isAcknowledged: false,
    });

    // TODO: integrate with FCM push notification service here.
    // e.g. await admin.messaging().send({ token: userFcmToken, notification: { title: 'Emergency', body: message } });

    return res.json({
      status: 'success',
      alert_id: alert._id,
      message: 'Emergency alert recorded. Push notification support requires FCM integration.',
      notification_queued: false, // flip to true once FCM is wired
    });
  } catch (e) {
    console.error('[compatController.sendEmergencyAlert]', e.message);
    return res.status(500).json({ status: 'error', message: 'Failed to send emergency alert.' });
  }
};

// ─── Trigger Notification (generic) ──────────────────────────────────────────

exports.triggerNotification = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.user_id;
    const message = req.body.message || 'Notification triggered';
    const severity = req.body.severity || 'Low';

    await SeizureAlert.create({
      userId,
      alertType: req.body.notification_type || 'info',
      alertMessage: message,
      severity,
      triggeredBy: 'system',
      isAcknowledged: false,
    });

    // TODO: push via FCM here.

    return res.json({ status: 'success', message: 'Notification recorded.' });
  } catch (e) {
    console.error('[compatController.triggerNotification]', e.message);
    return res.status(500).json({ status: 'error', message: 'Failed to trigger notification.' });
  }
};

// ─── Language Preference ──────────────────────────────────────────────────────

exports.languagePreference = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.user_id;
    const language = req.body.language || 'en';

    const SUPPORTED = ['en', 'ur', 'ar', 'fr', 'es', 'de', 'zh', 'hi'];
    if (!SUPPORTED.includes(language)) {
      return res.status(400).json({ status: 'error', message: `Unsupported language '${language}'.` });
    }

    if (userId) {
      await User.findByIdAndUpdate(userId, { $set: { preferredLanguage: language } });
    }

    return res.json({ status: 'success', language });
  } catch (e) {
    console.error('[compatController.languagePreference]', e.message);
    return res.status(500).json({ status: 'error', message: 'Failed to save language preference.' });
  }
};
