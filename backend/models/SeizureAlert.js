const mongoose = require('mongoose');

const seizureAlertSchema = new mongoose.Schema(
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
    predictionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Prediction',
    },
    alertType: {
      type: String,
      trim: true,
    },
    seizureType: {
      type: String,
      enum: ['Generalized Tonic-Clonic', 'Focal Impaired Awareness', 'Absence', 'Myoclonic', 'Atonic', 'Unknown', 'Unspecified Seizure'],
      default: 'Unspecified Seizure',
      trim: true,
    },
    riskLevel: {
      type: String,
      trim: true,
    },
    severity: {
      type: String,
      trim: true,
    },
    alertMessage: {
      type: String,
      trim: true,
    },
    actionTaken: {
      type: String,
      trim: true,
    },
    confidenceScore: {
      type: Number,
      min: 0,
      max: 1,
    },
    isAcknowledged: {
      type: Boolean,
      default: false,
    },
    acknowledgedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    acknowledgedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);
seizureAlertSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('SeizureAlert', seizureAlertSchema);
