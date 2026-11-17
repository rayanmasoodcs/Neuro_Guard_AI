const { User, PatientNotification, PatientPrivacy, DoctorNotificationSettings, DoctorPrivacySettings } = require('../models');
const { ensureLegacyId } = require('../utils/userId');

/**
 * Admin-only: create a doctor or patient login account.
 */
exports.createUser = async (req, res) => {
  try {
    const { name, email, phone, role, password, age, gender } = req.body;
    if (!name || !email || !password || !['doctor', 'patient'].includes(role)) {
      return res.status(400).json({ status: 'error', message: 'Name, email, password and role (doctor or patient) are required.' });
    }
    if (await User.findOne({ email: email.toLowerCase() })) {
      return res.status(400).json({ status: 'error', message: 'Email address already registered.' });
    }

    const user = new User({
      name,
      email: email.toLowerCase(),
      phone: phone || '',
      role,
      password,
      age: age ? parseInt(age, 10) : undefined,
      gender: gender || '',
    });
    await user.save();
    await ensureLegacyId(user);

    if (role === 'patient') {
      await PatientNotification.create({ userId: user._id });
      await PatientPrivacy.create({ userId: user._id });
    } else {
      await DoctorNotificationSettings.create({ userId: user._id });
      await DoctorPrivacySettings.create({ userId: user._id });
    }

    return res.status(201).json({
      status: 'success',
      message: `${role === 'doctor' ? 'Doctor' : 'Patient'} account created.`,
      user: { id: user.legacyId, mongo_id: user._id, name: user.name, email: user.email, role: user.role },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({ status: 'error', message: Object.values(error.errors).map((e) => e.message).join(' ') });
    }
    console.error('[ADMIN CREATE USER ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to create user.' });
  }
};

/**
 * Admin-only: list doctor and patient accounts.
 */
exports.listUsers = async (req, res) => {
  try {
    const users = await User.find({ role: { $in: ['doctor', 'patient'] } })
      .select('legacyId name email role createdAt').sort({ createdAt: -1 }).lean();
    return res.json({
      status: 'success',
      users: users.map((u) => ({ id: u.legacyId, name: u.name, email: u.email, role: u.role, created_at: u.createdAt })),
    });
  } catch (error) {
    console.error('[ADMIN LIST USERS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to list users.' });
  }
};
