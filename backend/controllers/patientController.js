const { Patient, User, Medication } = require('../models');

/**
 * Add or update patient chart record
 */
exports.updateOrAddPatient = async (req, res) => {
  try {
    const {
      patient_id,
      doctorId,
      doctor_id,
      name,
      age,
      gender,
      medical_condition,
      medicalCondition,
      last_eeg_info,
      lastEegInfo,
      email,
      phone,
      address,
      emergency_contact,
      emergencyContact,
    } = req.body;

    const targetDocId = doctorId || doctor_id;
    const targetName = name;
    const targetAge = age ? parseInt(age, 10) : undefined;
    const targetGender = gender;
    const targetCondition = medicalCondition || medical_condition || '';
    const targetEegInfo = lastEegInfo || last_eeg_info || '';
    const targetEmergency = emergencyContact || emergency_contact || '';

    let patient;

    if (patient_id) {
      // Find existing patient by ObjectId or custom patientCode
      patient = await Patient.findOne({
        $or: [
          { _id: patient_id.match(/^[0-9a-fA-F]{24}$/) ? patient_id : null },
          { patientCode: patient_id }
        ]
      });
    }

    if (patient) {
      // Update
      if (targetName) patient.name = targetName;
      if (targetAge !== undefined) patient.age = targetAge;
      if (targetGender) patient.gender = targetGender;
      if (targetCondition) patient.medicalCondition = targetCondition;
      if (targetEegInfo) patient.lastEegInfo = targetEegInfo;
      if (email) patient.email = email;
      if (phone) patient.phone = phone;
      if (address) patient.address = address;
      if (targetEmergency) patient.emergencyContact = targetEmergency;
      if (targetDocId) patient.doctorId = targetDocId;

      await patient.save();

      return res.status(200).json({
        status: 'success',
        message: 'Patient profile updated successfully.',
        patient_id: patient._id,
        patient,
      });
    } else {
      // Create new patient
      const newPatientCode = patient_id || `P-${Date.now()}`;
      patient = new Patient({
        patientCode: newPatientCode,
        doctorId: targetDocId,
        name: targetName,
        age: targetAge,
        gender: targetGender,
        medicalCondition: targetCondition,
        lastEegInfo: targetEegInfo,
        email: email || '',
        phone: phone || '',
        address: address || '',
        emergencyContact: targetEmergency,
      });

      await patient.save();

      return res.status(201).json({
        status: 'success',
        message: 'Patient profile created successfully.',
        patient_id: patient._id,
        patient,
      });
    }
  } catch (error) {
    console.error('[PATIENT UPDATE/ADD ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to create or update patient record.' });
  }
};

/**
 * Get screen statistics for doctor patient directory
 */
exports.getPatientScreenStats = async (req, res) => {
  try {
    const doctorId = req.query.doctor_id || req.query.doctorId;
    
    let query = {};
    if (doctorId && doctorId.match(/^[0-9a-fA-F]{24}$/)) {
      query.doctorId = doctorId;
    }

    const total = await Patient.countDocuments(query);
    const critical = await Patient.countDocuments({ ...query, medicalCondition: { $regex: /critical|severe|refractory/i } });
    const stable = total - critical;

    return res.status(200).json({
      status: 'success',
      total_patients: total,
      critical_patients: critical,
      stable_patients: stable,
    });
  } catch (error) {
    console.error('[GET PATIENT SCREEN STATS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch patient statistics.' });
  }
};

/**
 * Get list of all patients managed by doctor
 */
exports.getAllPatients = async (req, res) => {
  try {
    const doctorId = req.query.doctor_id || req.query.doctorId;
    
    let query = {};
    if (doctorId && doctorId.match(/^[0-9a-fA-F]{24}$/)) {
      query.doctorId = doctorId;
    }

    const patients = await Patient.find(query).sort({ createdAt: -1 });

    const formattedPatients = patients.map((p) => ({
      id: p._id,
      patient_id: p.patientCode || p._id.toString(),
      name: p.name,
      age: p.age,
      gender: p.gender,
      medical_condition: p.medicalCondition,
      last_eeg_info: p.lastEegInfo,
      email: p.email,
      phone: p.phone,
      address: p.address,
      emergency_contact: p.emergencyContact,
      doctor_id: p.doctorId,
    }));

    return res.status(200).json({
      status: 'success',
      patients: formattedPatients,
    });
  } catch (error) {
    console.error('[GET ALL PATIENTS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch patients list.' });
  }
};

