const { User, PatientNotification, PatientPrivacy, DoctorNotificationSettings, DoctorPrivacySettings } = require('../models');
const { generateToken } = require('../middleware/authMiddleware');
const { ensureLegacyId } = require('../utils/userId');

/**
 * Register a new user (Patient or Doctor)
 */
exports.signup = async (req, res) => {
  try {
    const { name, email, phone, role, password, age, gender } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ status: 'error', message: 'Name, email, and password are required.' });
    }

    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ status: 'error', message: 'Email address already registered.' });
    }

    const userRole = (role === 'doctor' || role === 'Doctor') ? 'doctor' : 'patient';

    const newUser = new User({
      name,
      email: email.toLowerCase(),
      phone: phone || '',
      role: userRole,
      password,
      age: age ? parseInt(age, 10) : undefined,
      gender: gender || '',
    });

    await newUser.save();
    await ensureLegacyId(newUser);

    // Create default notification and privacy settings for new user
    if (userRole === 'patient') {
      await PatientNotification.create({ userId: newUser._id });
      await PatientPrivacy.create({ userId: newUser._id });
    } else {
      await DoctorNotificationSettings.create({ userId: newUser._id });
      await DoctorPrivacySettings.create({ userId: newUser._id });
    }

    const token = generateToken(newUser);

    return res.status(201).json({
      status: 'success',
      message: 'User registered successfully.',
      token,
      user: {
        id: newUser.legacyId,
        mongo_id: newUser._id,
        name: newUser.name,
        email: newUser.email,
        phone: newUser.phone,
        role: newUser.role,
        age: newUser.age,
        gender: newUser.gender,
      },
    });
  } catch (error) {
    console.error('[AUTH SIGNUP ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'An internal server error occurred during registration.' });
  }
};

/**
 * Authenticate existing user
 */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ status: 'error', message: 'Email and password are required.' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(401).json({ status: 'error', message: 'Invalid credentials.' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ status: 'error', message: 'Invalid credentials.' });
    }

    if (!user.legacyId) await ensureLegacyId(user);

    const token = generateToken(user);

    return res.status(200).json({
      status: 'success',
      message: 'Login successful.',
      token,
      user: {
        id: user.legacyId || user._id,
        mongo_id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        age: user.age,
        gender: user.gender,
      },
    });
  } catch (error) {
    console.error('[AUTH LOGIN ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'An internal server error occurred during login.' });
  }
};

/**
 * Update user demographics
 */
exports.updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, email, phone, age, gender } = req.body;

    if (!userId) {
      return res.status(400).json({ status: 'error', message: 'User ID is required.' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ status: 'error', message: 'User not found.' });
    }

    if (name) user.name = name;
    if (email) user.email = email.toLowerCase();
    if (phone !== undefined) user.phone = phone;
    if (age !== undefined) user.age = parseInt(age, 10);
    if (gender) user.gender = gender;

    await user.save();

    return res.status(200).json({
      status: 'success',
      message: 'Profile updated successfully.',
      user: {
        id: user.legacyId || user._id,
        mongo_id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        age: user.age,
        gender: user.gender,
      },
    });
  } catch (error) {
    console.error('[AUTH UPDATE PROFILE ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to update user profile.' });
  }
};

/**
 * Authenticated password change
 */
exports.changePassword = async (req, res) => {
  try {
    const userId = req.user.id;
    const { current_password, new_password } = req.body;

    if (!userId || !new_password) {
      return res.status(400).json({ status: 'error', message: 'User ID and new password are required.' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ status: 'error', message: 'User not found.' });
    }

    if (!current_password) {
      return res.status(400).json({ status: 'error', message: 'Current password is required.' });
    }

    const isMatch = await user.comparePassword(current_password);
    if (!isMatch) {
      return res.status(401).json({ status: 'error', message: 'Current password is incorrect.' });
    }

    user.password = new_password; // Will be hashed by pre-save middleware
    await user.save();

    return res.status(200).json({ status: 'success', message: 'Password changed successfully.' });
  } catch (error) {
    console.error('[AUTH CHANGE PASSWORD ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to change password.' });
  }
};
