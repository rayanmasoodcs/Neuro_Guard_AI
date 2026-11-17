const express = require('express');
const router = express.Router();
const { resolveLegacyIds } = require('../middleware/resolveLegacyIds');
const patientController = require('../controllers/patientController');

router.post('/update_or_add_patient', patientController.updateOrAddPatient);
router.get('/get_patient_screen_stats', patientController.getPatientScreenStats);
router.get('/get_all_patients', patientController.getAllPatients);
router.get('/get_dashboard_stats', patientController.getDashboardStats);
router.get('/get_recent_patients', patientController.getRecentPatients);
router.get('/get_patient_details/:patient_id', patientController.getPatientDetails);
router.get('/get_medical_history/:user_id', resolveLegacyIds, patientController.getMedicalHistory);

module.exports = router;
