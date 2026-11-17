const mongoose = require('mongoose');

const medicationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    patientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Patient',
      index: true,
    },
    medicineName: {
      type: String,
      required: true,
      trim: true,
    },
    dose: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    frequency: {
      type: String,
      required: true,
      trim: true,
    },
    timing: {
      type: String,
      required: true,
      trim: true,
    },
    takeWith: {
      type: String,
      default: '',
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);
medicationSchema.index({ userId: 1 });

module.exports = mongoose.model('Medication', medicationSchema);
