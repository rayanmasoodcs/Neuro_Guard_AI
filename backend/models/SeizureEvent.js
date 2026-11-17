const mongoose = require('mongoose');

const seizureEventSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      index: true,
    },
    patientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Patient',
      index: true,
    },
    seizureType: {
      type: String,
      enum: ['Generalized Tonic-Clonic', 'Focal Impaired Awareness', 'Absence', 'Myoclonic', 'Atonic', 'Unknown', 'Unspecified Seizure'],
      default: 'Unspecified Seizure',
      trim: true,
    },
    eventTime: {
      type: String,
      trim: true,
    },
    severity: {
      type: String,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    eventDate: {
      type: Date,
      default: Date.now,
    },
    associatedMedicationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Medication',
    },
    associatedReminderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Reminder',
    },
    relatedEegUploadId: {
      type: mongoose.Schema.Types.ObjectId,
    },
    medicationNotificationSent: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);
seizureEventSchema.index({ userId: 1, eventDate: -1 });

module.exports = mongoose.model('SeizureEvent', seizureEventSchema);
