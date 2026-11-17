
class ClinicalReport {
  final String reportType;
  final String patientName;
  final String patientId;
  final DateTime reportDate;
  final String physicianName;
  final String reportContent;
  final Map<String, dynamic> patientData;
  final Map<String, dynamic>? seizureAnalysis;
  final Map<String, dynamic>? sensorData;

  ClinicalReport({
    required this.reportType,
    required this.patientName,
    required this.patientId,
    required this.reportDate,
    required this.physicianName,
    required this.reportContent,
    required this.patientData,
    this.seizureAnalysis,
    this.sensorData,
  });

  String toFormattedText() {
    return '''
═══════════════════════════════════════════════════════════
                    CLINICAL REPORT
═══════════════════════════════════════════════════════════

Report Type: $reportType
Date: ${reportDate.toString().split(' ')[0]}
Time: ${reportDate.toString().split(' ')[1].substring(0, 5)}

───────────────────────────────────────────────────────────
PATIENT INFORMATION
───────────────────────────────────────────────────────────
Name: $patientName
Patient ID: $patientId
Age: ${patientData['age'] ?? 'N/A'}
Gender: ${patientData['gender'] ?? 'N/A'}
DOB: ${patientData['dob'] ?? 'N/A'}

───────────────────────────────────────────────────────────
PHYSICIAN INFORMATION
───────────────────────────────────────────────────────────
Name: $physicianName
License #: ${patientData['physician_license'] ?? 'N/A'}

───────────────────────────────────────────────────────────
CLINICAL REPORT
───────────────────────────────────────────────────────────
$reportContent

${seizureAnalysis != null ? _formatSeizureAnalysis(seizureAnalysis!) : ''}

${sensorData != null ? _formatSensorData(sensorData!) : ''}

───────────────────────────────────────────────────────────
RECOMMENDATIONS
───────────────────────────────────────────────────────────
1. Continue current medication regimen with adherence monitoring
2. Follow-up EEG in 3-6 months or sooner if clinical change
3. Encourage lifestyle modifications and seizure precautions
4. Screen for comorbid depression/anxiety
5. Consider neurology specialist referral if poor seizure control

───────────────────────────────────────────────────────────
PATIENT INSTRUCTIONS
───────────────────────────────────────────────────────────
✓ Take medications exactly as prescribed
✓ Report breakthrough seizures immediately
✓ Avoid seizure triggers (sleep deprivation, stress, etc.)
✓ Maintain seizure diary
✓ Schedule follow-up appointment
✓ Seek emergency care for status epilepticus or head injury

───────────────────────────────────────────────────────────
EMERGENCY PROTOCOLS
───────────────────────────────────────────────────────────
If seizure lasts > 5 minutes → Call 911
If multiple seizures in short period → Emergency evaluation needed
If loss of consciousness > 30 minutes → Seek immediate care

═══════════════════════════════════════════════════════════
                    END OF REPORT
═══════════════════════════════════════════════════════════

Physician Signature: ________________________
Date: ${reportDate.toString().split(' ')[0]}

This report is confidential and intended for medical use only.
''';
  }

  String _formatSeizureAnalysis(Map<String, dynamic> analysis) {
    return '''

───────────────────────────────────────────────────────────
SEIZURE ANALYSIS
───────────────────────────────────────────────────────────
Seizure Type: ${analysis['seizure_type'] ?? 'Unknown'}
Confidence: ${analysis['confidence'] ?? 'N/A'}
Risk Level: ${analysis['risk_level'] ?? 'N/A'}

EEG Patterns Detected:
${(analysis['eeg_patterns'] as List?)?.map((p) => '  • \$p').join('') ?? 'None detected'}

Clinical Assessment:
${analysis['raw_analysis'] ?? 'No additional data available'}
''';
  }

