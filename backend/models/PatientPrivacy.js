const mongoose = require('mongoose');

const patientPrivacySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    biometricLogin: {
      type: Boolean,
      default: true,
    },
    shareHealthData: {
      type: Boolean,
      default: false,
    },
    emergencyAccess: {
      type: Boolean,
      default: true,
    },
    rememberDevice: {
      type: Boolean,
      default: true,
    },
    appLock: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('PatientPrivacy', patientPrivacySchema);