/**
 * Get doctor dashboard summary metrics
 */
exports.getDashboardStats = async (req, res) => {
  try {
    const doctorId = req.query.doctor_id || req.query.doctorId;

    let query = {};
    if (doctorId && doctorId.match(/^[0-9a-fA-F]{24}$/)) {
      query.doctorId = doctorId;
    }

    const totalPatients = await Patient.countDocuments(query);
    const criticalCount = await Patient.countDocuments({ ...query, medicalCondition: { $regex: /critical|severe/i } });

    return res.status(200).json({
      status: 'success',
      total_patients: totalPatients,
      critical_count: criticalCount,
      emergency_alerts: criticalCount,
      active_monitoring: totalPatients,
    });
  } catch (error) {
    console.error('[GET DASHBOARD STATS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch dashboard statistics.' });
  }
};

/**
 * Get recent patient registrations for doctor dashboard
 */
exports.getRecentPatients = async (req, res) => {
  try {
    const doctorId = req.query.doctor_id || req.query.doctorId;

    let query = {};
    if (doctorId && doctorId.match(/^[0-9a-fA-F]{24}$/)) {
      query.doctorId = doctorId;
    }

    const patients = await Patient.find(query).sort({ createdAt: -1 }).limit(5);

    const formatted = patients.map((p) => ({
      id: p._id,
      patient_id: p.patientCode || p._id.toString(),
      name: p.name,
      age: p.age,
      gender: p.gender,
      medical_condition: p.medicalCondition,
    }));

    return res.status(200).json({
      status: 'success',
      recent_patients: formatted,
    });
  } catch (error) {
    console.error('[GET RECENT PATIENTS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch recent patients.' });
  }
};

/**
 * Get patient details chart record
 */
exports.getPatientDetails = async (req, res) => {
  try {
    const { patient_id } = req.params;

    const patient = await Patient.findOne({
      $or: [
        { _id: patient_id.match(/^[0-9a-fA-F]{24}$/) ? patient_id : null },
        { patientCode: patient_id }
      ]
    });

    if (!patient) {
      return res.status(404).json({ status: 'error', message: 'Patient not found.' });
    }

    const medications = await Medication.find({
      $or: [{ patientId: patient._id }, { userId: patient.doctorId }]
    });

    return res.status(200).json({
      status: 'success',
      patient: {
        id: patient._id,
        patient_id: patient.patientCode || patient._id.toString(),
        name: patient.name,
        age: patient.age,
        gender: patient.gender,
        medical_condition: patient.medicalCondition,
        last_eeg_info: patient.lastEegInfo,
        email: patient.email,
        phone: patient.phone,
        address: patient.address,
        emergency_contact: patient.emergencyContact,
        doctor_id: patient.doctorId,
      },
      medications,
    });
  } catch (error) {
    console.error('[GET PATIENT DETAILS ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch patient details.' });
  }
};

/**
 * Get patient medical history chart
 */
exports.getMedicalHistory = async (req, res) => {
  try {
    const { user_id } = req.params;

    let user = null;
    let patient = null;

    if (user_id.match(/^[0-9a-fA-F]{24}$/)) {
      user = await User.findById(user_id);
      patient = await Patient.findOne({ email: user?.email });
    } else {
      patient = await Patient.findOne({ patientCode: user_id });
    }

    const medications = await Medication.find({
      $or: [
        { userId: user_id.match(/^[0-9a-fA-F]{24}$/) ? user_id : null },
        { patientId: patient?._id }
      ]
    });

    return res.status(200).json({
      status: 'success',
      user: user || { id: user_id, name: patient?.name || 'Patient' },
      patient: patient || {},
      medications,
    });
  } catch (error) {
    console.error('[GET MEDICAL HISTORY ERROR]', error);
    return res.status(500).json({ status: 'error', message: 'Failed to fetch medical history.' });
  }
};
