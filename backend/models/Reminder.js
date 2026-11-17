const mongoose = require('mongoose');

const reminderSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: {
      type: String,
      trim: true,
    },
    reminderType: {
      type: String,
      enum: ['Medication', 'Appointment'],
      required: true,
    },
    reminderDate: {
      type: Date,
    },
    reminderTime: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);
reminderSchema.index({ userId: 1 });

module.exports = mongoose.model('Reminder', reminderSchema);
