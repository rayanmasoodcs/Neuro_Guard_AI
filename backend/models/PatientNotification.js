const mongoose = require('mongoose');

const patientNotificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    allNotifications: {
      type: Boolean,
      default: true,
    },
    emergencyAlerts: {
      type: Boolean,
      default: true,
    },
    aiAlerts: {
      type: Boolean,
      default: true,
    },
    patientUpdates: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('PatientNotification', patientNotificationSchema);
