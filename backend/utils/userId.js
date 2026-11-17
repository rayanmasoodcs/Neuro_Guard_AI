const mongoose = require('mongoose');
const { User } = require('../models');

async function resolveUserId(value) {
  if (value === undefined || value === null || value === '') return null;
  const text = String(value);
  if (mongoose.isValidObjectId(text)) return text;
  if (/^\d+$/.test(text)) {
    const user = await User.findOne({ legacyId: Number(text) }).select('_id');
    return user ? user._id : null;
  }
  return null;
}

async function ensureLegacyId(user) {
  if (user.legacyId) return user.legacyId;
  const last = await User.findOne({ legacyId: { $exists: true } }).sort({ legacyId: -1 }).select('legacyId');
  user.legacyId = (last?.legacyId || 0) + 1;
  await user.save();
  return user.legacyId;
}

module.exports = { resolveUserId, ensureLegacyId };