  String _formatSensorData(Map<String, dynamic> data) {
    return '''

───────────────────────────────────────────────────────────
SENSOR DATA SUMMARY
───────────────────────────────────────────────────────────
Heart Rate (avg): ${data['heart_rate'] ?? 'N/A'} bpm
Body Temperature: ${data['body_temperature'] ?? 'N/A'}°C
Motion Level: ${data['motion_level'] ?? 'N/A'}
Fall Detection: ${data['fall_detected'] == true ? 'YES - Immediate follow-up recommended' : 'No'}
Data Source: ${data['data_source'] ?? 'Unknown'}
Last Update: ${data['timestamp'] ?? 'N/A'}
''';
  }
}

class ReportGeneratorService {
  static final ReportGeneratorService _instance =
      ReportGeneratorService._internal();

  factory ReportGeneratorService() {
    return _instance;
  }

  ReportGeneratorService._internal();

  /// Generate a clinical seizure report
  ClinicalReport generateSeizureReport({
    required String patientName,
    required String patientId,
    required String physicianName,
    required Map<String, dynamic> patientData,
    Map<String, dynamic>? seizureAnalysis,
    Map<String, dynamic>? sensorData,
  }) {
    final reportContent = '''
CHIEF COMPLAINT:
Follow-up evaluation for seizure disorder management

HISTORY OF PRESENT ILLNESS:
Patient presents for ongoing management of seizure disorder. Current status:
• Seizure frequency: ${patientData['seizure_frequency'] ?? 'Stable'}
• Last seizure: ${patientData['last_seizure'] ?? 'N/A'}
• Medication adherence: ${patientData['medication_adherence'] ?? 'Good'}
• Quality of life: ${patientData['quality_of_life'] ?? 'Reasonable'}

PAST MEDICAL HISTORY:
• Seizure onset: ${patientData['seizure_onset'] ?? 'Unknown'}
• Previous EEG findings: ${patientData['previous_eeg'] ?? 'Unknown'}
• Previous imaging: ${patientData['previous_imaging'] ?? 'Unknown'}
• Comorbidities: ${patientData['comorbidities'] ?? 'None reported'}

MEDICATIONS:
${_formatMedications(patientData['current_medications'])}

PHYSICAL EXAMINATION:
• Neurological exam: Grossly intact
• Cranial nerves: II-XII intact
• Motor: 5/5 throughout
• Sensory: Intact to all modalities
• Coordination: Normal
• Reflexes: Normal and symmetric

ASSESSMENT:
${patientData['diagnosis'] ?? 'Epilepsy - type to be determined by additional testing'}

PLAN:
1. Continue current antiseizure medications with adherence reinforcement
2. Obtain EEG if not done within last 6 months
3. Patient counseling on seizure safety and SUDEP risk
4. Screen for mood disorders at follow-up
5. Consider adjustment of medications if breakthrough seizures occur
6. Return visit in 3 months or sooner if clinical change
''';

    return ClinicalReport(
      reportType: 'Seizure Analysis & Management Report',
      patientName: patientName,
      patientId: patientId,
      reportDate: DateTime.now(),
      physicianName: physicianName,
      reportContent: reportContent,
      patientData: patientData,
      seizureAnalysis: seizureAnalysis,
      sensorData: sensorData,
    );
  }

  /// Generate a comprehensive health status report
  ClinicalReport generateHealthStatusReport({
    required String patientName,
    required String patientId,
    required String physicianName,
    required Map<String, dynamic> patientData,
    Map<String, dynamic>? sensorData,
  }) {
    final reportContent = '''
OVERVIEW:
Comprehensive health status assessment including current medications, recent
test results, vital signs trends, and clinical observations.

VITAL SIGNS (Latest):
${_formatVitalSigns(sensorData)}

MEDICATION SUMMARY:
${_formatMedications(patientData['current_medications'])}

RECENT TEST RESULTS:
${_formatTestResults(patientData['recent_tests'])}

CLINICAL OBSERVATIONS:
${patientData['clinical_notes'] ?? 'Patient stable on current regimen'}

CURRENT ISSUES:
${_formatActiveIssues(patientData['active_issues'])}

ASSESSMENT:
Overall health status is ${patientData['overall_status'] ?? 'stable'}. Patient
demonstrates good medication adherence and compliance with medical recommendations.

PLAN:
1. Continue current management strategy
2. Monitor for symptom changes
3. Schedule routine follow-up visits as planned
4. Consider additional testing if clinical indication arises
''';

    return ClinicalReport(
      reportType: 'Health Status Summary Report',
      patientName: patientName,
      patientId: patientId,
      reportDate: DateTime.now(),
      physicianName: physicianName,
      reportContent: reportContent,
      patientData: patientData,
      sensorData: sensorData,
    );
  }

