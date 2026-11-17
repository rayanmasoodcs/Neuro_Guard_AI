const mongoose = require('mongoose');

const sensorReadingSchema = new mongoose.Schema(
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
    heartRate: {
      type: Number,
      min: [20, 'Heart rate is too low'],
      max: [300, 'Heart rate is physiologically impossible'],
    },
    bodyTemperature: {
      type: Number,
      min: [30, 'Body temperature is too low'],
      max: [45, 'Body temperature is physiologically impossible'],
    },
    accelerometer: {
      x: { type: Number },
      y: { type: Number },
      z: { type: Number },
    },
    gyroscope: {
      x: { type: Number },
      y: { type: Number },
      z: { type: Number },
    },
    fallDetection: {
      type: Boolean,
      default: false,
    },
    eegReading: {
      type: mongoose.Schema.Types.Mixed,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);
sensorReadingSchema.index({ userId: 1, timestamp: -1 });

module.exports = mongoose.model('SensorReading', sensorReadingSchema);
