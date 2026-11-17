const mongoose = require('mongoose');

const predictionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    sensorReadingId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SensorReading',
    },
    seizureDetected: {
      type: Boolean,
      required: true,
    },
    seizureType: {
      type: String,
      enum: ['Generalized Tonic-Clonic', 'Focal Impaired Awareness', 'Absence', 'Myoclonic', 'Atonic', 'Unknown', 'Unspecified Seizure'],
      default: 'Unspecified Seizure',
      trim: true,
    },
    confidenceScore: {
      type: Number,
      min: 0,
      max: 1,
    },
    predictionTimestamp: {
      type: Date,
      default: Date.now,
    },
    alertTriggered: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);
predictionSchema.index({ userId: 1, predictionTimestamp: -1 });

module.exports = mongoose.model('Prediction', predictionSchema);
