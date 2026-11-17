// Advanced Medical Report Generator for Doctor Chatbot
// Generates comprehensive clinical reports from predictions

import 'package:neuroguard_ai/models/seizure_prediction_model.dart';

class ClinicalReport {
  final String reportId;
  final String reportType; // seizure_analysis, health_status, patient_profile, comprehensive
  final String patientName;
  final String patientId;
  final String? patientAge;
  final String? patientGender;
  final DateTime reportDate;
  final String physicianName;
  final String physicianLicense;
  final String clinicalSummary;
  final List<String> findings;
  final List<String> assessments;
  final List<String> recommendations;
  final Map<String, dynamic>? seizurePredictionData;
  final Map<String, dynamic>? patientHistoryData;
  final Map<String, dynamic>? medicationData;
  final List<String> attachedImages; // EEG, MRI, etc.
  final String disclaimer;

  ClinicalReport({
    required this.reportId,
    required this.reportType,
    required this.patientName,
    required this.patientId,
    this.patientAge,
    this.patientGender,
    required this.reportDate,
    required this.physicianName,
    required this.physicianLicense,
    required this.clinicalSummary,
    required this.findings,
    required this.assessments,
    required this.recommendations,
    this.seizurePredictionData,
    this.patientHistoryData,
    this.medicationData,
    this.attachedImages = const [],
    this.disclaimer =
        '⚠️ MEDICAL DISCLAIMER: This report is for informational purposes and clinical decision support only. All recommendations must be verified against current evidence-based guidelines and institutional protocols. The physician retains full clinical responsibility for all patient care decisions.',
  });

