import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NeuroGuard AI'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'AI Powered Epileptic Seizure Monitoring System'**
  String get appTagline;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 NeuroGuard AI'**
  String get copyright;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'NeuroGuard AI'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI Powered Epileptic Seizure Monitoring System'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signupPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get signupPrompt;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @chooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose an account'**
  String get chooseAccount;

  /// No description provided for @toContinue.
  ///
  /// In en, this message translates to:
  /// **'to continue to NeuroGuard AI'**
  String get toContinue;

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get useAnotherAccount;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loginSuccess;

  /// No description provided for @roleConfigError.
  ///
  /// In en, this message translates to:
  /// **'Role configuration profile error'**
  String get roleConfigError;

  /// No description provided for @newPrompt.
  ///
  /// In en, this message translates to:
  /// **'New?'**
  String get newPrompt;

  /// No description provided for @registerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerPrompt;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get allFieldsRequired;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server connection failure'**
  String get serverError;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signupButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginPrompt;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender status to proceed.'**
  String get selectGender;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8+ characters with uppercase, lowercase, number, and special character'**
  String get invalidPassword;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get signupSuccess;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get signupFailed;

  /// No description provided for @doctorRole.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorRole;

  /// No description provided for @patientRole.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientRole;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @maleGender.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleGender;

  /// No description provided for @femaleGender.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleGender;

  /// No description provided for @otherGender.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherGender;

  /// No description provided for @doctorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Doctor Dashboard'**
  String get doctorDashboard;

  /// No description provided for @patientDashboard.
  ///
  /// In en, this message translates to:
  /// **'Patient Dashboard'**
  String get patientDashboard;

  /// No description provided for @bluetoothDevices.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Devices'**
  String get bluetoothDevices;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @homeNav.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNav;

  /// No description provided for @patientsNav.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsNav;

  /// No description provided for @reportsNav.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsNav;

  /// No description provided for @profileNav.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileNav;

  /// No description provided for @remindersNav.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersNav;

  /// No description provided for @dashboardNav.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardNav;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Logout Confirmation'**
  String get logoutConfirmation;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your profile?'**
  String get logoutMessage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back, {name}'**
  String welcomeBack(String name);

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor patients and AI seizure predictions'**
  String get welcomeSubtitle;

  /// No description provided for @todaysOverview.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Overview'**
  String get todaysOverview;

  /// No description provided for @overviewDescription.
  ///
  /// In en, this message translates to:
  /// **'NeuroGuard AI continuously monitors EEG reports and emergency alerts in real time.'**
  String get overviewDescription;

  /// No description provided for @viewAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'View AI Analysis'**
  String get viewAiAnalysis;

  /// No description provided for @patientsStat.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsStat;

  /// No description provided for @eegReportsStat.
  ///
  /// In en, this message translates to:
  /// **'EEG Reports'**
  String get eegReportsStat;

  /// No description provided for @emergencyStat.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyStat;

  /// No description provided for @aiAccuracyStat.
  ///
  /// In en, this message translates to:
  /// **'AI Accuracy'**
  String get aiAccuracyStat;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @aiPrediction.
  ///
  /// In en, this message translates to:
  /// **'AI Prediction'**
  String get aiPrediction;

  /// No description provided for @aiPredictionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No high-risk seizure predicted in the next few hours.'**
  String get aiPredictionSubtitle;

  /// No description provided for @todaysAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Analysis'**
  String get todaysAnalysis;

  /// No description provided for @todaysAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'12 EEG reports processed successfully.'**
  String get todaysAnalysisSubtitle;

  /// No description provided for @emergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alerts'**
  String get emergencyAlerts;

  /// No description provided for @emergencyAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 patient requires immediate review.} other{{count} patients require immediate review.}}'**
  String emergencyAlertsSubtitle(int count);

  /// No description provided for @loadingAlerts.
  ///
  /// In en, this message translates to:
  /// **'Loading alerts...'**
  String get loadingAlerts;

  /// No description provided for @recentPatients.
  ///
  /// In en, this message translates to:
  /// **'Recent Patients'**
  String get recentPatients;

  /// No description provided for @noPatientsYet.
  ///
  /// In en, this message translates to:
  /// **'No patients registered yet.'**
  String get noPatientsYet;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @uploadEeg.
  ///
  /// In en, this message translates to:
  /// **'Upload EEG'**
  String get uploadEeg;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @prescribeMedication.
  ///
  /// In en, this message translates to:
  /// **'Prescribe Medication'**
  String get prescribeMedication;

  /// No description provided for @noMedicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No medications prescribed yet.'**
  String get noMedicationsYet;

  /// No description provided for @noMedicationsLogged.
  ///
  /// In en, this message translates to:
  /// **'No prescribed medications logged for this patient.'**
  String get noMedicationsLogged;

  /// No description provided for @patientList.
  ///
  /// In en, this message translates to:
  /// **'Patient List'**
  String get patientList;

  /// No description provided for @noPatientsMatch.
  ///
  /// In en, this message translates to:
  /// **'No patient records match your criteria.'**
  String get noPatientsMatch;

  /// No description provided for @patientStatistics.
  ///
  /// In en, this message translates to:
  /// **'Patient Statistics'**
  String get patientStatistics;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @generalReview.
  ///
  /// In en, this message translates to:
  /// **'General Review'**
  String get generalReview;

  /// No description provided for @needUrgentReview.
  ///
  /// In en, this message translates to:
  /// **'Need Urgent Review'**
  String get needUrgentReview;

  /// No description provided for @emergencyAlert.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alert'**
  String get emergencyAlert;

  /// No description provided for @observationRequired.
  ///
  /// In en, this message translates to:
  /// **'Observation Required'**
  String get observationRequired;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @updatePatient.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updatePatient;

  /// No description provided for @searchPatient.
  ///
  /// In en, this message translates to:
  /// **'Search Patient'**
  String get searchPatient;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'Age: {age}'**
  String ageYears(String age);

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @statusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get statusStable;

  /// No description provided for @statusEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get statusEmergency;

  /// No description provided for @statusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get statusCritical;

  /// No description provided for @statusObservation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get statusObservation;

  /// No description provided for @managePatients.
  ///
  /// In en, this message translates to:
  /// **'Manage, monitor and review all registered patients.'**
  String get managePatients;

  /// No description provided for @registerNewPatient.
  ///
  /// In en, this message translates to:
  /// **'Register New Patient'**
  String get registerNewPatient;

  /// No description provided for @patientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient ID (e.g. 01, 02)'**
  String get patientIdLabel;

  /// No description provided for @medicalConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical Condition Status'**
  String get medicalConditionLabel;

  /// No description provided for @lastEegInfo.
  ///
  /// In en, this message translates to:
  /// **'Last EEG Info (e.g. today, last month)'**
  String get lastEegInfo;

  /// No description provided for @lastEegInfoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last EEG Info Update (e.g. today, last month)'**
  String get lastEegInfoUpdate;

  /// No description provided for @emailHintPatient.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailHintPatient;

  /// No description provided for @phoneHintPatient.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneHintPatient;

  /// No description provided for @residentialAddress.
  ///
  /// In en, this message translates to:
  /// **'Residential Address'**
  String get residentialAddress;

  /// No description provided for @emergencyContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Number'**
  String get emergencyContactNumber;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes / History'**
  String get additionalNotes;

  /// No description provided for @savePatientProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Patient Profile'**
  String get savePatientProfile;

  /// No description provided for @updatePatientFile.
  ///
  /// In en, this message translates to:
  /// **'Update Patient File'**
  String get updatePatientFile;

  /// No description provided for @targetPatientId.
  ///
  /// In en, this message translates to:
  /// **'Target Patient ID (Locate File)'**
  String get targetPatientId;

  /// No description provided for @updateInstructions.
  ///
  /// In en, this message translates to:
  /// **'Fill only fields you wish to modify. Leaving fields blank leaves previous logs unchanged.'**
  String get updateInstructions;

  /// No description provided for @commitProfileUpdates.
  ///
  /// In en, this message translates to:
  /// **'Commit Profile Updates'**
  String get commitProfileUpdates;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to register patient'**
  String get registerFailed;

  /// No description provided for @selectCondition.
  ///
  /// In en, this message translates to:
  /// **'Please select a medical condition status value.'**
  String get selectCondition;

  /// No description provided for @providePatientId.
  ///
  /// In en, this message translates to:
  /// **'Please provide a Target Patient ID to identify the file.'**
  String get providePatientId;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @patientRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Status'**
  String get patientRecordTitle;

  /// No description provided for @patientFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient File: {id}'**
  String patientFileTitle(String id);

  /// No description provided for @clinicalStatus.
  ///
  /// In en, this message translates to:
  /// **'Clinical Status'**
  String get clinicalStatus;

  /// No description provided for @medicalConditionDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Medical Condition/Diagnostic Tag'**
  String get medicalConditionDiagnostic;

  /// No description provided for @noConditionFlagged.
  ///
  /// In en, this message translates to:
  /// **'No condition flagged'**
  String get noConditionFlagged;

  /// No description provided for @latestEegAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Latest EEG Analysis Summary'**
  String get latestEegAnalysis;

  /// No description provided for @noEegRecorded.
  ///
  /// In en, this message translates to:
  /// **'No EEG tracking profile recorded yet.'**
  String get noEegRecorded;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @emailNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get emailNotProvided;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @emergencySosContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS Contact'**
  String get emergencySosContact;

  /// No description provided for @activeMedications.
  ///
  /// In en, this message translates to:
  /// **'Active Medications'**
  String get activeMedications;

  /// No description provided for @confidentialClinicalFile.
  ///
  /// In en, this message translates to:
  /// **'NeuroGuard AI • Confidential Clinical File'**
  String get confidentialClinicalFile;

  /// No description provided for @doseLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get doseLabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyLabel;

  /// No description provided for @timingLabel.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timingLabel;

  /// No description provided for @asDirected.
  ///
  /// In en, this message translates to:
  /// **'As directed'**
  String get asDirected;

  /// No description provided for @reportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'EEG Reports'**
  String get reportSectionTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review uploaded EEG reports and AI-generated analysis.'**
  String get reportSubtitle;

  /// No description provided for @aiReportAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Report Analysis'**
  String get aiReportAnalysis;

  /// No description provided for @uploadEegPrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload an EEG report to receive seizure prediction and AI-powered neurological insights.'**
  String get uploadEegPrompt;

  /// No description provided for @uploadEegButton.
  ///
  /// In en, this message translates to:
  /// **'Upload EEG Report'**
  String get uploadEegButton;

  /// No description provided for @recentReports.
  ///
  /// In en, this message translates to:
  /// **'Recent Reports'**
  String get recentReports;

  /// No description provided for @aiStatistics.
  ///
  /// In en, this message translates to:
  /// **'AI Statistics'**
  String get aiStatistics;

  /// No description provided for @reportsProcessed.
  ///
  /// In en, this message translates to:
  /// **'Reports Processed'**
  String get reportsProcessed;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @reportStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get reportStatusNormal;

  /// No description provided for @reportStatusObservation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get reportStatusObservation;

  /// No description provided for @reportStatusEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get reportStatusEmergency;

  /// No description provided for @reportsFooter.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsFooter;

  /// No description provided for @eegUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'EEG Analysis & Classification'**
  String get eegUploadTitle;

  /// No description provided for @eegUploadHeader.
  ///
  /// In en, this message translates to:
  /// **'EEG Dataset Upload & AI Classification'**
  String get eegUploadHeader;

  /// No description provided for @eegUploadDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload EEG data for automatic seizure classification using AI analysis. Supports CSV, TXT, and EDF formats.'**
  String get eegUploadDescription;

  /// No description provided for @chooseEegDataset.
  ///
  /// In en, this message translates to:
  /// **'Choose EEG Dataset'**
  String get chooseEegDataset;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'File Selected'**
  String get fileSelected;

  /// No description provided for @analyzingEeg.
  ///
  /// In en, this message translates to:
  /// **'Analyzing EEG Data...'**
  String get analyzingEeg;

  /// No description provided for @runningAiModel.
  ///
  /// In en, this message translates to:
  /// **'Running AI classification model'**
  String get runningAiModel;

  /// No description provided for @classificationResults.
  ///
  /// In en, this message translates to:
  /// **'Classification Results'**
  String get classificationResults;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get riskHigh;

  /// No description provided for @eegPatternsDetected.
  ///
  /// In en, this message translates to:
  /// **'EEG Patterns Detected'**
  String get eegPatternsDetected;

  /// No description provided for @detailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get detailedAnalysis;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @recommendedAction.
  ///
  /// In en, this message translates to:
  /// **'Recommended Action'**
  String get recommendedAction;

  /// No description provided for @medicalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get medicalDisclaimerTitle;

  /// No description provided for @medicalDisclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This AI analysis is for informational purposes only. Do not rely solely on these results for medical decisions. Always consult with a qualified neurologist for diagnosis and treatment.'**
  String get medicalDisclaimerText;

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete'**
  String get analysisComplete;

  /// No description provided for @analysisError.
  ///
  /// In en, this message translates to:
  /// **'Analysis error'**
  String get analysisError;

  /// No description provided for @couldNotParse.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not parse EEG data from file'**
  String get couldNotParse;

  /// No description provided for @doctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Doctor Profile'**
  String get doctorProfile;

  /// No description provided for @doctorProfileFooter.
  ///
  /// In en, this message translates to:
  /// **'Doctor Profile'**
  String get doctorProfileFooter;

  /// No description provided for @neurologist.
  ///
  /// In en, this message translates to:
  /// **'Neurologist'**
  String get neurologist;

  /// No description provided for @doctorId.
  ///
  /// In en, this message translates to:
  /// **'Doctor ID'**
  String get doctorId;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordChanged;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @updatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Updating Password...'**
  String get updatingPassword;

  /// No description provided for @allPasswordFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All password fields are required'**
  String get allPasswordFieldsRequired;

  /// No description provided for @newPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordMismatch;

  /// No description provided for @errorResettingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error resetting password'**
  String get errorResettingPassword;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @accountCoreCredentials.
  ///
  /// In en, this message translates to:
  /// **'Account Core Credentials'**
  String get accountCoreCredentials;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile details updated successfully!'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get profileUpdateFailed;

  /// No description provided for @emptyFieldsWarning.
  ///
  /// In en, this message translates to:
  /// **'All fields are empty. Please enter at least one detail to update.'**
  String get emptyFieldsWarning;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @allNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable all app notifications'**
  String get allNotificationsDesc;

  /// No description provided for @alertPreferences.
  ///
  /// In en, this message translates to:
  /// **'Alert Preferences'**
  String get alertPreferences;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive email notifications for important updates'**
  String get emailNotificationsDesc;

  /// No description provided for @appointmentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Appointment Notifications'**
  String get appointmentAlerts;

  /// No description provided for @appointmentAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive appointment scheduling alerts'**
  String get appointmentAlertsDesc;

  /// No description provided for @reminderAlerts.
  ///
  /// In en, this message translates to:
  /// **'Reminder Notifications'**
  String get reminderAlerts;

  /// No description provided for @reminderAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive medication and task reminders'**
  String get reminderAlertsDesc;

  /// No description provided for @saveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveNotifications;

  /// No description provided for @savingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Saving Settings...'**
  String get savingNotifications;

  /// No description provided for @notificationsSaved.
  ///
  /// In en, this message translates to:
  /// **'Notification settings saved to database successfully!'**
  String get notificationsSaved;

  /// No description provided for @notificationsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving notification settings'**
  String get notificationsSaveError;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @accountSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Your medical data is protected with secure access controls.'**
  String get accountSecurityDesc;

  /// No description provided for @securityPreferences.
  ///
  /// In en, this message translates to:
  /// **'Security Preferences'**
  String get securityPreferences;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get profileVisibility;

  /// No description provided for @profileVisibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Control who can view your doctor profile'**
  String get profileVisibilityDesc;

  /// No description provided for @shareActivity.
  ///
  /// In en, this message translates to:
  /// **'Share Activity'**
  String get shareActivity;

  /// No description provided for @shareActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your clinical activity with colleagues'**
  String get shareActivityDesc;

  /// No description provided for @allowMessages.
  ///
  /// In en, this message translates to:
  /// **'Allow Messages'**
  String get allowMessages;

  /// No description provided for @allowMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow patients to send you direct messages'**
  String get allowMessagesDesc;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockDesc.
  ///
  /// In en, this message translates to:
  /// **'Require authentication when opening the app'**
  String get appLockDesc;

  /// No description provided for @saveSecuritySettings.
  ///
  /// In en, this message translates to:
  /// **'Save Security Settings'**
  String get saveSecuritySettings;

  /// No description provided for @savingSecuritySettings.
  ///
  /// In en, this message translates to:
  /// **'Saving Settings...'**
  String get savingSecuritySettings;

  /// No description provided for @privacySaved.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings saved to database successfully!'**
  String get privacySaved;

  /// No description provided for @privacySaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving privacy settings'**
  String get privacySaveError;

  /// No description provided for @bluetoothTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Devices'**
  String get bluetoothTitle;

  /// No description provided for @bluetoothStatus.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Status'**
  String get bluetoothStatus;

  /// No description provided for @readyToScan.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get readyToScan;

  /// No description provided for @bluetoothDisabled.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is disabled'**
  String get bluetoothDisabled;

  /// No description provided for @initializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get initializationFailed;

  /// No description provided for @connectedDevice.
  ///
  /// In en, this message translates to:
  /// **'Connected Device'**
  String get connectedDevice;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @pairedDevices.
  ///
  /// In en, this message translates to:
  /// **'Paired Devices'**
  String get pairedDevices;

  /// No description provided for @availableDevices.
  ///
  /// In en, this message translates to:
  /// **'Available Devices'**
  String get availableDevices;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// No description provided for @tapToScan.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Scan\" to search for nearby devices'**
  String get tapToScan;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get startScan;

  /// No description provided for @stopScanning.
  ///
  /// In en, this message translates to:
  /// **'Stop Scanning'**
  String get stopScanning;

  /// No description provided for @bluetoothPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permissions required'**
  String get bluetoothPermissionRequired;

  /// No description provided for @enableBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth'**
  String get enableBluetooth;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {device}'**
  String connectedTo(String device);

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @deviceUnpaired.
  ///
  /// In en, this message translates to:
  /// **'Device unpaired'**
  String get deviceUnpaired;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @patientProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Profile'**
  String get patientProfileTitle;

  /// No description provided for @patientProfileFooter.
  ///
  /// In en, this message translates to:
  /// **'Patient Profile'**
  String get patientProfileFooter;

  /// No description provided for @patientIdLabelProfile.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get patientIdLabelProfile;

  /// No description provided for @welcomeBackPatient.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back, {name} 👋'**
  String welcomeBackPatient(String name);

  /// No description provided for @stayHealthy.
  ///
  /// In en, this message translates to:
  /// **'Stay healthy and follow your treatment plan.'**
  String get stayHealthy;

  /// No description provided for @todaysHealthStatus.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Health Status'**
  String get todaysHealthStatus;

  /// No description provided for @noSeizureRisk.
  ///
  /// In en, this message translates to:
  /// **'No seizure risk detected today. Continue taking your medication on time.'**
  String get noSeizureRisk;

  /// No description provided for @viewHealthReport.
  ///
  /// In en, this message translates to:
  /// **'View Health Report'**
  String get viewHealthReport;

  /// No description provided for @liveSensors.
  ///
  /// In en, this message translates to:
  /// **'Live Sensors'**
  String get liveSensors;

  /// No description provided for @chatWithAi.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI Assistant'**
  String get chatWithAi;

  /// No description provided for @medicationReminder.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get medicationReminder;

  /// No description provided for @healthParameters.
  ///
  /// In en, this message translates to:
  /// **'Health Parameters'**
  String get healthParameters;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @o2Saturation.
  ///
  /// In en, this message translates to:
  /// **'O2 Saturation'**
  String get o2Saturation;

  /// No description provided for @motion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get motion;

  /// No description provided for @motionLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get motionLow;

  /// No description provided for @motionActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get motionActivity;

  /// No description provided for @viewDetailedSensors.
  ///
  /// In en, this message translates to:
  /// **'View Detailed Sensor Analysis'**
  String get viewDetailedSensors;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @emergencyHelpline.
  ///
  /// In en, this message translates to:
  /// **'Emergency Helpline'**
  String get emergencyHelpline;

  /// No description provided for @patientHomeFooter.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientHomeFooter;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your medication and appointment reminders.'**
  String get remindersSubtitle;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Title'**
  String get reminderTitle;

  /// No description provided for @reminderType.
  ///
  /// In en, this message translates to:
  /// **'Reminder Type'**
  String get reminderType;

  /// No description provided for @reminderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reminderDate;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminder;

  /// No description provided for @medicationType.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medicationType;

  /// No description provided for @pillType.
  ///
  /// In en, this message translates to:
  /// **'Pill'**
  String get pillType;

  /// No description provided for @appointmentType.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentType;

  /// No description provided for @doctorVisitType.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visit'**
  String get doctorVisitType;

  /// No description provided for @noRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders set yet.'**
  String get noRemindersYet;

  /// No description provided for @addFirstReminder.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Add Reminder\' to set your first reminder.'**
  String get addFirstReminder;

  /// No description provided for @viewMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get viewMedicationTitle;

  /// No description provided for @patientMedicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Medications'**
  String get patientMedicationsTitle;

  /// No description provided for @medicationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name (e.g., Panadol)'**
  String get medicationNameLabel;

  /// No description provided for @medicationDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage Strength (e.g., 500mg, 2 tablets)'**
  String get medicationDoseLabel;

  /// No description provided for @medicationFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency (e.g., Twice Daily, Every 8 Hours)'**
  String get medicationFrequencyLabel;

  /// No description provided for @medicationTimingLabel.
  ///
  /// In en, this message translates to:
  /// **'Timing (e.g., Before Meals, After Meals)'**
  String get medicationTimingLabel;

  /// No description provided for @takeWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Take With (e.g., Water, Milk - Default is Water)'**
  String get takeWithLabel;

  /// No description provided for @instructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinical Instructions / Special Description'**
  String get instructionsLabel;

  /// No description provided for @savePrescription.
  ///
  /// In en, this message translates to:
  /// **'Save Prescription'**
  String get savePrescription;

  /// No description provided for @medicationSaved.
  ///
  /// In en, this message translates to:
  /// **'Medication prescription logged successfully!'**
  String get medicationSaved;

  /// No description provided for @medicationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save prescription entry.'**
  String get medicationSaveFailed;

  /// No description provided for @noMedications.
  ///
  /// In en, this message translates to:
  /// **'No medications prescribed yet.'**
  String get noMedications;

  /// No description provided for @medicineDose.
  ///
  /// In en, this message translates to:
  /// **'Dose: {dose} • Frequency: {frequency}'**
  String medicineDose(String dose, String frequency);

  /// No description provided for @callTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Call'**
  String get callTitle;

  /// No description provided for @callPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to call the emergency contact?'**
  String get callPrompt;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get calling;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Health Assistant'**
  String get chatbotTitle;

  /// No description provided for @chatbotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about epilepsy, medications, and health.'**
  String get chatbotSubtitle;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @chatbotDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This chatbot provides educational information only. Always consult your doctor for medical advice.'**
  String get chatbotDisclaimer;

  /// No description provided for @realtimeSensorTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Sensor Data'**
  String get realtimeSensorTitle;

  /// No description provided for @realtimeSensorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor real-time physiological data from connected sensors.'**
  String get realtimeSensorSubtitle;

  /// No description provided for @fallDetected.
  ///
  /// In en, this message translates to:
  /// **'FALL DETECTED'**
  String get fallDetected;

  /// No description provided for @fallSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get fallSafe;

  /// No description provided for @sensorUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get sensorUpdated;

  /// No description provided for @bpmUnit.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get bpmUnit;

  /// No description provided for @celsiusUnit.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsiusUnit;

  /// No description provided for @percentUnit.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percentUnit;

  /// No description provided for @healthReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Report'**
  String get healthReportTitle;

  /// No description provided for @healthReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your latest health report and analysis.'**
  String get healthReportSubtitle;

  /// No description provided for @healthReportSummary.
  ///
  /// In en, this message translates to:
  /// **'Health Summary'**
  String get healthReportSummary;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @medicalHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistoryTitle;

  /// No description provided for @medicalHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your complete medical history and past treatments.'**
  String get medicalHistorySubtitle;

  /// No description provided for @pastRecords.
  ///
  /// In en, this message translates to:
  /// **'Past Records'**
  String get pastRecords;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No medical history records found.'**
  String get noHistoryFound;

  /// No description provided for @predictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Seizure Prediction'**
  String get predictionTitle;

  /// No description provided for @predictionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered seizure risk assessment'**
  String get predictionSubtitle;

  /// No description provided for @seizureStatus.
  ///
  /// In en, this message translates to:
  /// **'Seizure Status'**
  String get seizureStatus;

  /// No description provided for @predictionConfidence.
  ///
  /// In en, this message translates to:
  /// **'Prediction Confidence'**
  String get predictionConfidence;

  /// No description provided for @predictionTime.
  ///
  /// In en, this message translates to:
  /// **'Prediction Time'**
  String get predictionTime;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @recentSeizureEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent Seizure Events'**
  String get recentSeizureEvents;

  /// No description provided for @noSeizureEvents.
  ///
  /// In en, this message translates to:
  /// **'No seizure events recorded'**
  String get noSeizureEvents;

  /// No description provided for @seizureEventsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Recent seizure events will appear here'**
  String get seizureEventsWillAppear;

  /// No description provided for @acknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledge;

  /// No description provided for @acknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get acknowledged;

  /// No description provided for @acknowledgeSeizureEvent.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge Seizure Event'**
  String get acknowledgeSeizureEvent;

  /// No description provided for @eventAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Event acknowledged successfully'**
  String get eventAcknowledged;

  /// No description provided for @addDoctorNotes.
  ///
  /// In en, this message translates to:
  /// **'Add doctor notes or medication adjustments'**
  String get addDoctorNotes;

  /// No description provided for @medicationAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Medication Alert Sent'**
  String get medicationAlertSent;

  /// No description provided for @appointmentAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Appointment Alert Sent'**
  String get appointmentAlertSent;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View past records and clinical history.'**
  String get historySubtitle;

  /// No description provided for @exportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Report as PDF'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate and download a PDF report.'**
  String get exportPdfSubtitle;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'PDF export completed'**
  String get exportComplete;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @languageNameEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// No description provided for @languageNameEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageNameEs;

  /// No description provided for @languageNameUr.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageNameUr;

  /// No description provided for @languageNameAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageNameAr;

  /// No description provided for @languageNameFr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageNameFr;

  /// No description provided for @languageNameDe.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageNameDe;

  /// No description provided for @languageNameTr.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageNameTr;

  /// No description provided for @languageNameZh.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get languageNameZh;

  /// No description provided for @languageSwitched.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageSwitched(String language);

  /// No description provided for @clinicalStatus_observation.
  ///
  /// In en, this message translates to:
  /// **'Under Observation'**
  String get clinicalStatus_observation;

  /// No description provided for @clinicalStatus_stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get clinicalStatus_stable;

  /// No description provided for @clinicalStatus_critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get clinicalStatus_critical;

  /// No description provided for @clinicalStatus_urgent.
  ///
  /// In en, this message translates to:
  /// **'Need Urgent Review'**
  String get clinicalStatus_urgent;

  /// No description provided for @doseFormat.
  ///
  /// In en, this message translates to:
  /// **'Dose: {dose}'**
  String doseFormat(String dose);

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderAndAge.
  ///
  /// In en, this message translates to:
  /// **'Gender: {gender} • Age: {age} Yrs'**
  String genderAndAge(String gender, String age);

  /// No description provided for @seizureTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Seizure'**
  String get seizureTypeUnknown;

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get severityCritical;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get severityHigh;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get severityMedium;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get severityLow;

  /// No description provided for @severityLabelCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityLabelCritical;

  /// No description provided for @severityLabelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityLabelHigh;

  /// No description provided for @severityLabelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get severityLabelMedium;

  /// No description provided for @severityLabelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLabelLow;

  /// No description provided for @motionStatusMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get motionStatusMinimal;

  /// No description provided for @motionStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get motionStatusLow;

  /// No description provided for @motionStatusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get motionStatusModerate;

  /// No description provided for @motionStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get motionStatusHigh;

  /// No description provided for @heartRateStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get heartRateStatusNormal;

  /// No description provided for @heartRateStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get heartRateStatusLow;

  /// No description provided for @heartRateStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get heartRateStatusHigh;

  /// No description provided for @temperatureStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get temperatureStatusNormal;

  /// No description provided for @temperatureStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get temperatureStatusLow;

  /// No description provided for @temperatureStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get temperatureStatusHigh;

  /// No description provided for @labelNgaPrefix.
  ///
  /// In en, this message translates to:
  /// **'NGA-DR-{id}'**
  String labelNgaPrefix(String id);

  /// No description provided for @labelNgaPatient.
  ///
  /// In en, this message translates to:
  /// **'NGA-P{id}'**
  String labelNgaPatient(String id);

  /// No description provided for @uploadEegFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: CSV, TXT, EDF, DAT'**
  String get uploadEegFormats;

  /// No description provided for @analyzeAllPatients.
  ///
  /// In en, this message translates to:
  /// **'Analyze All Patients (Batch)'**
  String get analyzeAllPatients;

  /// No description provided for @generateEegGraph.
  ///
  /// In en, this message translates to:
  /// **'Generate EEG Graph'**
  String get generateEegGraph;

  /// No description provided for @generatingEegGraph.
  ///
  /// In en, this message translates to:
  /// **'Generating EEG graph...'**
  String get generatingEegGraph;

  /// No description provided for @eegGraphFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate graph'**
  String get eegGraphFailed;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @exportBatchReport.
  ///
  /// In en, this message translates to:
  /// **'Export Batch Report'**
  String get exportBatchReport;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully!'**
  String get reportGenerated;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Report generation failed'**
  String get reportFailed;

  /// No description provided for @generatingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get generatingReport;

  /// No description provided for @datasetReview.
  ///
  /// In en, this message translates to:
  /// **'Dataset Review'**
  String get datasetReview;

  /// No description provided for @multiPatientDataset.
  ///
  /// In en, this message translates to:
  /// **'Multi-Patient Dataset — {count} patients detected'**
  String multiPatientDataset(int count);

  /// No description provided for @batchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch Results ({count} Patients)'**
  String batchResultsTitle(int count);

  /// No description provided for @tableHeaderPatient.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get tableHeaderPatient;

  /// No description provided for @tableHeaderSeizureType.
  ///
  /// In en, this message translates to:
  /// **'Seizure Type'**
  String get tableHeaderSeizureType;

  /// No description provided for @tableHeaderConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get tableHeaderConfidence;

  /// No description provided for @tableHeaderRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get tableHeaderRisk;

  /// No description provided for @tableHeaderRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get tableHeaderRecommendation;

  /// No description provided for @tableHeaderGraph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get tableHeaderGraph;

  /// No description provided for @batchAnalysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Batch complete: {count} patients analyzed'**
  String batchAnalysisComplete(int count);

  /// No description provided for @doctorChatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Doctor Chatbot'**
  String get doctorChatbotTitle;

  /// No description provided for @doctorChatbotDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL DECISION SUPPORT ONLY: All recommendations must be verified against current evidence-based guidelines.'**
  String get doctorChatbotDisclaimer;

  /// No description provided for @doctorChatbotHint.
  ///
  /// In en, this message translates to:
  /// **'Type your clinical query...'**
  String get doctorChatbotHint;

  /// No description provided for @doctorChatbotWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Doctor. I am your Clinical Decision Support AI Assistant. How can I assist you today?'**
  String get doctorChatbotWelcome;

  /// No description provided for @quickCommandGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get quickCommandGenerateReport;

  /// No description provided for @quickCommandExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get quickCommandExportPdf;

  /// No description provided for @quickCommandMedicationInfo.
  ///
  /// In en, this message translates to:
  /// **'Medication Info'**
  String get quickCommandMedicationInfo;

  /// No description provided for @quickCommandEegGuidance.
  ///
  /// In en, this message translates to:
  /// **'EEG Guidance'**
  String get quickCommandEegGuidance;

  /// No description provided for @quickCommandSafetyGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Safety Guidelines'**
  String get quickCommandSafetyGuidelines;

  /// No description provided for @quickCommandPatientHistory.
  ///
  /// In en, this message translates to:
  /// **'Patient History'**
  String get quickCommandPatientHistory;

  /// No description provided for @quickCommandDiagnosticWorkup.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Workup'**
  String get quickCommandDiagnosticWorkup;

  /// No description provided for @quickCommandComorbidity.
  ///
  /// In en, this message translates to:
  /// **'Comorbidity Management'**
  String get quickCommandComorbidity;

  /// No description provided for @patientUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Patient File'**
  String get patientUpdateTitle;

  /// No description provided for @patientUpdateDriveId.
  ///
  /// In en, this message translates to:
  /// **'Doctor identity not found. Please log in again.'**
  String get patientUpdateDriveId;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
