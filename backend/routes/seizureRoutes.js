const express = require('express');
const router = express.Router();
const { resolveLegacyIds } = require('../middleware/resolveLegacyIds');
const telemetryController = require('../controllers/telemetryController');
const compatController = require('../controllers/compatController');
const { authenticateToken, requireRole } = require('../middleware/authMiddleware');
const { validateRequest, storeSensorReadingSchema, predictSeizureRealtimeSchema, storeAlertSchema } = require('../middleware/validationMiddleware');

// Sensor Telemetry
// Require patient role for sensor read/writes (or admin/clinician via IDOR checks inside the controller)
router.post('/store_sensor_reading', authenticateToken, requireRole('patient'), validateRequest(storeSensorReadingSchema), telemetryController.storeSensorReading);
router.get('/get_sensor_history', authenticateToken, telemetryController.getSensorHistory);

// AI Seizure Prediction & History
router.post('/predict_seizure_realtime', authenticateToken, requireRole('patient'), validateRequest(predictSeizureRealtimeSchema), telemetryController.predictSeizureRealtime);
router.get('/get_prediction_history', authenticateToken, telemetryController.getPredictionHistory);
router.get('/get_latest_prediction', authenticateToken, telemetryController.getLatestPrediction);

// Seizure Alerts & Logging
router.post('/store_alert', authenticateToken, validateRequest(storeAlertSchema), telemetryController.storeAlert);
router.get('/get_alerts', authenticateToken, telemetryController.getAlerts);
router.post('/acknowledge_alert/:id', authenticateToken, resolveLegacyIds, telemetryController.acknowledgeAlert);
router.post('/store_seizure_event', authenticateToken, requireRole('patient'), telemetryController.storeSeizureEvent);
router.get('/get_seizure_events/:id', authenticateToken, resolveLegacyIds, telemetryController.getSeizureEvents);

// Flutter compatibility / ML adapter endpoints
router.post('/predict_seizure_from_eeg', authenticateToken, compatController.predictEEG);
router.post('/predict_batch', authenticateToken, compatController.predictBatch);
router.post('/dataset_summary', authenticateToken, compatController.datasetSummary);
router.post('/generate_eeg_graph_for_patient', authenticateToken, compatController.generateGraph);
router.post('/generate_seizure_report', authenticateToken, compatController.generateReport);
router.get('/get_upcoming_alerts/:id', authenticateToken, resolveLegacyIds, compatController.upcomingAlerts);
router.post('/acknowledge_seizure_event/:id', authenticateToken, resolveLegacyIds, compatController.acknowledgeEvent);
router.post('/send_emergency_alert', authenticateToken, compatController.sendEmergencyAlert);
router.post('/trigger_notification', authenticateToken, compatController.triggerNotification);

module.exports = router;
