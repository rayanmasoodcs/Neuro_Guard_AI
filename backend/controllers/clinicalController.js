const {
  Medication,
  Reminder,
  FamilyContact,
  Chat,
  PatientNotification,
  PatientPrivacy,
  DoctorNotificationSettings,
  DoctorPrivacySettings,
} = require('../models');

// ──────────────────────────────────────────────────────────
// MEDICATIONS & REMINDERS
// ──────────────────────────────────────────────────────────

exports.addMedication = async (req, res) => {
  try {
    const { user_id, userId, patient_id, patientId, medicine_name, medicineName, dose, description, frequency, timing, take_with, takeWith } = req.body;

    const targetUserId = userId || user_id;
    const targetMedicine = medicineName || medicine_name;

    if (!targetUserId || !targetMedicine || !dose || !frequency || !timing) {
      return res.status(400).json({ status: 'error', message: 'User ID, medicine name, dose, frequency, and timing are required.' });
    }

    const newMed = new Medication({
      userId: targetUserId,
      patientId: patientId || patient_id || undefined,
      medicineName: targetMedicine,
      dose,
      description: description || '',
      frequency,
      timing,
      takeWith: takeWith || take_with || '',
    });

    await newMed.save();

    return res.status(201).json({
      status: 'success',
      message: 'Medication added successfully.',
      medication: newMed,
    });
  } catch (error) {
    console.error('[ADD MEDICATION ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to add medication.' });
  }
};

exports.getMedications = async (req, res) => {
  try {
    const { user_id } = req.params;
    const medications = await Medication.find({
      $or: [
        { userId: user_id.match(/^[0-9a-fA-F]{24}$/) ? user_id : null },
        { patientId: user_id.match(/^[0-9a-fA-F]{24}$/) ? user_id : null }
      ]
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      status: 'success',
      medications,
    });
  } catch (error) {
    console.error('[GET MEDICATIONS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch medications.' });
  }
};

exports.deleteMedication = async (req, res) => {
  try {
    const { id, name } = req.params;

    if (id.match(/^[0-9a-fA-F]{24}$/)) {
      const med = await Medication.findById(id);
      if (!med) {
         return res.status(404).json({status: 'error', message: 'Medication not found'});
      }
      if (req.user && med.userId !== req.user.id && req.user.role !== 'admin' && req.user.role !== 'clinician' && req.user.role !== 'doctor') {
         return res.status(403).json({status: 'error', message: 'Unauthorized'});
      }
      await Medication.findByIdAndDelete(id);
    } else {
      if (req.user && id !== req.user.id && req.user.role !== 'admin' && req.user.role !== 'clinician' && req.user.role !== 'doctor') {
         return res.status(403).json({status: 'error', message: 'Unauthorized'});
      }
      await Medication.deleteMany({ userId: id, medicineName: name });
    }

    return res.status(200).json({ status: 'success', message: 'Medication removed successfully.' });
  } catch (error) {
    console.error('[DELETE MEDICATION ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to delete medication.' });
  }
};

exports.addReminder = async (req, res) => {
  try {
    const { user_id, userId, title, reminder_type, reminderType, reminder_date, reminderDate, reminder_time, reminderTime } = req.body;

    const targetUserId = userId || user_id;
    const targetType = reminderType || reminder_type || 'Medication';

    if (!targetUserId || !title) {
      return res.status(400).json({ status: 'error', message: 'User ID and title are required.' });
    }

    const reminder = new Reminder({
      userId: targetUserId,
      title,
      reminderType: targetType,
      reminderDate: reminderDate || reminder_date || new Date(),
      reminderTime: reminderTime || reminder_time || '09:00 AM',
    });

    await reminder.save();

    return res.status(201).json({
      status: 'success',
      message: 'Reminder scheduled successfully.',
      reminder,
    });
  } catch (error) {
    console.error('[ADD REMINDER ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to schedule reminder.' });
  }
};

exports.getReminders = async (req, res) => {
  try {
    const { user_id } = req.params;
    const reminders = await Reminder.find({ userId: user_id }).sort({ reminderDate: 1 });

    return res.status(200).json({
      status: 'success',
      reminders,
    });
  } catch (error) {
    console.error('[GET REMINDERS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch reminders.' });
  }
};

// ──────────────────────────────────────────────────────────
// FAMILY CONTACTS
// ──────────────────────────────────────────────────────────

exports.getFamilyContacts = async (req, res) => {
  try {
    const { user_id } = req.params;
    const contacts = await FamilyContact.find({ userId: user_id });
    return res.status(200).json({ status: 'success', contacts });
  } catch (error) {
    console.error('[GET FAMILY CONTACTS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch family contacts.' });
  }
};

exports.addFamilyContact = async (req, res) => {
  try {
    const { user_id, userId, name, phone_number, phoneNumber, relationship } = req.body;
    const targetUserId = userId || user_id;
    const targetPhone = phoneNumber || phone_number;

    if (!targetUserId || !name || !targetPhone) {
      return res.status(400).json({ status: 'error', message: 'User ID, name, and phone number are required.' });
    }

    const contact = new FamilyContact({
      userId: targetUserId,
      name,
      phoneNumber: targetPhone,
      relationship: relationship || 'Family',
    });

    await contact.save();

    return res.status(201).json({ status: 'success', message: 'Family contact added.', contact });
  } catch (error) {
    console.error('[ADD FAMILY CONTACT ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to add contact.' });
  }
};

exports.deleteFamilyContact = async (req, res) => {
  try {
    const { id } = req.params;
    await FamilyContact.findByIdAndDelete(id);
    return res.status(200).json({ status: 'success', message: 'Contact deleted.' });
  } catch (error) {
    console.error('[DELETE FAMILY CONTACT ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to delete contact.' });
  }
};

