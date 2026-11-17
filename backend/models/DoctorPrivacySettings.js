const mongoose = require('mongoose');

const doctorPrivacySettingsSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    profileVisibility: {
      type: Boolean,
      default: true,
    },
    shareActivity: {
      type: Boolean,
      default: true,
    },
    allowMessages: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('DoctorPrivacySettings', doctorPrivacySettingsSchema);
