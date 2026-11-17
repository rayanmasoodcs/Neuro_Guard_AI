const express = require('express');
const router = express.Router();
const { resolveLegacyIds } = require('../middleware/resolveLegacyIds');
const clinicalController = require('../controllers/clinicalController');

// Medications & Reminders
router.post('/add_medication', clinicalController.addMedication);
router.get('/get_medications/:user_id', resolveLegacyIds, clinicalController.getMedications);
router.delete('/delete_medication/:id/:name', resolveLegacyIds, clinicalController.deleteMedication);
router.post('/add_reminder', clinicalController.addReminder);
router.get('/get_reminders/:user_id', resolveLegacyIds, clinicalController.getReminders);

// Family Contacts
router.get('/get_family_contacts/:user_id', resolveLegacyIds, clinicalController.getFamilyContacts);
router.post('/add_family_contact', clinicalController.addFamilyContact);
router.delete('/delete_family_contact/:id', resolveLegacyIds, clinicalController.deleteFamilyContact);

// Chatbot History
router.post('/save_chat_message', clinicalController.saveChatMessage);
router.get('/get_chat_history/:user_id', resolveLegacyIds, clinicalController.getChatHistory);

// Notification & Privacy Settings
router.get('/get_notification_settings/:id', resolveLegacyIds, clinicalController.getNotificationSettings);
router.post('/save_notification_settings', clinicalController.saveNotificationSettings);
router.get('/get_privacy_settings/:id', resolveLegacyIds, clinicalController.getPrivacySettings);
router.post('/save_privacy_settings', clinicalController.savePrivacySettings);
router.get('/get_doctor_notification_settings/:id', resolveLegacyIds, clinicalController.getDoctorNotificationSettings);
router.post('/save_doctor_notification_settings', clinicalController.saveDoctorNotificationSettings);
router.get('/get_doctor_privacy_settings/:id', resolveLegacyIds, clinicalController.getDoctorPrivacySettings);
router.post('/save_doctor_privacy_settings', clinicalController.saveDoctorPrivacySettings);

module.exports = router;