  /// Generate a comprehensive patient profile report
  ClinicalReport generatePatientProfileReport({
    required String patientName,
    required String patientId,
    required String physicianName,
    required Map<String, dynamic> patientData,
  }) {
    final reportContent = '''
PATIENT DEMOGRAPHICS:
Name: $patientName
Date of Birth: ${patientData['dob'] ?? 'N/A'}
Age: ${patientData['age'] ?? 'N/A'}
Gender: ${patientData['gender'] ?? 'N/A'}
Contact: ${patientData['contact'] ?? 'N/A'}
Emergency Contact: ${patientData['emergency_contact'] ?? 'N/A'}

MEDICAL HISTORY:
Primary Diagnosis: ${patientData['primary_diagnosis'] ?? 'Seizure Disorder'}
Secondary Diagnoses: ${patientData['secondary_diagnoses'] ?? 'None'}
Surgical History: ${patientData['surgical_history'] ?? 'None'}
Hospitalizations: ${patientData['hospitalizations'] ?? 'None'}

CURRENT MEDICATIONS:
${_formatMedications(patientData['current_medications'])}

ALLERGIES:
${_formatAllergies(patientData['allergies'])}

CONTRAINDICATIONS:
${patientData['contraindications'] ?? 'None documented'}

FAMILY HISTORY:
Epilepsy: ${patientData['family_epilepsy'] ?? 'Unknown'}
Neurological Disorders: ${patientData['family_neuro'] ?? 'Unknown'}
Psychiatric Conditions: ${patientData['family_psych'] ?? 'Unknown'}

SOCIAL HISTORY:
Occupation: ${patientData['occupation'] ?? 'Not specified'}
Education: ${patientData['education'] ?? 'Not specified'}
Living Situation: ${patientData['living_situation'] ?? 'Not specified'}
Support System: ${patientData['support_system'] ?? 'Not specified'}

INSURANCE INFORMATION:
Provider: ${patientData['insurance_provider'] ?? 'Unknown'}
Policy #: ${patientData['policy_number'] ?? 'Unknown'}

PROVIDER TEAM:
Primary Neurologist: $physicianName
Other Specialists: ${patientData['other_specialists'] ?? 'None'}

ASSESSMENT:
Comprehensive patient profile established. All relevant medical, social, and
demographic information documented for coordinated care management.

PLAN:
1. Update patient records with any new information at each visit
2. Maintain current specialist relationships
3. Ensure medication list is reviewed and updated regularly
4. Coordinate care across all providers as needed
''';

    return ClinicalReport(
      reportType: 'Comprehensive Patient Profile',
      patientName: patientName,
      patientId: patientId,
      reportDate: DateTime.now(),
      physicianName: physicianName,
      reportContent: reportContent,
      patientData: patientData,
    );
  }

