const { SensorReading, Prediction, SeizurePrediction, SeizureAlert, SeizureEvent, ConnectionLog } = require('../models');

// ──────────────────────────────────────────────────────────
// SENSOR READINGS & TELEMETRY
// ──────────────────────────────────────────────────────────

exports.storeSensorReading = async (req, res) => {
  try {
    const { userId, deviceId, deviceName, heartRate, bodyTemperature, accelerometer, gyroscope, fallDetection, eegReading } = req.body;

    // Prevent IDOR: ensuring user is writing their own data or is an admin
    if (req.user && req.user.id !== userId && req.user.role !== 'admin' && req.user.role !== 'clinician') {
      return res.status(403).json({ status: 'error', message: 'Unauthorized to write data for another user.' });
    }

    const reading = new SensorReading({
      userId: userId,
      deviceId: deviceId || '',
      deviceName: deviceName || '',
      heartRate: heartRate,
      bodyTemperature: bodyTemperature,
      accelerometer: accelerometer || { x: 0, y: 0, z: 0 },
      gyroscope: gyroscope || { x: 0, y: 0, z: 0 },
      fallDetection: fallDetection || false,
      eegReading: eegReading || null,
      timestamp: new Date(),
    });

    await reading.save();

    return res.status(201).json({
      status: 'success',
      message: 'Sensor reading stored successfully.',
      reading_id: reading._id,
      reading,
    });
  } catch (error) {
    console.error('[STORE SENSOR READING ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to store sensor reading.' });
  }
};

exports.getSensorHistory = async (req, res) => {
  try {
    const userId = req.query.user_id || req.query.userId;
    
    if (req.user && userId && req.user.id !== userId && req.user.role !== 'admin' && req.user.role !== 'clinician' && req.user.role !== 'doctor') {
      return res.status(403).json({ status: 'error', message: 'Unauthorized to read data for another user.' });
    }

    const limit = parseInt(req.query.limit, 10) || 50;

    let query = {};
    if (userId) query.userId = userId;

    const history = await SensorReading.find(query).sort({ timestamp: -1 }).limit(limit);

    return res.status(200).json({
      status: 'success',
      history,
    });
  } catch (error) {
    console.error('[GET SENSOR HISTORY ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch sensor history.' });
  }
};

// ──────────────────────────────────────────────────────────
// PREDICTIONS & ALERTS
// ──────────────────────────────────────────────────────────

exports.predictSeizureRealtime = async (req, res) => {
  try {
    const { userId, sensor_data } = req.body;
    const targetUserId = userId;
    
    // Prevent IDOR
    if (req.user && req.user.id !== targetUserId && req.user.role !== 'admin' && req.user.role !== 'clinician') {
      return res.status(403).json({ status: 'error', message: 'Unauthorized.' });
    }

    // Call the ML service directly
    const { predict } = require('../services/mlService');
    const mlResult = await predict(req.body);

    const seizureDetected = mlResult.prediction === 'seizure';
    const confidenceScore = mlResult.confidence;
    const riskLevel = seizureDetected ? 'HIGH' : 'LOW';
    const seizureType = seizureDetected ? 'Generalized Tonic-Clonic' : 'Normal';

    // Persist prediction
    const prediction = new Prediction({
      userId: targetUserId,
      seizureDetected,
      seizureType,
      confidenceScore,
      predictionTimestamp: new Date(),
      alertTriggered: seizureDetected,
    });
    await prediction.save();

    if (seizureDetected) {
      await SeizureAlert.create({
        userId: targetUserId,
        predictionId: prediction._id,
        alertType: mlResult.source === 'heuristic_fallback' ? 'WARNING' : 'EMERGENCY',
        seizureType,
        riskLevel,
        severity: mlResult.source === 'heuristic_fallback' ? 'MEDIUM' : 'CRITICAL',
        alertMessage: mlResult.source === 'heuristic_fallback' 
            ? 'Heuristic detection logged (ML offline).' 
            : 'Real-time telemetry threshold triggered a seizure alarm.',
        confidenceScore,
      });
    }

    return res.status(200).json({
      status: 'success',
      seizure_detected: seizureDetected,
      seizure_type: seizureType,
      confidence_score: confidenceScore,
      risk_level: riskLevel,
      prediction_id: prediction._id,
      source: mlResult.source,
      clinical_finding: mlResult.clinical_finding,
      warnings: mlResult.warnings
    });
  } catch (error) {
    console.error('[PREDICT SEIZURE REALTIME ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to evaluate real-time telemetry.' });
  }
};

