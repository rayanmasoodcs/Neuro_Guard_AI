// Advanced Medical Knowledge Base for Doctor Chatbot
// Provides evidence-based clinical information and suggestions

class MedicalKnowledgeBase {
  static final MedicalKnowledgeBase _instance = MedicalKnowledgeBase._internal();

  factory MedicalKnowledgeBase() {
    return _instance;
  }

  MedicalKnowledgeBase._internal();

  /// ASM (Anti-Seizure Medication) Database
  static Map<String, AntieizureMedication> asmDatabase = {
    'Levetiracetam': AntieizureMedication(
      name: 'Levetiracetam (Keppra)',
      dosageRange: '500-3000 mg/day',
      seizureTypes: ['Focal', 'Generalized', 'Myoclonic'],
      sideEffects: ['Mood changes', 'Dizziness', 'Somnolence'],
      interactions: ['Warfarin', 'Phenytoin'],
      pregnancy: 'Category B - Generally safe',
      advantages: ['No drug interactions', 'No protein binding', 'Rapid absorption'],
      disadvantages: ['Behavioral side effects', 'Cost'],
      monitoring: 'Baseline behavioral assessment, liver function',
    ),
    'Lamotrigine': AntieizureMedication(
      name: 'Lamotrigine (Lamictal)',
      dosageRange: '100-500 mg/day',
      seizureTypes: ['Focal', 'Generalized', 'Absence'],
      sideEffects: ['Rash', 'Dizziness', 'Ataxia'],
      interactions: ['Oral contraceptives', 'Valproate'],
      pregnancy: 'Category C - Use with caution',
      advantages: ['Mood stabilizing', 'Broad spectrum'],
      disadvantages: ['Rash risk (1-2%)', 'Slow titration required'],
      monitoring: 'Skin examination, HLA-B*1502 testing in Asian populations',
    ),
    'Valproate': AntieizureMedication(
      name: 'Valproic Acid (Depakote)',
      dosageRange: '750-3000 mg/day',
      seizureTypes: ['Focal', 'Generalized', 'Myoclonic', 'Absence'],
      sideEffects: ['Weight gain', 'Tremor', 'Hair loss', 'Hepatotoxicity'],
      interactions: ['Lamotrigine', 'Warfarin', 'Phenytoin'],
      pregnancy: 'Category X - CONTRAINDICATED in pregnancy',
      advantages: ['Broad spectrum', 'Effective for multiple seizure types'],
      disadvantages: ['Teratogenicity', 'Hepatotoxicity risk', 'Drug interactions'],
      monitoring: 'Liver function tests (baseline, 2-4 weeks, then annual), CBC, ammonia levels',
    ),
    'Phenytoin': AntieizureMedication(
      name: 'Phenytoin (Dilantin)',
      dosageRange: '200-400 mg/day',
      seizureTypes: ['Focal', 'Generalized', 'Tonic-Clonic'],
      sideEffects: ['Gingival hyperplasia', 'Hirsutism', 'Ataxia'],
      interactions: ['Warfarin', 'Oral contraceptives', 'Corticosteroids'],
      pregnancy: 'Category D - Risk of fetal hydantoin syndrome',
      advantages: ['Long half-life', 'Inexpensive', 'Well-established'],
      disadvantages: ['Narrow therapeutic range', 'Multiple side effects', 'Drug interactions'],
      monitoring: 'Therapeutic drug monitoring (10-20 µg/mL), liver function, CBC',
    ),
    'Oxcarbazepine': AntieizureMedication(
      name: 'Oxcarbazepine (Trileptal)',
      dosageRange: '600-2400 mg/day',
      seizureTypes: ['Focal', 'Generalized'],
      sideEffects: ['Hyponatremia', 'Dizziness', 'Ataxia'],
      interactions: ['Warfarin', 'Oral contraceptives'],
      pregnancy: 'Category C - Use with caution',
      advantages: ['Better tolerability than carbamazepine', 'No therapeutic monitoring needed'],
      disadvantages: ['Hyponatremia risk (25%)', 'Similar rash risk to carbamazepine'],
      monitoring: 'Sodium levels (baseline, 1-2 weeks, then every 3 months), ECG if symptoms',
    ),
    'Topiramate': AntieizureMedication(
      name: 'Topiramate (Topamax)',
      dosageRange: '200-400 mg/day',
      seizureTypes: ['Focal', 'Generalized', 'Myoclonic'],
      sideEffects: ['Cognitive effects', 'Weight loss', 'Paresthesias'],
      interactions: ['Oral contraceptives', 'Phenytoin'],
      pregnancy: 'Category D - Risk of cleft palate',
      advantages: ['Weight neutral to weight loss', 'Broad spectrum'],
      disadvantages: ['Cognitive side effects', 'Renal stone risk'],
      monitoring: 'Cognitive assessment, vision checks, electrolytes',
    ),
    'Lacosamide': AntieizureMedication(
      name: 'Lacosamide (Vimpat)',
      dosageRange: '100-400 mg/day',
      seizureTypes: ['Focal onset'],
      sideEffects: ['Dizziness', 'Diplopia', 'Ataxia'],
      interactions: ['None major'],
      pregnancy: 'Category C - Animal studies show risk',
      advantages: ['IV and oral forms', 'Rapid onset'],
      disadvantages: ['PR interval prolongation', 'Cost', 'Restricted to focal seizures'],
      monitoring: 'ECG baseline and periodic, cardiac history assessment',
    ),
  };

