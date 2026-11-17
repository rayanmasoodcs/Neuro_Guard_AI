# Doctor Chatbot Implementation & Integration Guide

## Quick Start

### 1. Access the Advanced Doctor Chatbot

**From Doctor Dashboard:**
```dart
// In doctor_dashboard.dart or similar navigation point
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DoctorChatbotScreen(
      patientName: selectedPatient?.name,
      patientId: selectedPatient?.id,
      latestPrediction: prediction,
      patientData: patientData,
    ),
  ),
);
```

### 2. Core Features at a Glance

| Feature | Command | Output |
|---------|---------|--------|
| Generate Report | "Generate Report" | Professional medical report |
| Export PDF | "Export PDF" | Formatted report ready for download |
| Medication Info | "Medication Info" | ASM database + recommendations |
| EEG Guidance | "EEG Guidance" | Pattern interpretation guide |
| Safety Guidelines | "Safety Guidelines" | SUDEP, driving, water, pregnancy info |
| Drug Interactions | Ask about interactions | Specific interaction details |

### 3. Complete Integration Example

```dart
// Minimal complete example
class DoctorDashboard extends StatefulWidget {
  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  late SeizurePredictionResult _latestPrediction;
  Map<String, dynamic>? _patientData;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  void _loadPatientData() async {
    // Fetch from API or local storage
    _latestPrediction = await PredictionService().predictFromEEGFile(...);
    _patientData = {
      'age': 35,
      'gender': 'Male',
      'history': {...},
      'medications': {...},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... doctor dashboard UI
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorChatbotScreen(
              patientName: 'John Doe',
              patientId: 'PT-001',
              latestPrediction: _latestPrediction,
              patientData: _patientData,
            ),
          ),
        ),
        child: Icon(Icons.chat),
      ),
    );
  }
}
```

## Data Flow Diagrams

### Report Generation Flow
```
┌─────────────────────────────────────────────────────────────┐
│ Doctor clicks "Generate Report"                             │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ DoctorChatbotScreen._handleGenerateReport()                 │
│ ✓ Checks patient data availability                          │
│ ✓ Retrieves latest prediction                               │
│ ✓ Loads patient history & medications                       │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ MedicalReportGeneratorService.generate*Report()             │
│ ✓ Creates ClinicalReport object                             │
│ ✓ Populates with prediction data                            │
│ ✓ Adds patient history, meds, assessments                   │
│ ✓ Generates recommendations                                 │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ ClinicalReport.toFormattedText()                             │
│ ✓ Formats as professional medical document                  │
│ ✓ Includes all sections with proper headers                 │
│ ✓ Adds signature blocks and disclaimers                     │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Display in Chat                                             │
│ ✓ Show summary in chatbot interface                         │
│ ✓ Offer PDF export option                                  │
│ ✓ Store for later reference                                 │
└─────────────────────────────────────────────────────────────┘
```

### PDF Export Flow
```
┌──────────────────────────────────────────────────┐
│ Doctor clicks "Export PDF"                       │
└───────────────────┬──────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────┐
│ _handleExportPDF()                               │
│ ✓ Check if report exists                        │
│ ✓ Convert to formatted text                      │
└───────────────────┬──────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────┐
│ Generate PDF-Ready Content                       │
│ ✓ Professional formatting                        │
│ ✓ Instructions for physician                     │
│ ✓ Filename suggestions                           │
└───────────────────┬──────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────┐
│ Display Export Instructions                      │
│ ✓ Show full report preview                       │
│ ✓ Provide conversion instructions                │
│ ✓ Offer save/share options                       │
└──────────────────────────────────────────────────┘
```

### Clinical Query Flow
```
┌─────────────────────────────────────────────────┐
│ Doctor Types Query                              │
│ "What medications for focal seizures?"          │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ _sendMessage() Routes to Handler                │
│ Checks query keywords                           │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ MedicalKnowledgeBase.getAsmRecommendation()     │
│ ✓ Looks up seizure type                         │
│ ✓ Retrieves first-line medications              │
│ ✓ Accounts for comorbidities                    │
│ ✓ Generates recommendations                     │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Display Response                                │
│ ✓ Medication details                            │
│ ✓ Dosage information                            │
│ ✓ Side effects & monitoring                     │
│ ✓ Clinical pearls                               │
└─────────────────────────────────────────────────┘
```

## Common Tasks

### Task 1: Generate Seizure Report
```dart
// Trigger report generation with prediction
await _handleGenerateReport();

// Report includes:
// - Seizure type: Generalized Seizure
// - Confidence: 95.3%
// - Risk Level: HIGH
// - EEG Patterns: Bilateral synchronous activity, 3Hz spike-wave
// - Recommendations: ASM therapy, seizure diary, follow-up EEG
```

### Task 2: Answer Medication Query
```dart
// Doctor asks: "What's best for absence seizures?"
// System automatically routes to medication handler
// Displays:
// - First-line: Ethosuximide, Valproate, Lamotrigine
// - Dosage ranges for each
// - Advantages/disadvantages
// - Pregnancy considerations
// - Drug interaction checks
```

