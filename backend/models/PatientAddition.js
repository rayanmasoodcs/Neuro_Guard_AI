const mongoose = require('mongoose');

const patientAdditionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    medicineName: {
      type: String,
      trim: true,
    },
    dose: {
      type: String,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    frequency: {
      type: String,
      trim: true,
    },
    timing: {
      type: String,
      trim: true,
    },
    takeWith: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('PatientAddition', patientAdditionSchema);