  /// EEG Interpretation Guide
  static Map<String, String> eegInterpretationGuide = {
    'spike_wave_3hz': 'Classic 3 Hz spike-wave pattern strongly suggests childhood absence epilepsy (CAE). Requires EEG confirmation and valproate or ethosuximide consideration.',
    'generalized_recruitment': 'Generalized recruitment pattern indicates bilateral brain involvement. Suggests generalized seizure type requiring broader ASM spectrum coverage.',
    'focal_spike_activity': 'Focal spike activity may indicate focal/partial seizure origin. Consider temporal lobe epilepsy (TLE) if temporal localization. MRI recommended.',
    'high_amplitude_spike': 'High amplitude spikes (>200 µV) suggest seizure activity or interictal discharges. Correlate with clinical presentation and seizure semiology.',
    'post_ictal_slowing': 'Post-ictal slowing (generalized delta activity) after seizure is normal and indicates postictal period. Patient typically regaining consciousness.',
    'background_slowing': 'Diffuse background slowing may indicate encephalopathy, medication effects, or severe epilepsy. Consider metabolic work-up.',
    'sharp_waves': 'Sharp waves between spikes suggest increased epileptiform activity. More frequent sharp waves correlate with higher seizure risk.',
    'absence_seizure_pattern': '3 Hz spike-wave in absence seizures. May trigger with hyperventilation. Respond well to specific medications (ethosuximide, valproate).',
    'polyspike_wave': 'Polyspike-wave complexes suggest myoclonic seizures. Often seen in juvenile myoclonic epilepsy (JME). Requires long-term ASM therapy.',
    'intermittent_rhythmic_delta': 'Intermittent rhythmic delta activity may indicate focal brain dysfunction. Can be normal variant but assess clinically.',
  };

