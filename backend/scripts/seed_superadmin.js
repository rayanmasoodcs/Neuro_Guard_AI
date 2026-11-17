/**
 * Create (or reset the password of) the superadmin account.
 * Reads SUPERADMIN_NAME, SUPERADMIN_EMAIL and SUPERADMIN_PASSWORD from .env.
 *
 * Usage: node scripts/seed_superadmin.js
 */
require('dotenv').config();
const mongoose = require('mongoose');
const { User } = require('../models');
const { ensureLegacyId } = require('../utils/userId');

(async () => {
  const { SUPERADMIN_NAME = 'Super Admin', SUPERADMIN_EMAIL, SUPERADMIN_PASSWORD } = process.env;
  if (!SUPERADMIN_EMAIL || !SUPERADMIN_PASSWORD) {
    console.error('Set SUPERADMIN_EMAIL and SUPERADMIN_PASSWORD in backend/.env first.');
    process.exit(1);
  }
  await mongoose.connect(process.env.MONGODB_URI);

  let user = await User.findOne({ email: SUPERADMIN_EMAIL.toLowerCase() });
  if (user) {
    user.role = 'admin';
    user.password = SUPERADMIN_PASSWORD; // re-hashed by the pre-save hook
    console.log(`Updated existing account ${user.email} to superadmin.`);
  } else {
    user = new User({ name: SUPERADMIN_NAME, email: SUPERADMIN_EMAIL.toLowerCase(), role: 'admin', password: SUPERADMIN_PASSWORD });
    console.log(`Created superadmin ${user.email}.`);
  }
  await user.save();
  await ensureLegacyId(user);
  await mongoose.disconnect();
})().catch(async (e) => {
  console.error('Seeding failed:', e.message);
  await mongoose.disconnect();
  process.exit(1);
});
