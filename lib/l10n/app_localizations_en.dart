// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NeuroGuard AI';

  @override
  String get appTagline => 'AI Powered Epileptic Seizure Monitoring System';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get available => 'Available';

  @override
  String get search => 'Search';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get success => 'Success';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get copyright => '© 2026 NeuroGuard AI';

  @override
  String get loginTitle => 'NeuroGuard AI';

  @override
  String get loginSubtitle => 'AI Powered Epileptic Seizure Monitoring System';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Password';

  @override
  String get loginButton => 'LOGIN';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signupPrompt => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get orDivider => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get chooseAccount => 'Choose an account';

  @override
  String get toContinue => 'to continue to NeuroGuard AI';

  @override
  String get useAnotherAccount => 'Use another account';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get loginSuccess => 'Logged in successfully!';

  @override
  String get roleConfigError => 'Role configuration profile error';

  @override
  String get newPrompt => 'New?';

  @override
  String get registerPrompt => 'Register';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get allFieldsRequired => 'All fields are required';

  @override
  String get serverError => 'Server connection failure';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get ageLabel => 'Age';

  @override
  String get genderLabel => 'Gender';

  @override
  String get roleLabel => 'Role';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get signupButton => 'SIGN UP';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginPrompt => 'Login';

  @override
  String get selectGender => 'Please select your gender status to proceed.';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidPassword =>
      'Password must be 8+ characters with uppercase, lowercase, number, and special character';

  @override
  String get signupSuccess => 'Account created successfully!';

  @override
  String get signupFailed => 'Registration failed';

  @override
  String get doctorRole => 'Doctor';

  @override
  String get patientRole => 'Patient';

  @override
  String get selectRole => 'Select Role';

  @override
  String get maleGender => 'Male';

  @override
  String get femaleGender => 'Female';

  @override
  String get otherGender => 'Other';

  @override
  String get doctorDashboard => 'Doctor Dashboard';

  @override
  String get patientDashboard => 'Patient Dashboard';

  @override
  String get bluetoothDevices => 'Bluetooth Devices';

  @override
  String get notifications => 'Notifications';

  @override
  String get homeNav => 'Home';

  @override
  String get patientsNav => 'Patients';

  @override
  String get reportsNav => 'Reports';

  @override
  String get profileNav => 'Profile';

  @override
  String get remindersNav => 'Reminders';

  @override
  String get dashboardNav => 'Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Logout Confirmation';

  @override
  String get logoutMessage =>
      'Are you sure you want to log out of your profile?';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String welcomeBack(String name) {
    return 'Welcome Back, $name';
  }

  @override
  String get welcomeSubtitle => 'Monitor patients and AI seizure predictions';

  @override
  String get todaysOverview => 'Today\'s Overview';

  @override
  String get overviewDescription =>
      'NeuroGuard AI continuously monitors EEG reports and emergency alerts in real time.';

  @override
  String get viewAiAnalysis => 'View AI Analysis';

  @override
  String get patientsStat => 'Patients';

  @override
  String get eegReportsStat => 'EEG Reports';

  @override
  String get emergencyStat => 'Emergency';

  @override
  String get aiAccuracyStat => 'AI Accuracy';

  @override
  String get aiSummary => 'AI Summary';

  @override
  String get aiPrediction => 'AI Prediction';

  @override
  String get aiPredictionSubtitle =>
      'No high-risk seizure predicted in the next few hours.';

  @override
  String get todaysAnalysis => 'Today\'s Analysis';

  @override
  String get todaysAnalysisSubtitle => '12 EEG reports processed successfully.';

  @override
  String get emergencyAlerts => 'Emergency Alerts';

  @override
  String emergencyAlertsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count patients require immediate review.',
      one: '1 patient requires immediate review.',
    );
    return '$_temp0';
  }

  @override
  String get loadingAlerts => 'Loading alerts...';

  @override
  String get recentPatients => 'Recent Patients';

  @override
  String get noPatientsYet => 'No patients registered yet.';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get uploadEeg => 'Upload EEG';

  @override
  String get alerts => 'Alerts';

  @override
  String get medication => 'Medication';

  @override
  String get prescribeMedication => 'Prescribe Medication';

  @override
  String get noMedicationsYet => 'No medications prescribed yet.';

  @override
  String get noMedicationsLogged =>
      'No prescribed medications logged for this patient.';

  @override
  String get patientList => 'Patient List';

  @override
  String get noPatientsMatch => 'No patient records match your criteria.';

  @override
  String get patientStatistics => 'Patient Statistics';

  @override
  String get total => 'Total';

  @override
  String get critical => 'Critical';

  @override
  String get stable => 'Stable';

  @override
  String get generalReview => 'General Review';

  @override
  String get needUrgentReview => 'Need Urgent Review';

  @override
  String get emergencyAlert => 'Emergency Alert';

  @override
  String get observationRequired => 'Observation Required';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get updatePatient => 'Update';

  @override
  String get searchPatient => 'Search Patient';

  @override
  String ageYears(String age) {
    return 'Age: $age';
  }

  @override
  String get years => 'Years';

  @override
  String get statusStable => 'Stable';

  @override
  String get statusEmergency => 'Emergency';

  @override
  String get statusCritical => 'Critical';

  @override
  String get statusObservation => 'Observation';

  @override
  String get managePatients =>
      'Manage, monitor and review all registered patients.';

  @override
  String get registerNewPatient => 'Register New Patient';

  @override
  String get patientIdLabel => 'Patient ID (e.g. 01, 02)';

  @override
  String get medicalConditionLabel => 'Medical Condition Status';

  @override
  String get lastEegInfo => 'Last EEG Info (e.g. today, last month)';

  @override
  String get lastEegInfoUpdate =>
      'Last EEG Info Update (e.g. today, last month)';

  @override
  String get emailHintPatient => 'Email Address';

  @override
  String get phoneHintPatient => 'Phone Number';

  @override
  String get residentialAddress => 'Residential Address';

  @override
  String get emergencyContactNumber => 'Emergency Contact Number';

  @override
  String get additionalNotes => 'Additional Notes / History';

  @override
  String get savePatientProfile => 'Save Patient Profile';

  @override
  String get updatePatientFile => 'Update Patient File';

  @override
  String get targetPatientId => 'Target Patient ID (Locate File)';

  @override
  String get updateInstructions =>
      'Fill only fields you wish to modify. Leaving fields blank leaves previous logs unchanged.';

  @override
  String get commitProfileUpdates => 'Commit Profile Updates';

  @override
  String get registerFailed => 'Failed to register patient';

  @override
  String get selectCondition =>
      'Please select a medical condition status value.';

  @override
  String get providePatientId =>
      'Please provide a Target Patient ID to identify the file.';

  @override
  String get notSpecified => 'Not Specified';

  @override
  String get patientRecordTitle => 'Clinical Status';

  @override
  String patientFileTitle(String id) {
    return 'Patient File: $id';
  }

  @override
  String get clinicalStatus => 'Clinical Status';

  @override
  String get medicalConditionDiagnostic => 'Medical Condition/Diagnostic Tag';

  @override
  String get noConditionFlagged => 'No condition flagged';

  @override
  String get latestEegAnalysis => 'Latest EEG Analysis Summary';

  @override
  String get noEegRecorded => 'No EEG tracking profile recorded yet.';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get emailNotProvided => 'Not provided';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get emergencySosContact => 'Emergency SOS Contact';

  @override
  String get activeMedications => 'Active Medications';

  @override
  String get confidentialClinicalFile =>
      'NeuroGuard AI • Confidential Clinical File';

  @override
  String get doseLabel => 'Dose';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get timingLabel => 'Timing';

  @override
  String get asDirected => 'As directed';

  @override
  String get reportSectionTitle => 'EEG Reports';

  @override
  String get reportSubtitle =>
      'Review uploaded EEG reports and AI-generated analysis.';

  @override
  String get aiReportAnalysis => 'AI Report Analysis';

  @override
  String get uploadEegPrompt =>
      'Upload an EEG report to receive seizure prediction and AI-powered neurological insights.';

  @override
  String get uploadEegButton => 'Upload EEG Report';

  @override
  String get recentReports => 'Recent Reports';

  @override
  String get aiStatistics => 'AI Statistics';

  @override
  String get reportsProcessed => 'Reports Processed';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get reportStatusNormal => 'Normal';

  @override
  String get reportStatusObservation => 'Observation';

  @override
  String get reportStatusEmergency => 'Emergency';

  @override
  String get reportsFooter => 'Reports';

  @override
  String get eegUploadTitle => 'EEG Analysis & Classification';

  @override
  String get eegUploadHeader => 'EEG Dataset Upload & AI Classification';

  @override
  String get eegUploadDescription =>
      'Upload EEG data for automatic seizure classification using AI analysis. Supports CSV, TXT, and EDF formats.';

  @override
  String get chooseEegDataset => 'Choose EEG Dataset';

  @override
  String get fileSelected => 'File Selected';

  @override
  String get analyzingEeg => 'Analyzing EEG Data...';

  @override
  String get runningAiModel => 'Running AI classification model';

  @override
  String get classificationResults => 'Classification Results';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get riskHigh => 'High';

  @override
  String get eegPatternsDetected => 'EEG Patterns Detected';

  @override
  String get detailedAnalysis => 'Detailed Analysis';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get recommendedAction => 'Recommended Action';

  @override
  String get medicalDisclaimerTitle => 'Medical Disclaimer';

  @override
  String get medicalDisclaimerText =>
      'This AI analysis is for informational purposes only. Do not rely solely on these results for medical decisions. Always consult with a qualified neurologist for diagnosis and treatment.';

  @override
  String get analysisComplete => 'Analysis complete';

  @override
  String get analysisError => 'Analysis error';

  @override
  String get couldNotParse => 'Error: Could not parse EEG data from file';

  @override
  String get doctorProfile => 'Doctor Profile';

  @override
  String get doctorProfileFooter => 'Doctor Profile';

  @override
  String get neurologist => 'Neurologist';

  @override
  String get doctorId => 'Doctor ID';

  @override
  String get phone => 'Phone';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get passwordChanged => 'Password updated successfully';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get updatingPassword => 'Updating Password...';

  @override
  String get allPasswordFieldsRequired => 'All password fields are required';

  @override
  String get newPasswordMismatch => 'New passwords do not match';

  @override
  String get errorResettingPassword => 'Error resetting password';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get accountCoreCredentials => 'Account Core Credentials';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile details updated successfully!';

  @override
  String get profileUpdateFailed => 'Failed to update profile.';

  @override
  String get emptyFieldsWarning =>
      'All fields are empty. Please enter at least one detail to update.';

  @override
  String get allNotifications => 'All Notifications';

  @override
  String get allNotificationsDesc => 'Enable or disable all app notifications';

  @override
  String get alertPreferences => 'Alert Preferences';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get emailNotificationsDesc =>
      'Receive email notifications for important updates';

  @override
  String get appointmentAlerts => 'Appointment Notifications';

  @override
  String get appointmentAlertsDesc => 'Receive appointment scheduling alerts';

  @override
  String get reminderAlerts => 'Reminder Notifications';

  @override
  String get reminderAlertsDesc => 'Receive medication and task reminders';

  @override
  String get saveNotifications => 'Save Settings';

  @override
  String get savingNotifications => 'Saving Settings...';

  @override
  String get notificationsSaved =>
      'Notification settings saved to database successfully!';

  @override
  String get notificationsSaveError => 'Error saving notification settings';

  @override
  String get accountSecurity => 'Account Security';

  @override
  String get accountSecurityDesc =>
      'Your medical data is protected with secure access controls.';

  @override
  String get securityPreferences => 'Security Preferences';

  @override
  String get profileVisibility => 'Profile Visibility';

  @override
  String get profileVisibilityDesc =>
      'Control who can view your doctor profile';

  @override
  String get shareActivity => 'Share Activity';

  @override
  String get shareActivityDesc =>
      'Share your clinical activity with colleagues';

  @override
  String get allowMessages => 'Allow Messages';

  @override
  String get allowMessagesDesc => 'Allow patients to send you direct messages';

  @override
  String get appLock => 'App Lock';

  @override
  String get appLockDesc => 'Require authentication when opening the app';

  @override
  String get saveSecuritySettings => 'Save Security Settings';

  @override
  String get savingSecuritySettings => 'Saving Settings...';

  @override
  String get privacySaved => 'Privacy settings saved to database successfully!';

  @override
  String get privacySaveError => 'Error saving privacy settings';

  @override
  String get bluetoothTitle => 'Bluetooth Devices';

  @override
  String get bluetoothStatus => 'Bluetooth Status';

  @override
  String get readyToScan => 'Ready to scan';

  @override
  String get bluetoothDisabled => 'Bluetooth is disabled';

  @override
  String get initializationFailed => 'Initialization failed';

  @override
  String get connectedDevice => 'Connected Device';

  @override
  String get connected => 'Connected';

  @override
  String get pairedDevices => 'Paired Devices';

  @override
  String get availableDevices => 'Available Devices';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get tapToScan => 'Tap \"Scan\" to search for nearby devices';

  @override
  String get startScan => 'Start Scan';

  @override
  String get stopScanning => 'Stop Scanning';

  @override
  String get bluetoothPermissionRequired => 'Bluetooth permissions required';

  @override
  String get enableBluetooth => 'Please enable Bluetooth';

  @override
  String connectedTo(String device) {
    return 'Connected to $device';
  }

  @override
  String get disconnected => 'Disconnected';

  @override
  String get deviceUnpaired => 'Device unpaired';

  @override
  String get initializing => 'Initializing...';

  @override
  String get patientProfileTitle => 'Patient Profile';

  @override
  String get patientProfileFooter => 'Patient Profile';

  @override
  String get patientIdLabelProfile => 'Patient ID';

  @override
  String welcomeBackPatient(String name) {
    return 'Welcome Back, $name 👋';
  }

  @override
  String get stayHealthy => 'Stay healthy and follow your treatment plan.';

  @override
  String get todaysHealthStatus => 'Today\'s Health Status';

  @override
  String get noSeizureRisk =>
      'No seizure risk detected today. Continue taking your medication on time.';

  @override
  String get viewHealthReport => 'View Health Report';

  @override
  String get liveSensors => 'Live Sensors';

  @override
  String get chatWithAi => 'Chat with AI Assistant';

  @override
  String get medicationReminder => 'Medication Reminder';

  @override
  String get healthParameters => 'Health Parameters';

  @override
  String get heartRate => 'Heart Rate';

  @override
  String get temperature => 'Temperature';

  @override
  String get o2Saturation => 'O2 Saturation';

  @override
  String get motion => 'Motion';

  @override
  String get motionLow => 'Low';

  @override
  String get motionActivity => 'Activity';

  @override
  String get viewDetailedSensors => 'View Detailed Sensor Analysis';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get emergencyHelpline => 'Emergency Helpline';

  @override
  String get patientHomeFooter => 'Patients';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersSubtitle =>
      'Manage your medication and appointment reminders.';

  @override
  String get reminderTitle => 'Reminder Title';

  @override
  String get reminderType => 'Reminder Type';

  @override
  String get reminderDate => 'Date';

  @override
  String get reminderTime => 'Time';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get saveReminder => 'Save Reminder';

  @override
  String get medicationType => 'Medication';

  @override
  String get pillType => 'Pill';

  @override
  String get appointmentType => 'Appointment';

  @override
  String get doctorVisitType => 'Doctor Visit';

  @override
  String get noRemindersYet => 'No reminders set yet.';

  @override
  String get addFirstReminder =>
      'Tap \'Add Reminder\' to set your first reminder.';

  @override
  String get viewMedicationTitle => 'Medications';

  @override
  String get patientMedicationsTitle => 'My Medications';

  @override
  String get medicationNameLabel => 'Medicine Name (e.g., Panadol)';

  @override
  String get medicationDoseLabel => 'Dosage Strength (e.g., 500mg, 2 tablets)';

  @override
  String get medicationFrequencyLabel =>
      'Frequency (e.g., Twice Daily, Every 8 Hours)';

  @override
  String get medicationTimingLabel =>
      'Timing (e.g., Before Meals, After Meals)';

  @override
  String get takeWithLabel =>
      'Take With (e.g., Water, Milk - Default is Water)';

  @override
  String get instructionsLabel => 'Clinical Instructions / Special Description';

  @override
  String get savePrescription => 'Save Prescription';

  @override
  String get medicationSaved => 'Medication prescription logged successfully!';

  @override
  String get medicationSaveFailed => 'Failed to save prescription entry.';

  @override
  String get noMedications => 'No medications prescribed yet.';

  @override
  String medicineDose(String dose, String frequency) {
    return 'Dose: $dose • Frequency: $frequency';
  }

  @override
  String get callTitle => 'Emergency Call';

  @override
  String get callPrompt =>
      'Are you sure you want to call the emergency contact?';

  @override
  String get calling => 'Calling...';

  @override
  String get chatbotTitle => 'AI Health Assistant';

  @override
  String get chatbotSubtitle =>
      'Ask me anything about epilepsy, medications, and health.';

  @override
  String get typeMessage => 'Type your message...';

  @override
  String get sendMessage => 'Send';

  @override
  String get chatbotDisclaimer =>
      'This chatbot provides educational information only. Always consult your doctor for medical advice.';

  @override
  String get realtimeSensorTitle => 'Live Sensor Data';

  @override
  String get realtimeSensorSubtitle =>
      'Monitor real-time physiological data from connected sensors.';

  @override
  String get fallDetected => 'FALL DETECTED';

  @override
  String get fallSafe => 'Safe';

  @override
  String get sensorUpdated => 'Updated';

  @override
  String get bpmUnit => 'bpm';

  @override
  String get celsiusUnit => '°C';

  @override
  String get percentUnit => '%';

  @override
  String get healthReportTitle => 'Health Report';

  @override
  String get healthReportSubtitle =>
      'View your latest health report and analysis.';

  @override
  String get healthReportSummary => 'Health Summary';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get medicalHistoryTitle => 'Medical History';

  @override
  String get medicalHistorySubtitle =>
      'Review your complete medical history and past treatments.';

  @override
  String get pastRecords => 'Past Records';

  @override
  String get noHistoryFound => 'No medical history records found.';

  @override
  String get predictionTitle => 'Seizure Prediction';

  @override
  String get predictionSubtitle => 'AI-powered seizure risk assessment';

  @override
  String get seizureStatus => 'Seizure Status';

  @override
  String get predictionConfidence => 'Prediction Confidence';

  @override
  String get predictionTime => 'Prediction Time';

  @override
  String get viewDetails => 'View Details';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get recentSeizureEvents => 'Recent Seizure Events';

  @override
  String get noSeizureEvents => 'No seizure events recorded';

  @override
  String get seizureEventsWillAppear =>
      'Recent seizure events will appear here';

  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get acknowledged => 'Acknowledged';

  @override
  String get acknowledgeSeizureEvent => 'Acknowledge Seizure Event';

  @override
  String get eventAcknowledged => 'Event acknowledged successfully';

  @override
  String get addDoctorNotes => 'Add doctor notes or medication adjustments';

  @override
  String get medicationAlertSent => 'Medication Alert Sent';

  @override
  String get appointmentAlertSent => 'Appointment Alert Sent';

  @override
  String get refresh => 'Refresh';

  @override
  String get historyTitle => 'History';

  @override
  String get historySubtitle => 'View past records and clinical history.';

  @override
  String get exportPdfTitle => 'Export Report as PDF';

  @override
  String get exportPdfSubtitle => 'Generate and download a PDF report.';

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportComplete => 'PDF export completed';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get languageNameEn => 'English';

  @override
  String get languageNameEs => 'Spanish';

  @override
  String get languageNameUr => 'Urdu';

  @override
  String get languageNameAr => 'Arabic';

  @override
  String get languageNameFr => 'French';

  @override
  String get languageNameDe => 'German';

  @override
  String get languageNameTr => 'Turkish';

  @override
  String get languageNameZh => 'Chinese (Simplified)';

  @override
  String languageSwitched(String language) {
    return 'Language changed to $language';
  }

  @override
  String get clinicalStatus_observation => 'Under Observation';

  @override
  String get clinicalStatus_stable => 'Stable';

  @override
  String get clinicalStatus_critical => 'Critical';

  @override
  String get clinicalStatus_urgent => 'Need Urgent Review';

  @override
  String doseFormat(String dose) {
    return 'Dose: $dose';
  }

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String genderAndAge(String gender, String age) {
    return 'Gender: $gender • Age: $age Yrs';
  }

  @override
  String get seizureTypeUnknown => 'Unknown Seizure';

  @override
  String get severityCritical => 'CRITICAL';

  @override
  String get severityHigh => 'HIGH';

  @override
  String get severityMedium => 'MEDIUM';

  @override
  String get severityLow => 'LOW';

  @override
  String get severityLabelCritical => 'Critical';

  @override
  String get severityLabelHigh => 'High';

  @override
  String get severityLabelMedium => 'Medium';

  @override
  String get severityLabelLow => 'Low';

  @override
  String get motionStatusMinimal => 'Minimal';

  @override
  String get motionStatusLow => 'Low';

  @override
  String get motionStatusModerate => 'Moderate';

  @override
  String get motionStatusHigh => 'High';

  @override
  String get heartRateStatusNormal => 'Normal';

  @override
  String get heartRateStatusLow => 'Low';

  @override
  String get heartRateStatusHigh => 'High';

  @override
  String get temperatureStatusNormal => 'Normal';

  @override
  String get temperatureStatusLow => 'Low';

  @override
  String get temperatureStatusHigh => 'High';

  @override
  String labelNgaPrefix(String id) {
    return 'NGA-DR-$id';
  }

  @override
  String labelNgaPatient(String id) {
    return 'NGA-P$id';
  }

  @override
  String get uploadEegFormats => 'Supported formats: CSV, TXT, EDF, DAT';

  @override
  String get analyzeAllPatients => 'Analyze All Patients (Batch)';

  @override
  String get generateEegGraph => 'Generate EEG Graph';

  @override
  String get generatingEegGraph => 'Generating EEG graph...';

  @override
  String get eegGraphFailed => 'Failed to generate graph';

  @override
  String get exportReport => 'Export Report';

  @override
  String get exportBatchReport => 'Export Batch Report';

  @override
  String get reportGenerated => 'Report generated successfully!';

  @override
  String get reportFailed => 'Report generation failed';

  @override
  String get generatingReport => 'Generating report...';

  @override
  String get datasetReview => 'Dataset Review';

  @override
  String multiPatientDataset(int count) {
    return 'Multi-Patient Dataset — $count patients detected';
  }

  @override
  String batchResultsTitle(int count) {
    return 'Batch Results ($count Patients)';
  }

  @override
  String get tableHeaderPatient => '#';

  @override
  String get tableHeaderSeizureType => 'Seizure Type';

  @override
  String get tableHeaderConfidence => 'Confidence';

  @override
  String get tableHeaderRisk => 'Risk';

  @override
  String get tableHeaderRecommendation => 'Recommendation';

  @override
  String get tableHeaderGraph => 'Graph';

  @override
  String batchAnalysisComplete(int count) {
    return 'Batch complete: $count patients analyzed';
  }

  @override
  String get doctorChatbotTitle => 'Advanced Doctor Chatbot';

  @override
  String get doctorChatbotDisclaimer =>
      'CLINICAL DECISION SUPPORT ONLY: All recommendations must be verified against current evidence-based guidelines.';

  @override
  String get doctorChatbotHint => 'Type your clinical query...';

  @override
  String get doctorChatbotWelcome =>
      'Welcome Doctor. I am your Clinical Decision Support AI Assistant. How can I assist you today?';

  @override
  String get quickCommandGenerateReport => 'Generate Report';

  @override
  String get quickCommandExportPdf => 'Export PDF';

  @override
  String get quickCommandMedicationInfo => 'Medication Info';

  @override
  String get quickCommandEegGuidance => 'EEG Guidance';

  @override
  String get quickCommandSafetyGuidelines => 'Safety Guidelines';

  @override
  String get quickCommandPatientHistory => 'Patient History';

  @override
  String get quickCommandDiagnosticWorkup => 'Diagnostic Workup';

  @override
  String get quickCommandComorbidity => 'Comorbidity Management';

  @override
  String get patientUpdateTitle => 'Update Patient File';

  @override
  String get patientUpdateDriveId =>
      'Doctor identity not found. Please log in again.';
}