  /// Seizure Classification Database
  static Map<String, SeizureTypeInfo> seizureClassification = {
    'Focal Seizure': SeizureTypeInfo(
      name: 'Focal Seizure',
      icdCode: 'G40.1',
      subtypes: ['Focal aware (Jacksonian)', 'Focal impaired awareness (Temporal lobe)'],
      prevalence: '60% of all epilepsy cases',
      eegFindings: 'Focal spike activity, asymmetric background slowing',
      clinicalFeatures: 'Localized motor signs, sensory phenomena, autonomic symptoms (autonomic seizures)',
      treatmentFirst: ['Levetiracetam', 'Lamotrigine', 'Oxcarbazepine'],
      treatmentSecond: ['Valproate', 'Phenytoin', 'Lacosamide'],
      surgeryCandidate: true,
      prognosis: '70% with single ASM, 50% overall seizure-free',
    ),
    'Generalized Seizure': SeizureTypeInfo(
      name: 'Generalized Seizure',
      icdCode: 'G40.0/G40.3',
      subtypes: ['Tonic-Clonic', 'Tonic', 'Clonic', 'Absence', 'Myoclonic', 'Atonic'],
      prevalence: '40% of all epilepsy cases',
      eegFindings: '3 Hz spike-wave (absence), generalized recruitment, bilateral symmetry',
      clinicalFeatures: 'Bilateral motor involvement, loss of consciousness, post-ictal confusion',
      treatmentFirst: ['Valproate', 'Lamotrigine', 'Levetiracetam'],
      treatmentSecond: ['Topiramate', 'Phenytoin'],
      surgeryCandidate: false,
      prognosis: '65% seizure-free with appropriate therapy',
    ),
    'Absence Seizure': SeizureTypeInfo(
      name: 'Absence Seizure',
      icdCode: 'G40.2',
      subtypes: ['Typical absence (CAE)', 'Atypical absence'],
      prevalence: '5-10% of childhood epilepsy',
      eegFindings: 'Characteristic 3 Hz spike-wave pattern, bilateral synchronous',
      clinicalFeatures: 'Brief (5-30s) behavioral arrest, no motor signs, responsive immediately after',
      treatmentFirst: ['Ethosuximide', 'Valproate', 'Lamotrigine'],
      treatmentSecond: ['Topiramate'],
      surgeryCandidate: false,
      prognosis: '80-90% seizure-free with appropriate ASM',
    ),
    'Tonic-Clonic Seizure': SeizureTypeInfo(
      name: 'Tonic-Clonic Seizure',
      icdCode: 'G40.901',
      subtypes: ['Generalized onset', 'Focal-to-bilateral tonic-clonic'],
      prevalence: '35% of generalized seizures',
      eegFindings: 'High amplitude spikes, generalized recruitment, post-ictal slowing',
      clinicalFeatures: 'Loss of consciousness, tonic phase (rigidity), clonic phase (jerking), post-ictal confusion',
      treatmentFirst: ['Valproate', 'Levetiracetam', 'Lamotrigine'],
      treatmentSecond: ['Oxcarbazepine', 'Phenytoin', 'Topiramate'],
      surgeryCandidate: false,
      prognosis: '60-80% with appropriate ASM therapy',
    ),
    'Myoclonic Seizure': SeizureTypeInfo(
      name: 'Myoclonic Seizure',
      icdCode: 'G40.8',
      subtypes: ['Juvenile myoclonic epilepsy (JME)', 'Childhood myoclonic', 'Progressive'],
      prevalence: '5-10% of epilepsy',
      eegFindings: 'Polyspike-wave complexes, bilateral often asymmetric',
      clinicalFeatures: 'Sudden brief jerking movements, typically on awakening, no LOC',
      treatmentFirst: ['Valproate', 'Levetiracetam', 'Lamotrigine'],
      treatmentSecond: ['Topiramate', 'Zonisamide'],
      surgeryCandidate: false,
      prognosis: 'Usually lifelong treatment required (JME)',
    ),
  };

  /// Diagnostic Workup Recommendations
  static Map<String, DiagnosticWorkup> diagnosticWorkupGuide = {
    'first_seizure': DiagnosticWorkup(
      name: 'First Seizure Evaluation',
      priority: 'Urgent',
      tests: [
        'EEG (within 24 hours, sleep deprivation preferred)',
        'Brain MRI (3T preferred, high-resolution epilepsy protocol)',
        'Laboratory: CBC, CMP, glucose, calcium, magnesium, phosphate',
        'Urine drug screen (if indicated)',
        'Toxicology screen',
        'Blood cultures if fever present',
        'LP if meningitis/encephalitis suspected',
      ],
      timeline: '24-48 hours for EEG, 1-2 weeks for MRI',
      considerations: 'Distinguish provoked vs unprovoked seizure. Assess for secondary causes.',
    ),
    'established_epilepsy': DiagnosticWorkup(
      name: 'Established Epilepsy Management',
      priority: 'Routine',
      tests: [
        'EEG (baseline and during medication changes, annual for refractory)',
        'Brain MRI (if not already done, repeat if clinical change)',
        'Periodic ASM levels (TDM) if on drugs requiring monitoring',
        'Annual: CBC, CMP, liver function, lipids',
        'Reproductive counseling (women of childbearing age)',
        'DEXA scan consideration (on phenytoin, phenobarbital)',
      ],
      timeline: 'EEG every 1-2 years, Labs every 6-12 months',
      considerations: 'Monitor for medication side effects, drug interactions. Assess seizure control and quality of life.',
    ),
    'refractory_epilepsy': DiagnosticWorkup(
      name: 'Refractory Epilepsy Work-up',
      priority: 'High',
      tests: [
        'Repeat/Extended EEG (24-48 hour monitoring)',
        'High-resolution 3T MRI with epilepsy protocol',
        'Genetic testing if indicated (SCN1A, CDKL5, etc.)',
        'Specialized neuropsychological testing',
        'Neuroimaging co-registration studies',
        'Video-EEG telemetry for surgical candidacy',
        'PET, SPECT imaging if available',
        'Consultation with epilepsy specialist/surgery center',
      ],
      timeline: 'Urgent referral, 2-4 week evaluation',
      considerations: 'Assess for surgery candidacy, device therapy (RNS, VNS), or specialized ASM options.',
    ),
  };