exports.getPredictionHistory = async (req, res) => {
  try {
    const userId = req.query.user_id || req.query.userId;
    
    if (req.user && userId && req.user.id !== userId && req.user.role !== 'admin' && req.user.role !== 'clinician' && req.user.role !== 'doctor') {
      return res.status(403).json({ status: 'error', message: 'Unauthorized.' });
    }

    const limit = parseInt(req.query.limit, 10) || 50;

    let query = {};
    if (userId) query.userId = userId;

    const predictions = await Prediction.find(query).sort({ predictionTimestamp: -1 }).limit(limit);

    return res.status(200).json({
      status: 'success',
      predictions,
    });
  } catch (error) {
    console.error('[GET PREDICTION HISTORY ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch prediction history.' });
  }
};

exports.getLatestPrediction = async (req, res) => {
  try {
    const userId = req.query.user_id || req.query.userId;
    let query = {};
    if (userId) query.userId = userId;

    const latest = await Prediction.findOne(query).sort({ predictionTimestamp: -1 });

    return res.status(200).json({
      status: 'success',
      prediction: latest || null,
    });
  } catch (error) {
    console.error('[GET LATEST PREDICTION ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch latest prediction.' });
  }
};

exports.storeAlert = async (req, res) => {
  try {
    const { userId, patientId, alertType, seizureType, severity, riskLevel, alertMessage, confidenceScore } = req.body;
    
    // Prevent IDOR
    if (req.user && req.user.id !== userId && req.user.role !== 'admin' && req.user.role !== 'clinician') {
      return res.status(403).json({ status: 'error', message: 'Unauthorized.' });
    }

    const alert = new SeizureAlert({
      userId: userId,
      patientId: patientId || userId,
      alertType: alertType || 'ALERT',
      seizureType: seizureType || 'Unknown',
      severity: severity || 'MEDIUM',
      riskLevel: riskLevel || 'MEDIUM',
      alertMessage: alertMessage || 'Seizure notification logged.',
      confidenceScore: confidenceScore || 0.8,
    });

    await alert.save();

    return res.status(201).json({ status: 'success', alert_id: alert._id, alert });
  } catch (error) {
    console.error('[STORE ALERT ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to log alert.' });
  }
};

exports.getAlerts = async (req, res) => {
  try {
    const userId = req.query.user_id || req.query.userId;
    
    if (req.user && userId && req.user.id !== userId && req.user.role !== 'admin' && req.user.role !== 'clinician' && req.user.role !== 'doctor') {
      return res.status(403).json({ status: 'error', message: 'Unauthorized.' });
    }

    let query = {};
    if (userId) query.userId = userId;

    const alerts = await SeizureAlert.find(query).sort({ createdAt: -1 });

    return res.status(200).json({ status: 'success', alerts });
  } catch (error) {
    console.error('[GET ALERTS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch alerts.' });
  }
};

exports.acknowledgeAlert = async (req, res) => {
  try {
    const { id } = req.params;
    const { acknowledged_by, action_taken } = req.body;

    const alert = await SeizureAlert.findByIdAndUpdate(
      id,
      {
        isAcknowledged: true,
        acknowledgedBy: acknowledged_by,
        actionTaken: action_taken || 'Acknowledged by clinician',
        acknowledgedAt: new Date(),
      },
      { new: true }
    );

    return res.status(200).json({ status: 'success', alert });
  } catch (error) {
    console.error('[ACKNOWLEDGE ALERT ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to acknowledge alert.' });
  }
};

exports.storeSeizureEvent = async (req, res) => {
  try {
    const { user_id, userId, patient_id, patientId, seizure_type, event_date, event_time, severity, description } = req.body;

    const event = new SeizureEvent({
      userId: userId || user_id,
      patientId: patientId || patient_id,
      seizureType: seizure_type || 'Unspecified Seizure',
      eventDate: event_date ? new Date(event_date) : new Date(),
      eventTime: event_time || '00:00',
      severity: severity || 'MODERATE',
      description: description || '',
    });

    await event.save();

    return res.status(201).json({ status: 'success', event_id: event._id, event });
  } catch (error) {
    console.error('[STORE SEIZURE EVENT ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to store seizure event.' });
  }
};

exports.getSeizureEvents = async (req, res) => {
  try {
    const { id } = req.params;
    const events = await SeizureEvent.find({ $or: [{ userId: id }, { patientId: id }] }).sort({ eventDate: -1 });

    return res.status(200).json({ status: 'success', events });
  } catch (error) {
    console.error('[GET SEIZURE EVENTS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch seizure events.' });
  }
};
