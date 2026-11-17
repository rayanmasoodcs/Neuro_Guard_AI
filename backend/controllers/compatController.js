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

// Shape a non-result (cannot assess / service offline) in the fields the Flutter client reads,
// so the client shows the reason instead of falling back to its own on-device guess.
function noResult(label, reason, extra = {}) {
  return {
    seizure_type: label,
    confidence: 0,
    risk_level: 'Unknown',
    eeg_patterns: [reason],
    analysis_summary: `${label}: ${reason}`,
    all_scores: {},
    ...extra,
  };
}

exports.predictEEG = async (req, res) => {
  try {
    const filename = req.body.eeg_filename || req.body.eeg_file_name || 'upload.csv';
    if (!req.body.eeg_file) {
      return res.json({ status: 'success', model_backend: 'none',
        prediction: noResult('Cannot assess', 'No EEG file was provided.') });
    }

    // EEG files are only analysed by the trained model; there is no heuristic fallback,
    // because heart rate or motion cannot stand in for EEG (spec §1, NFR-15).
    let ml = null;
    try {
      ml = await proxyToML('/predict_eeg', {
        eeg_file: req.body.eeg_file,
        eeg_filename: filename,
        sampling_rate: req.body.sampling_rate,
      });
    } catch (err) {
      console.error('[compatController.predictEEG] ML service unreachable:', err.message);
    }
    if (!ml || !ml.status) {
      return res.json({ status: 'success', model_backend: 'unavailable',
        prediction: noResult('Analysis unavailable', 'The EEG analysis service is offline. No result was produced.') });
    }
    if (ml.status !== 'SUCCESS') {
      return res.json({ status: 'success', model_backend: 'python_ml',
        prediction: noResult('Cannot assess', ml.reason || 'The file could not be analysed.', { model_version: ml.model_version }) });
    }

    const detected = ml.result === 'seizure_like_activity';
    const maxP = ml.max_window_probability;
    const ev = ml.evaluation?.event_metrics || {};
    const patterns = detected
      ? ml.flagged_intervals.map((f) => `Flagged ${f.start_s}–${f.end_s} s (peak probability ${f.max_probability})`)
      : ['No interval met the alarm rule'];
    const prediction = {
      seizure_type: detected ? 'Seizure-like activity' : 'No seizure-like activity',
      confidence: detected ? maxP : 1 - maxP,
      risk_level: detected ? 'High' : 'Low',
      eeg_patterns: patterns,
      analysis_summary:
        `${ml.clinical_finding}. Analysed ${ml.duration_s} s, ${ml.channels.length} channels at ${ml.sampling_rate_hz} Hz ` +
        `(${ml.n_windows} windows). Model ${ml.model_version}, evaluated leave-one-patient-out on CHB-MIT: ` +
        `${ev.detected}/${ev.seizures} seizures detected, ${ev.fa_per_hour} false alarms/hour. ` +
        `${ml.warnings.length ? 'Warnings: ' + ml.warnings.join('; ') + '. ' : ''}${ml.disclaimer}`,
      all_scores: { 'Seizure-like': maxP, 'No seizure-like': 1 - maxP },
      flagged_intervals: ml.flagged_intervals,
      window_probabilities: ml.window_probabilities,
      model_version: ml.model_version,
    };

    await Prediction.create({
      userId: req.user?.id,
      seizureDetected: detected,
      seizureType: detected ? 'Unspecified Seizure' : 'Unknown',
      confidenceScore: prediction.confidence,
      alertTriggered: detected,
    }).catch((err) => console.error('[compatController.predictEEG] could not store prediction:', err.message)); // non-fatal

    return res.json({ status: 'success', prediction, model_backend: 'python_ml' });
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