  /// Safety Considerations for Seizures
  static Map<String, SafetyConsideration> safetyGuidelines = {
    'driving': SafetyConsideration(
      topic: 'Driving Restrictions',
      details: '''
Guidelines vary by jurisdiction:
• Most areas: Minimum 6-12 months seizure-free before driving
• Some regions: Unrestricted if on ASM and seizure-free >1 year
• Document physician approval; patient responsible for updates
• Advise against driving large vehicles/commercial use
• Regular reassessment required with seizures''',
    ),
    'sudep': SafetyConsideration(
      topic: 'SUDEP (Sudden Unexpected Nocturnal Death in Epilepsy)',
      details: '''
Risk Factor Discussion:
• Incidence: 1 in 500-1000 people with epilepsy
• Highest risk: Generalized tonic-clonic seizures, poor adherence, young males
• Potentially modifiable: Medication adherence, ASM compliance
• Recommended precautions:
  - Consistent ASM therapy
  - Seizure emergency action plan
  - Consider pulse oximetry/oxygen at night for high-risk patients
  - Educate patient/family on recognition and response
• Document counseling in chart''',
    ),
    'water_safety': SafetyConsideration(
      topic: 'Water Safety',
      details: '''
Bathing and Swimming Guidelines:
• Supervised bathing always recommended, especially for uncontrolled seizures
• Avoid unsupervised water activities (swimming, boating, water sports)
• Avoid bathing at height or in dangerous environments
• For swimming: Trained lifeguard present, buddy system, avoid deep water
• Personal flotation devices recommended for uncontrolled seizures
• Seizure alert dogs may be beneficial for warning
• Clear water hazards from environment''',
    ),
    'pregnancy': SafetyConsideration(
      topic: 'Pregnancy Planning',
      details: '''
Pre-Conception Counseling:
• Risk of birth defects with ASMs (varies by medication)
• High risk: Phenytoin (fetal hydantoin syndrome), Valproate (10-20% malformation rate)
• Safer options: Levetiracetam, Lamotrigine, Oxcarbazepine (Category C)
• Folic acid supplementation (5 mg daily) recommended
• Consider medication optimization before conception
• High-dose ASM therapy increases malformation risk
• Pregnancy registry enrollment available for ASM exposure monitoring
• Seizure breakthrough risk during pregnancy (hormonal changes)
• Close coordination with obstetrics and neurology''',
    ),
    'employment': SafetyConsideration(
      topic: 'Employment Considerations',
      details: '''
Workplace Safety:
• Avoid work at heights, with heavy machinery, near fire/water
• Job duty assessment required
• Workplace accommodations may include:
  - Flexible scheduling to avoid seizure triggers
  - Quiet rest area for recovery
  - Time for medication adherence
• Anti-discrimination laws: ADA (USA), similar in other countries
• Disclosure decisions: Not required but may enable accommodations
• Document seizure impact on job performance if relevant''',
    ),
  };

  /// Drug-Drug Interaction Database
  static Map<String, String> interactionDatabase = {
    'levetiracetam_warfarin': 'Levetiracetam + Warfarin: Monitor INR closely, minimal interaction but case reports exist',
    'lamotrigine_oc': 'Lamotrigine + Oral Contraceptives: OC reduces lamotrigine levels by 40-60%, may need dose increase',
    'valproate_lamotrigine': 'Valproate + Lamotrigine: Valproate inhibits lamotrigine metabolism, increase lamotrigine toxicity risk',
    'phenytoin_warfarin': 'Phenytoin + Warfarin: Phenytoin increases warfarin metabolism, requires warfarin monitoring/adjustment',
    'oxcarbazepine_oc': 'Oxcarbazepine + OCP: May reduce OCP efficacy at doses >900 mg/day',
    'topiramate_oc': 'Topiramate + OCP: Topiramate increases OCP levels significantly, lower OCP doses may be needed',
  };