  /// Generate suggestions for clinical decision making
  String generateClinicalSuggestions(Map<String, dynamic> patientData) {
    List<String> suggestions = [];

    // Seizure frequency suggestions
    final seizureFreq = patientData['seizure_frequency'] as String?;
    if (seizureFreq == 'High' || seizureFreq?.contains('multiple') == true) {
      suggestions.add(
          '⚠️ HIGH SEIZURE FREQUENCY: Consider medication optimization or dose adjustment');
      suggestions.add('   → Review medication adherence');
      suggestions.add('   → Check antiepileptic drug levels if applicable');
      suggestions.add('   → Evaluate for drug interactions');
    }

    // Medication adherence suggestions
    final adherence = patientData['medication_adherence'] as String?;
    if (adherence == 'Poor' || adherence?.contains('poor') == true) {
      suggestions.add('⚠️ ADHERENCE CONCERN: Implement adherence support strategies');
      suggestions.add('   → Discuss barriers to medication taking');
      suggestions.add('   → Consider pill organizers or phone reminders');
      suggestions.add('   → Simplify medication regimen if possible');
    }

    // Comorbidity suggestions
    if (patientData['comorbidities'] != null) {
      suggestions.add('📋 COMORBIDITY MANAGEMENT: Screen for mood/behavioral changes');
      suggestions.add('   → Screen for depression (PHQ-9)');
      suggestions.add('   → Assess for anxiety symptoms');
      suggestions.add('   → Consider psychotherapy referral');
    }

    // Follow-up suggestions
    suggestions.add('✅ ROUTINE RECOMMENDATIONS:');
    suggestions.add('   □ EEG follow-up (if not done within 6-12 months)');
    suggestions.add('   □ Brain imaging if seizure control unchanged after 2+ ASM trials');
    suggestions.add('   □ Neurology specialist referral if drug-resistant epilepsy');
    suggestions.add('   □ SUDEP counseling and safety planning');
    suggestions.add('   □ Bone health screening (if on enzyme-inducing ASMs)');

    // Safety suggestions
    suggestions.add('🔒 PATIENT SAFETY CONSIDERATIONS:');
    suggestions.add('   □ Discuss driving restrictions based on seizure control');
    suggestions.add('   □ Review seizure action plan');
    suggestions.add('   □ Ensure emergency contact list is current');
    suggestions.add('   □ Medical alert ID recommendation');

    return suggestions.join('');
  }

  String _formatMedications(dynamic meds) {
    if (meds == null) return '  • No medications documented';
    if (meds is List) {
      if (meds.isEmpty) return '  • No medications documented';
      return meds
          .map((m) => '  • ${m['name'] ?? 'Unknown'} - ${m['dose'] ?? 'N/A'} '
              '${m['frequency'] ?? 'N/A'} (since ${m['start_date'] ?? 'Unknown'})')
          .join('');
    }
    return '  • $meds';
  }

  String _formatVitalSigns(dynamic data) {
    if (data == null) return '  • No recent vital signs available';
    if (data is Map) {
      return '''  • Heart Rate: ${data['heart_rate'] ?? 'N/A'} bpm
  • Blood Pressure: ${data['blood_pressure'] ?? 'N/A'} mmHg
  • Temperature: ${data['temperature'] ?? 'N/A'}°C
  • Respiratory Rate: ${data['respiratory_rate'] ?? 'N/A'} breaths/min
  • O2 Saturation: ${data['o2_saturation'] ?? 'N/A'}%''';
    }
    return '  • $data';
  }

  String _formatTestResults(dynamic tests) {
    if (tests == null) return '  • No recent test results documented';
    if (tests is List) {
      if (tests.isEmpty) return '  • No recent test results documented';
      return tests.map((t) => '  • ${t['test_name'] ?? 'Unknown'}: ${t['result'] ?? 'N/A'} '
          '(${t['date'] ?? 'Unknown'})').join('');
    }
    return '  • $tests';
  }

  String _formatActiveIssues(dynamic issues) {
    if (issues == null) return '  • No active issues documented';
    if (issues is List) {
      if (issues.isEmpty) return '  • No active issues';
      return issues.map((i) => '  • $i').join('');
    }
    return '  • $issues';
  }

  String _formatAllergies(dynamic allergies) {
    if (allergies == null) return '  • No known drug allergies (NKDA)';
    if (allergies is List) {
      if (allergies.isEmpty) return '  • No known drug allergies (NKDA)';
      return allergies
          .map((a) => '  • ${a['medication'] ?? 'Unknown'}: ${a['reaction'] ?? 'Unknown reaction'}')
          .join('');
    }
    return '  • $allergies';
  }
}