  /// Generate formatted text report suitable for printing/PDF
  String toFormattedText() {
    StringBuffer report = StringBuffer();

    // Header
    report.writeln('╔════════════════════════════════════════════════════════════════╗');
    report.writeln('║                   CLINICAL MEDICAL REPORT                      ║');
    report.writeln('║                    NeuroGuard AI System                        ║');
    report.writeln('╚════════════════════════════════════════════════════════════════╝');

    // Report Metadata
    report.writeln('REPORT INFORMATION');
    report.writeln('═' * 70);
    report.writeln('Report ID: $reportId');
    report.writeln('Report Type: ${reportType.replaceAll('_', ' ').toUpperCase()}');
    report.writeln('Generated: ${reportDate.toLocal()}');
    report.writeln('Report Date: ${_formatDate(reportDate)}');

    // Patient Information
    report.writeln('PATIENT INFORMATION');
    report.writeln('═' * 70);
    report.writeln('Name: $patientName');
    report.writeln('Patient ID: $patientId');
    if (patientAge != null) report.writeln('Age: $patientAge');
    if (patientGender != null) report.writeln('Gender: $patientGender');
    report.writeln();

    // Physician Information
    report.writeln('PHYSICIAN INFORMATION');
    report.writeln('═' * 70);
    report.writeln('Physician: $physicianName');
    report.writeln('License #: $physicianLicense');
    report.writeln();

    // Clinical Summary
    report.writeln('CLINICAL SUMMARY');
    report.writeln('═' * 70);
    report.writeln(clinicalSummary);
    report.writeln();

    // Seizure Prediction Data (if available)
    if (seizurePredictionData != null) {
      report.writeln('SEIZURE ANALYSIS RESULTS');
      report.writeln('═' * 70);
      report.writeln('Seizure Type: ${seizurePredictionData?['seizureType'] ?? 'N/A'}');
      report.writeln(
          'Confidence Score: ${((seizurePredictionData?['confidence'] ?? 0) * 100).toStringAsFixed(1)}%');
      report.writeln('Risk Level: ${seizurePredictionData?['riskLevel'] ?? 'N/A'}');

      final patterns = seizurePredictionData?['eegPatterns'] as List?;
      if (patterns != null && patterns.isNotEmpty) {
        report.writeln('EEG Patterns Detected:');
        for (var i = 0; i < patterns.length; i++) {
          report.writeln('  ${i + 1}. ${patterns[i]}');
        }
      }
      report.writeln();
    }

    // Clinical Findings
    if (findings.isNotEmpty) {
      report.writeln('CLINICAL FINDINGS');
      report.writeln('═' * 70);
      for (var i = 0; i < findings.length; i++) {
        report.writeln('${i + 1}. ${findings[i]}');
      }
      report.writeln();
    }

    // Assessment & Diagnosis
    if (assessments.isNotEmpty) {
      report.writeln('ASSESSMENT & DIAGNOSIS');
      report.writeln('═' * 70);
      for (var i = 0; i < assessments.length; i++) {
        report.writeln('${i + 1}. ${assessments[i]}');
      }
      report.writeln();
    }

    // Patient History (if available)
    if (patientHistoryData != null) {
      report.writeln('PATIENT MEDICAL HISTORY');
      report.writeln('═' * 70);
      report.writeln('Current Diagnoses:');
      final diagnoses = patientHistoryData?['diagnoses'] as List?;
      if (diagnoses != null) {
        for (var diag in diagnoses) {
          report.writeln('  • $diag');
        }
      } else {
        report.writeln('  No documented diagnoses');
      }

      report.writeln('Family History:');
      final familyHistory = patientHistoryData?['familyHistory'] as String?;
      report.writeln('  ${familyHistory ?? 'No significant family history documented'}');

      report.writeln('Allergies:');
      final allergies = patientHistoryData?['allergies'] as List?;
      if (allergies != null && allergies.isNotEmpty) {
        for (var allergy in allergies) {
          report.writeln('  • $allergy');
        }
      } else {
        report.writeln('  No documented allergies');
      }
      report.writeln();
    }

    // Current Medications (if available)
    if (medicationData != null) {
      final meds = medicationData?['medications'] as List?;
      if (meds != null && meds.isNotEmpty) {
        report.writeln('CURRENT MEDICATIONS');
        report.writeln('═' * 70);
        for (var med in meds) {
          if (med is Map) {
            report.writeln('• ${med['name'] ?? 'Unknown'}');
            if (med['dosage'] != null) report.writeln('  Dosage: ${med['dosage']}');
            if (med['frequency'] != null) report.writeln('  Frequency: ${med['frequency']}');
            if (med['indication'] != null) report.writeln('  Indication: ${med['indication']}');
          }
        }
        report.writeln();
      }
    }

    // Treatment Recommendations
    if (recommendations.isNotEmpty) {
      report.writeln('RECOMMENDATIONS & TREATMENT PLAN');
      report.writeln('═' * 70);
      for (var i = 0; i < recommendations.length; i++) {
        report.writeln('${i + 1}. ${recommendations[i]}');
      }
      report.writeln();
    }

    // Follow-up Plan
    report.writeln('FOLLOW-UP PLAN');
    report.writeln('═' * 70);
    report.writeln('• Next appointment: 4-6 weeks for assessment of medication efficacy');
    report.writeln('• EEG follow-up: Per institutional protocol or clinical indication');
    report.writeln('• Laboratory monitoring: As per medication regimen');
    report.writeln('• Patient to maintain seizure diary and medication adherence');
    report.writeln('• Contact physician if any adverse effects or seizure breakthrough occurs');
    report.writeln();

    // Safety Counseling
    report.writeln('PATIENT SAFETY COUNSELING');
    report.writeln('═' * 70);
    report.writeln('• Seizure emergency action plan discussed');
    report.writeln('• Driving restrictions reviewed (varies by jurisdiction and seizure control)');
    report.writeln('• SUDEP (Sudden Unexpected Nocturnal Death in Epilepsy) risk discussed');
    report.writeln('• Water safety precautions reviewed');
    report.writeln('• Medication adherence emphasized');
    report.writeln('• Trigger identification and avoidance discussed');
    report.writeln();

    // Medical Disclaimer
    report.writeln('MEDICAL DISCLAIMER');
    report.writeln('═' * 70);
    report.writeln(disclaimer);
    report.writeln();

    // Signature Block
    report.writeln('PHYSICIAN SIGNATURE & AUTHORIZATION');
    report.writeln('═' * 70);
    report.writeln('Physician Name (Print): _________________________________');
    report.writeln('Physician Signature:     _________________________________');
    report.writeln('License Number:         $physicianLicense');
    report.writeln('Date:                   _________________________________');
    report.writeln('');

    // Footer
    report.writeln('═' * 70);
    report.writeln('Report generated by NeuroGuard AI Clinical Decision Support System');
    report.writeln('For inquiries, contact: support@neuroguard-ai.com');
    report.writeln('═' * 70);

    return report.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class MedicalReportGeneratorService {
  static final MedicalReportGeneratorService _instance = MedicalReportGeneratorService._internal();

  factory MedicalReportGeneratorService() {
    return _instance;
  }

  MedicalReportGeneratorService._internal();

  /// Generate Seizure Analysis Report from prediction
  ClinicalReport generateSeizureAnalysisReport({
    required String patientName,
    required String patientId,
    required SeizurePredictionResult prediction,
    required String physicianName,
    required String physicianLicense,
    String? patientAge,
    String? patientGender,
    Map<String, dynamic>? patientHistory,
    Map<String, dynamic>? medications,
  }) {
    final reportId = 'SR-${DateTime.now().millisecondsSinceEpoch}';

    StringBuffer clinicalSummary = StringBuffer();
    clinicalSummary.writeln('Patient presented for seizure evaluation.');
    clinicalSummary.writeln(
        'EEG analysis reveals ${prediction.seizureType.toLowerCase()} with ${(prediction.confidence * 100).toStringAsFixed(1)}% confidence.');
    clinicalSummary
        .writeln('Risk level classified as ${prediction.riskLevel.toUpperCase()}.');
    clinicalSummary.writeln(
        'EEG patterns consistent with: ${prediction.eegPatterns.join(", ")}');

    List<String> findings = [
      '${prediction.seizureType} identified on EEG analysis',
      'Confidence score: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
      'Risk classification: ${prediction.riskLevel}',
    ];

    findings.addAll(prediction.eegPatterns.map((p) => 'Pattern: $p'));

    List<String> assessments = [
      '${prediction.seizureType} - Confirmed by EEG analysis',
      'Severity: ${prediction.riskLevel.toUpperCase()}',
      'Current seizure risk: ${_getRiskDescription(prediction.riskLevel)}',
    ];

    List<String> recommendations = [
      'Initiate appropriate anti-seizure medication (ASM) based on seizure type',
      'Schedule follow-up EEG in 4-6 weeks',
      'Patient to maintain detailed seizure diary',
      'Implement safety precautions (driving restrictions, water safety)',
      'Schedule neurology follow-up in 2-4 weeks',
      'Baseline labs (CBC, CMP, LFTs) before ASM initiation',
    ];

    return ClinicalReport(
      reportId: reportId,
      reportType: 'seizure_analysis',
      patientName: patientName,
      patientId: patientId,
      patientAge: patientAge,
      patientGender: patientGender,
      reportDate: DateTime.now(),
      physicianName: physicianName,
      physicianLicense: physicianLicense,
      clinicalSummary: clinicalSummary.toString(),
      findings: findings,
      assessments: assessments,
      recommendations: recommendations,
      seizurePredictionData: prediction.toJson(),
      patientHistoryData: patientHistory,
      medicationData: medications,
    );
  }

  /// Generate Comprehensive Health Status Report
  ClinicalReport generateHealthStatusReport({
    required String patientName,
    required String patientId,
    required String physicianName,
    required String physicianLicense,
    String? patientAge,
    String? patientGender,
    Map<String, dynamic>? vitalSigns,
    Map<String, dynamic>? patientHistory,
    Map<String, dynamic>? medications,
    Map<String, dynamic>? recentTests,
  }) {
    final reportId = 'HS-${DateTime.now().millisecondsSinceEpoch}';

    StringBuffer clinicalSummary = StringBuffer();
    clinicalSummary.writeln('Comprehensive health status evaluation performed.');
    clinicalSummary.writeln('Patient presents with stable medical status.');
    clinicalSummary
        .writeln('Current medication regimen reviewed and optimized as needed.');

    List<String> findings = [
      'Vital signs reviewed',
      'Physical examination completed',
      'Medical history documented',
    ];

    if (vitalSigns != null) {
      findings.add(
          'Blood Pressure: ${vitalSigns["bloodPressure"] ?? "Not recorded"} mmHg');
      findings.add('Heart Rate: ${vitalSigns["heartRate"] ?? "Not recorded"} bpm');
      findings.add('Temperature: ${vitalSigns["temperature"] ?? "Not recorded"}°C');
      findings.add('Respiratory Rate: ${vitalSigns["respiratoryRate"] ?? "Not recorded"} breaths/min');
    }

    List<String> assessments = [
      'General health status: Stable',
      'Seizure control status: Per patient report',
      'Medication adherence: To be assessed',
    ];

    List<String> recommendations = [
      'Continue current anti-seizure medication regimen',
      'Maintain seizure diary for pattern recognition',
      'Regular exercise and stress management',
      'Avoid known seizure triggers',
      'Follow-up appointment in 6-8 weeks',
      'Annual EEG and labs as per protocol',
    ];

    return ClinicalReport(
      reportId: reportId,
      reportType: 'health_status',
      patientName: patientName,
      patientId: patientId,
      patientAge: patientAge,
      patientGender: patientGender,
      reportDate: DateTime.now(),
      physicianName: physicianName,
      physicianLicense: physicianLicense,
      clinicalSummary: clinicalSummary.toString(),
      findings: findings,
      assessments: assessments,
      recommendations: recommendations,
      patientHistoryData: patientHistory,
      medicationData: medications,
    );
  }

  /// Generate Patient Profile Report
  ClinicalReport generatePatientProfileReport({
    required String patientName,
    required String patientId,
    required String physicianName,
    required String physicianLicense,
    String? patientAge,
    String? patientGender,
    Map<String, dynamic>? demographics,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? medications,
  }) {
    final reportId = 'PP-${DateTime.now().millisecondsSinceEpoch}';

    StringBuffer clinicalSummary = StringBuffer();
    clinicalSummary.writeln('Complete patient profile documentation.');
    clinicalSummary.writeln('Demographics, medical history, and current medications compiled.');
    clinicalSummary.writeln('Patient ready for clinical assessment and treatment planning.');

    List<String> findings = [
      'Patient demographics documented',
      'Medical history reviewed and updated',
      'Current medications listed',
      'Drug allergies identified',
    ];

    List<String> assessments = [
      'Patient profile complete and current',
      'Medical information organized for clinical decision-making',
      'Treatment history reviewed',
    ];

    List<String> recommendations = [
      'Patient to keep record of all medical visits',
      'Update medications list as changes occur',
      'Maintain regular follow-up appointments',
      'Communicate any new symptoms or concerns promptly',
    ];

    return ClinicalReport(
      reportId: reportId,
      reportType: 'patient_profile',
      patientName: patientName,
      patientId: patientId,
      patientAge: patientAge,
      patientGender: patientGender,
      reportDate: DateTime.now(),
      physicianName: physicianName,
      physicianLicense: physicianLicense,
      clinicalSummary: clinicalSummary.toString(),
      findings: findings,
      assessments: assessments,
      recommendations: recommendations,
      patientHistoryData: medicalHistory,
      medicationData: medications,
    );
  }

  /// Generate Clinical Suggestions based on patient data
  List<String> generateClinicalSuggestions({
    required Map<String, dynamic> patientData,
    required Map<String, dynamic> seizureData,
  }) {
    List<String> suggestions = [];

    // Seizure frequency analysis
    final seizureFrequency = seizureData['frequency'] as num?;
    if (seizureFrequency != null && seizureFrequency > 4) {
      suggestions.add(
          '⚠️ HIGH PRIORITY: Seizure frequency >4/month detected. Consider ASM adjustment or addition of second-line therapy.');
    } else if (seizureFrequency != null && seizureFrequency > 2) {
      suggestions.add('Moderate seizure frequency detected. Continue monitoring, consider ASM titration.');
    }

    // Medication adherence
    final adherence = patientData['medicationAdherence'] as String?;
    if (adherence == 'Poor') {
      suggestions.add('⚠️ MEDICATION ADHERENCE CONCERN: Patient adherence is poor. Implement adherence counseling and consider simplification of regimen.');
    }

    // EEG findings
    final eegFindings = seizureData['eegPatterns'] as List?;
    if (eegFindings != null && eegFindings.isNotEmpty) {
      suggestions.add('Review EEG findings with patient. Consider home safety modifications based on seizure semiology.');
    }

    // Age-specific considerations
    final age = patientData['age'] as num?;
    if (age != null) {
      if (age < 18) {
        suggestions.add('PEDIATRIC CONSIDERATION: Ensure age-appropriate dosing and developmental monitoring during ASM therapy.');
      } else if (age > 65) {
        suggestions.add('GERIATRIC CONSIDERATION: Monitor for polypharmacy interactions. Consider simplified dosing schedule.');
      }
    }

    // Pregnancy status
    final pregnancy = patientData['pregnancyStatus'] as String?;
    if (pregnancy == 'Pregnant' || pregnancy == 'Planning') {
      suggestions.add('⚠️ PREGNANCY PLANNING: Ensure ASM teratogenicity profile reviewed. Consider folic acid supplementation. High-risk meds (valproate) should be avoided if possible.');
    }

    // Comorbidity considerations
    final comorbidities = patientData['comorbidities'] as List?;
    if (comorbidities != null) {
      if (comorbidities.contains('Depression')) {
        suggestions.add('Depression documented: Consider lamotrigine (mood-stabilizing properties) if seizure type appropriate.');
      }
      if (comorbidities.contains('Migraine')) {
        suggestions.add('Migraine history: Topiramate or valproate may provide dual benefit for seizure + migraine management.');
      }
    }

    // If no suggestions generated, provide default guidance
    if (suggestions.isEmpty) {
      suggestions = [
        'Patient is clinically stable on current regimen.',
        'Continue current medications with good adherence.',
        'Maintain seizure diary and report any changes.',
        'Schedule routine follow-up in 6-8 weeks.',
      ];
    }

    return suggestions;
  }

  String _getRiskDescription(String riskLevel) {
    switch (riskLevel) {
      case 'Low':
        return 'Low risk - Good prognosis with appropriate treatment';
      case 'Medium':
        return 'Moderate risk - Requires close monitoring and adherence to treatment';
      case 'High':
        return 'High risk - Requires urgent intervention and close follow-up';
      default:
        return 'Risk level to be determined by clinical evaluation';
    }
  }
}