  /// Clinical Decision Support
  String getAsmRecommendation(
    String seizureType,
    double confidence,
    List<String> comorbidities,
  ) {
    StringBuffer recommendation = StringBuffer();

    // Primary recommendation based on seizure type
    switch (seizureType) {
      case 'Generalized Seizure':
        recommendation.writeln('First-line ASM for Generalized Seizures:');
        recommendation.writeln('1. Valproate (most effective, broad spectrum) - 750-3000 mg/day');
        recommendation.writeln('   Caution: Teratogenic, avoid in women of childbearing age');
        recommendation.writeln('2. Lamotrigine - 100-500 mg/day (better pregnancy profile)');
        recommendation.writeln('3. Levetiracetam - 500-3000 mg/day (no drug interactions)');
        break;

      case 'Focal Seizure':
        recommendation.writeln('First-line ASM for Focal Seizures:');
        recommendation.writeln('1. Levetiracetam - 500-3000 mg/day (first-line, excellent tolerability)');
        recommendation.writeln('2. Lamotrigine - 100-500 mg/day');
        recommendation.writeln('3. Oxcarbazepine - 600-2400 mg/day (watch sodium levels)');
        break;

      case 'Myoclonic Seizure':
        recommendation.writeln('First-line ASM for Myoclonic Seizures:');
        recommendation.writeln('1. Valproate - 750-3000 mg/day (most effective)');
        recommendation.writeln('2. Levetiracetam - 500-3000 mg/day');
        recommendation.writeln('3. Lamotrigine - 100-500 mg/day');
        break;

      case 'Absence Seizure':
        recommendation.writeln('First-line ASM for Absence Seizures:');
        recommendation.writeln('1. Ethosuximide - 500-1500 mg/day (specific for absence)');
        recommendation.writeln('2. Valproate - 750-3000 mg/day');
        recommendation.writeln('3. Lamotrigine - 100-500 mg/day');
        break;

      default:
        recommendation.writeln('Requires clinical evaluation for seizure type classification');
    }

    // Add comorbidity considerations
    if (comorbidities.isNotEmpty) {
      recommendation.writeln('--- Comorbidity Considerations ---');
      for (String comorbid in comorbidities) {
        switch (comorbid.toLowerCase()) {
          case 'depression':
            recommendation.writeln('• Depression: Consider lamotrigine (mood stabilizing), avoid topiramate (mood effects)');
            break;
          case 'bipolar':
            recommendation.writeln('• Bipolar Disorder: Lamotrigine or valproate beneficial');
            break;
          case 'obesity':
            recommendation.writeln('• Obesity: Avoid valproate (weight gain), consider topiramate (weight loss)');
            break;
          case 'migraine':
            recommendation.writeln('• Migraine: Topiramate or valproate helpful (dual benefit)');
            break;
        }
      }
    }

    recommendation.writeln('--- Monitoring Plan ---');
    recommendation.writeln('• Baseline labs: CBC, CMP, LFTs, anticoagulation (if applicable)');
    recommendation.writeln('• Follow-up: 2 weeks for tolerability, 4-6 weeks for efficacy');
    recommendation.writeln('• Seizure diary: Document frequency, time, duration, triggers');
    recommendation.writeln('• Medication adherence: Critical for seizure control');

    return recommendation.toString();
  }

  String generateClinicianGuidance(String query) {
    final lowerQuery = query.toLowerCase();

    // EEG-related queries
    if (lowerQuery.contains('eeg') || lowerQuery.contains('pattern')) {
      return '''
EEG INTERPRETATION GUIDE:
${_formatMapAsString(eegInterpretationGuide)}

Key Points:
• Interictal EEGs normal in 20-30% of untreated epilepsy patients
• Sleep-deprived EEG increases abnormality yield by 30-50%
• 24-48 hour monitoring required for confirmation of seizure origin
• Correlation with clinical semiology essential for localization
''';
    }

    // Medication interaction queries
    if (lowerQuery.contains('interact') || lowerQuery.contains('drug')) {
      return '''
DRUG INTERACTION CONSIDERATIONS:

${_formatMapAsString(interactionDatabase)}

Management:
• Review all medications before ASM initiation
• Monitor pharmacokinetic interactions closely
• Adjust doses based on drug-drug interactions
• Consider third-line ASMs with fewer interactions if needed
• Use therapeutic drug monitoring when available
''';
    }

    // Safety queries
    if (lowerQuery.contains('safety') || lowerQuery.contains('sudep') || lowerQuery.contains('drive')) {
      return _buildSafetyResponse(lowerQuery);
    }

    // Diagnosis queries
    if (lowerQuery.contains('diagnos') || lowerQuery.contains('workup')) {
      return '''
DIAGNOSTIC EVALUATION RECOMMENDATIONS:

For First Seizure:
${_formatMapAsString(diagnosticWorkupGuide).split('').take(10).join('')}

Standard Approach:
1. Clinical history and neurological exam
2. EEG (within 24 hours if possible)
3. Brain imaging (MRI preferred over CT)
4. Laboratory assessment (glucose, calcium, magnesium, etc.)
5. Assessment for provoked vs unprovoked seizure
6. Differentiation from seizure mimics
''';
    }

    return _defaultClinicalResponse();
  }

