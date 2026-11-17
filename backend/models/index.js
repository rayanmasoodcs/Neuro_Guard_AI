const User = require('./User');
const Patient = require('./Patient');
const Medication = require('./Medication');
const PatientAddition = require('./PatientAddition');
const Reminder = require('./Reminder');
const Chat = require('./Chat');
const ConnectionLog = require('./ConnectionLog');
const SensorReading = require('./SensorReading');
const Prediction = require('./Prediction');
const SeizurePrediction = require('./SeizurePrediction');
const SeizureAlert = require('./SeizureAlert');
const SeizureEvent = require('./SeizureEvent');
const FamilyContact = require('./FamilyContact');
const DoctorNotificationSettings = require('./DoctorNotificationSettings');
const DoctorPrivacySettings = require('./DoctorPrivacySettings');
const PatientNotification = require('./PatientNotification');
const PatientPrivacy = require('./PatientPrivacy');

module.exports = {
  User,
  Patient,
  Medication,
  PatientAddition,
  Reminder,
  Chat,
  ConnectionLog,
  SensorReading,
  Prediction,
  SeizurePrediction,
  SeizureAlert,
  SeizureEvent,
  FamilyContact,
  DoctorNotificationSettings,
  DoctorPrivacySettings,
  PatientNotification,
  PatientPrivacy,
};