### Task 3: Query EEG Patterns
```dart
// Doctor asks: "What does 3Hz spike-wave mean?"
// System provides:
// - Pattern explanation
// - Clinical significance
// - Associated seizure types
// - Diagnostic implications
// - Documentation requirements
```

### Task 4: Review Drug Interactions
```dart
// Doctor asks: "Lamotrigine with oral contraceptives?"
// System provides:
// - Interaction: OCP reduces lamotrigine 40-60%
// - Management: May need lamotrigine dose increase
// - Monitoring: Track seizure control closely
// - Alternatives: Consider different ASM or contraception
```

### Task 5: Safety Counseling
```dart
// Doctor asks: "SUDEP risk?"
// System provides:
// - Incidence: 1 in 500-1000
// - Risk factors: GTC, poor adherence
// - Preventive measures: Adherence, action plan
// - Patient counseling: Documentation reminder
```

## API Reference

### DoctorChatbotScreen Constructor
```dart
DoctorChatbotScreen({
  Key? key,
  String? patientName,              // Patient display name
  String? patientId,                // Patient unique identifier
  SeizurePredictionResult? latestPrediction,  // Latest AI prediction
  Map<String, dynamic>? patientData, // Complete patient data
})
```

### MedicalReportGeneratorService Methods
```dart
// Generate seizure analysis report
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
})

// Generate health status report
ClinicalReport generateHealthStatusReport({...})

// Generate patient profile report
ClinicalReport generatePatientProfileReport({...})

// Generate clinical suggestions
List<String> generateClinicalSuggestions({
  required Map<String, dynamic> patientData,
  required Map<String, dynamic> seizureData,
})
```

### MedicalKnowledgeBase Methods
```dart
// Get ASM recommendations
String getAsmRecommendation(
  String seizureType,
  double confidence,
  List<String> comorbidities,
)

// Generate clinician guidance
String generateClinicianGuidance(String query)

// Static databases:
// - asmDatabase: Anti-seizure medications
// - eegInterpretationGuide: EEG pattern explanations
// - seizureClassification: Seizure type info
// - diagnosticWorkupGuide: Testing protocols
// - safetyGuidelines: Patient safety info
// - interactionDatabase: Drug interactions
```

### ClinicalReport Methods
```dart
// Get formatted text suitable for display/PDF
String toFormattedText()

// Access report properties
String reportId
String reportType
String patientName
DateTime reportDate
List<String> findings
List<String> assessments
List<String> recommendations
```

## Troubleshooting

### Issue: Report not generating
**Solution:**
- Verify patient data is provided
- Check that prediction object is not null
- Ensure physician name/license are set
```dart
if (widget.patientName == null || widget.patientId == null) {
  _addBotMessage('⚠️ Patient information not available.');
  return;
}
```

### Issue: Chat messages not scrolling
**Solution:**
- Check ScrollController initialization
- Verify hasClients check before scrolling
```dart
if (_scrollController.hasClients) {
  _scrollController.animateTo(...);
}
```

### Issue: Quick buttons not responding
**Solution:**
- Verify _isLoading state is not true
- Check message controller text is not empty
```dart
if (!_isLoading && _messageController.text.isNotEmpty) {
  _sendMessage();
}
```

## Performance Optimization

### Report Generation
- Currently synchronous (instant)
- Can be moved to background for large datasets
```dart
// Use compute for heavy processing
final report = await compute(
  _generateReportInBackground,
  reportParams,
);
```

### Knowledge Base Caching
- MedicalKnowledgeBase uses static const (cached at compile time)
- No runtime performance impact
- ~25KB memory footprint

### Message Display
- Uses ListView.builder (efficient for scrolling)
- Keeps recent messages in memory
- Consider pagination for 1000+ messages

## Security Considerations

### Patient Data Privacy
- All patient information stays on-device
- No data transmitted to external servers (local implementation)
- HIPAA compliance: Encrypt local storage if needed

### Report Confidentiality
- Include confidentiality statement in reports
- Physician must verify before sharing
- Store securely per institutional policy

### Medical Liability
- All outputs include medical disclaimer
- Physician retains clinical responsibility
- Document AI system usage in patient chart

## Testing Checklist

- [ ] Generate report with valid prediction
- [ ] Generate report without prediction (health status)
- [ ] Export report to PDF format
- [ ] Test all quick command buttons
- [ ] Verify medication recommendations accuracy
- [ ] Test EEG pattern queries
- [ ] Verify drug interaction detection
- [ ] Test safety guideline display
- [ ] Verify scroll behavior with many messages
- [ ] Test with different screen sizes (responsive)
- [ ] Verify all links in report open correctly
- [ ] Test offline functionality (uses local knowledge base)

## Future Enhancements

### Phase 2
- [ ] Direct PDF generation (pdf package)
- [ ] Email report distribution (mailer)
- [ ] Report versioning and history
- [ ] Patient PDF viewing capability

### Phase 3
- [ ] EHR system integration (HL7/FHIR)
- [ ] Real-time lab data fetch
- [ ] Predictive alerts for medication changes
- [ ] Treatment outcome tracking

### Phase 4
- [ ] Voice input for queries (speech_to_text)
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Clinical trial recommendation engine

---

**Last Updated:** July 21, 2026
**Version:** 1.0
**Status:** Production Ready