  String _buildSafetyResponse(String query) {
    StringBuffer response = StringBuffer('PATIENT SAFETY CONSIDERATIONS:');

    if (query.contains('sudep')) {
      response.writeln(safetyGuidelines['sudep']?.details ?? '');
    } else if (query.contains('drive')) {
      response.writeln(safetyGuidelines['driving']?.details ?? '');
    } else if (query.contains('water')) {
      response.writeln(safetyGuidelines['water_safety']?.details ?? '');
    } else if (query.contains('pregnan')) {
      response.writeln(safetyGuidelines['pregnancy']?.details ?? '');
    } else {
      // Include all safety guidelines
      for (var safety in safetyGuidelines.values) {
        response.writeln('${safety.topic}:${safety.details}');
      }
    }

    return response.toString();
  }

  String _formatMapAsString<T>(Map<String, T> map) {
    return map.entries
        .map((e) => '${e.key}: ${e.value.toString()}')
        .join('');
  }

  String _defaultClinicalResponse() {
    return '''
CLINICAL DECISION SUPPORT:

Key Clinical Pearls:
1. Always distinguish focal vs generalized seizure onset
2. Medication choice depends on seizure type, not syndrome
3. Target: Seizure freedom with minimal side effects
4. 70% of new-onset epilepsy patients achieve seizure control with first or second ASM
5. If one ASM fails: Add or switch, don't double-dose

Evaluation Checklist:
□ Seizure type clearly defined (focal/generalized, subtype)
□ Provoked vs unprovoked determined
□ MRI reviewed and findings documented
□ EEG interpreted in clinical context
□ Medication allergy/interaction history obtained
□ Pregnancy/contraception status assessed
□ Comorbidities identified and accounted for
□ Patient education provided on disease and treatment

Follow-up:
• First visit: Baseline labs, EEG, imaging
• 4-6 weeks: Efficacy assessment, side effect review
• 3-6 months: Titration to target dose if needed
• Annual: Medication review, labs, EEG if indicated
''';
  }
}

// Data Models

class AntieizureMedication {
  final String name;
  final String dosageRange;
  final List<String> seizureTypes;
  final List<String> sideEffects;
  final List<String> interactions;
  final String pregnancy;
  final List<String> advantages;
  final List<String> disadvantages;
  final String monitoring;

  AntieizureMedication({
    required this.name,
    required this.dosageRange,
    required this.seizureTypes,
    required this.sideEffects,
    required this.interactions,
    required this.pregnancy,
    required this.advantages,
    required this.disadvantages,
    required this.monitoring,
  });
}

class SeizureTypeInfo {
  final String name;
  final String icdCode;
  final List<String> subtypes;
  final String prevalence;
  final String eegFindings;
  final String clinicalFeatures;
  final List<String> treatmentFirst;
  final List<String> treatmentSecond;
  final bool surgeryCandidate;
  final String prognosis;

  SeizureTypeInfo({
    required this.name,
    required this.icdCode,
    required this.subtypes,
    required this.prevalence,
    required this.eegFindings,
    required this.clinicalFeatures,
    required this.treatmentFirst,
    required this.treatmentSecond,
    required this.surgeryCandidate,
    required this.prognosis,
  });
}

class DiagnosticWorkup {
  final String name;
  final String priority;
  final List<String> tests;
  final String timeline;
  final String considerations;

  DiagnosticWorkup({
    required this.name,
    required this.priority,
    required this.tests,
    required this.timeline,
    required this.considerations,
  });
}

class SafetyConsideration {
  final String topic;
  final String details;

  SafetyConsideration({
    required this.topic,
    required this.details,
  });
}