// ──────────────────────────────────────────────────────────
// CHATBOT HISTORY
// ──────────────────────────────────────────────────────────

exports.saveChatMessage = async (req, res) => {
  try {
    const { user_id, userId, text, is_user, isUser } = req.body;
    const targetUserId = userId || user_id;
    const targetIsUser = isUser !== undefined ? isUser : (is_user !== undefined ? is_user : true);

    if (!targetUserId || !text) {
      return res.status(400).json({ status: 'error', message: 'User ID and message text required.' });
    }

    const chat = new Chat({
      userId: targetUserId,
      text,
      isUser: targetIsUser,
    });

    await chat.save();

    return res.status(201).json({ status: 'success', chat });
  } catch (error) {
    console.error('[SAVE CHAT MESSAGE ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to save chat message.' });
  }
};

exports.getChatHistory = async (req, res) => {
  try {
    const { user_id } = req.params;
    const history = await Chat.find({ userId: user_id }).sort({ timestamp: 1 });
    return res.status(200).json({ status: 'success', history });
  } catch (error) {
    console.error('[GET CHAT HISTORY ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch chat history.' });
  }
};

// ──────────────────────────────────────────────────────────
// SETTINGS & PRIVACY
// ──────────────────────────────────────────────────────────

exports.getNotificationSettings = async (req, res) => {
  try {
    const { id } = req.params;
    let settings = await PatientNotification.findOne({ userId: id });
    if (!settings) {
      settings = await PatientNotification.create({ userId: id });
    }
    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[GET NOTIFICATION SETTINGS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch notification settings.' });
  }
};

exports.saveNotificationSettings = async (req, res) => {
  try {
    const userId = req.body.user_id || req.body.userId;
    const { all_notifications, emergency_alerts, ai_alerts, patient_updates } = req.body;

    const settings = await PatientNotification.findOneAndUpdate(
      { userId },
      {
        allNotifications: all_notifications !== undefined ? all_notifications : true,
        emergencyAlerts: emergency_alerts !== undefined ? emergency_alerts : true,
        aiAlerts: ai_alerts !== undefined ? ai_alerts : true,
        patientUpdates: patient_updates !== undefined ? patient_updates : true,
      },
      { new: true, upsert: true }
    );

    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[SAVE NOTIFICATION SETTINGS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to save notification settings.' });
  }
};

exports.getPrivacySettings = async (req, res) => {
  try {
    const { id } = req.params;
    let settings = await PatientPrivacy.findOne({ userId: id });
    if (!settings) {
      settings = await PatientPrivacy.create({ userId: id });
    }
    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[GET PRIVACY SETTINGS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch privacy settings.' });
  }
};

exports.savePrivacySettings = async (req, res) => {
  try {
    const userId = req.body.user_id || req.body.userId;
    const { biometric_login, share_health_data, emergency_access, remember_device, app_lock } = req.body;

    const settings = await PatientPrivacy.findOneAndUpdate(
      { userId },
      {
        biometricLogin: biometric_login !== undefined ? biometric_login : true,
        shareHealthData: share_health_data !== undefined ? share_health_data : false,
        emergencyAccess: emergency_access !== undefined ? emergency_access : true,
        rememberDevice: remember_device !== undefined ? remember_device : true,
        appLock: app_lock !== undefined ? app_lock : false,
      },
      { new: true, upsert: true }
    );

    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[SAVE PRIVACY SETTINGS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to save privacy settings.' });
  }
};

exports.getDoctorNotificationSettings = async (req, res) => {
  try {
    const { id } = req.params;
    let settings = await DoctorNotificationSettings.findOne({ userId: id });
    if (!settings) {
      settings = await DoctorNotificationSettings.create({ userId: id });
    }
    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[GET DOCTOR NOTIFICATION ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch doctor notification settings.' });
  }
};

exports.saveDoctorNotificationSettings = async (req, res) => {
  try {
    const userId = req.body.user_id || req.body.userId;
    const { push_notifications, email_notifications, appointment_notifications, reminder_notifications } = req.body;

    const settings = await DoctorNotificationSettings.findOneAndUpdate(
      { userId },
      {
        pushNotifications: push_notifications !== undefined ? push_notifications : true,
        emailNotifications: email_notifications !== undefined ? email_notifications : true,
        appointmentNotifications: appointment_notifications !== undefined ? appointment_notifications : true,
        reminderNotifications: reminder_notifications !== undefined ? reminder_notifications : true,
      },
      { new: true, upsert: true }
    );

    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[SAVE DOCTOR NOTIFICATION ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to save doctor notification settings.' });
  }
};

exports.getDoctorPrivacySettings = async (req, res) => {
  try {
    const { id } = req.params;
    let settings = await DoctorPrivacySettings.findOne({ userId: id });
    if (!settings) {
      settings = await DoctorPrivacySettings.create({ userId: id });
    }
    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[GET DOCTOR PRIVACY ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch doctor privacy settings.' });
  }
};

exports.saveDoctorPrivacySettings = async (req, res) => {
  try {
    const userId = req.body.user_id || req.body.userId;
    const { profile_visibility, share_activity, allow_messages } = req.body;

    const settings = await DoctorPrivacySettings.findOneAndUpdate(
      { userId },
      {
        profileVisibility: profile_visibility !== undefined ? profile_visibility : true,
        shareActivity: share_activity !== undefined ? share_activity : true,
        allowMessages: allow_messages !== undefined ? allow_messages : true,
      },
      { new: true, upsert: true }
    );

    return res.status(200).json({ status: 'success', settings });
  } catch (error) {
    console.error('[SAVE DOCTOR PRIVACY ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to save doctor privacy settings.' });
  }
};
