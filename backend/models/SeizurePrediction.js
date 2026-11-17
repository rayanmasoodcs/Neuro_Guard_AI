const mongoose = require('mongoose');

const seizurePredictionSchema = new mongoose.Schema(
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
    patientName: {
      type: String,
      trim: true,
    },
    patientGender: {
      type: String,
      trim: true,
    },
    predictionType: {
      type: String,
      trim: true,
    },
    predictedSeizureType: {
      type: String,
      trim: true,
    },
    riskLevel: {
      type: String,
      trim: true,
    },
    patientAge: {
      type: Number,
    },
    confidenceScore: {
      type: Number,
      min: 0,
      max: 1,
    },
    eeg: {
      fileName: { type: String },
      fileUrl: { type: String },
      featuresComputed: { type: mongoose.Schema.Types.Mixed },
    },
  },
  {
    timestamps: true,
  }
);
seizurePredictionSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('SeizurePrediction', seizurePredictionSchema);
