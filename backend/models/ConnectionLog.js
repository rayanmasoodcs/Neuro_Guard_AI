const mongoose = require('mongoose');

const connectionLogSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    deviceId: {
      type: String,
      trim: true,
    },
    deviceName: {
      type: String,
      trim: true,
    },
    connectionStatus: {
      type: String,
      enum: ['connected', 'disconnected'],
      required: true,
    },
    connectionTimestamp: {
      type: Date,
      default: Date.now,
    },
    disconnectionTimestamp: {
      type: Date,
    },
    durationSeconds: {
      type: Number,
      min: 0,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('ConnectionLog', connectionLogSchema);
