import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neuroguard_ai/models/seizure_prediction_model.dart';
import 'package:neuroguard_ai/services/medical_knowledge_base.dart';
import 'package:neuroguard_ai/services/medical_report_generator_service.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class DoctorChatbotScreen extends StatefulWidget {
  final String? patientName;
  final String? patientId;
  final int? userId;
  final SeizurePredictionResult? latestPrediction;
  final Map<String, dynamic>? patientData;

  const DoctorChatbotScreen({
    super.key,
    this.patientName,
    this.patientId,
    this.userId,
    this.latestPrediction,
    this.patientData,
  });

  @override
  State<DoctorChatbotScreen> createState() => _DoctorChatbotScreenState();
}

class _DoctorChatbotScreenState extends State<DoctorChatbotScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  final List<ChatMessage> _messages = [];
  final MedicalKnowledgeBase _knowledgeBase = MedicalKnowledgeBase();
  final MedicalReportGeneratorService _reportGenerator = MedicalReportGeneratorService();
  bool _isLoading = false;
  ClinicalReport? _generatedReport;

  final List<String> _quickCommands = [
    'Generate Report',
    'Export PDF',
    'Medication Info',
    'EEG Guidance',
    'Safety Guidelines',
    'Patient History',
    'Diagnostic Workup',
    'Comorbidity Management',
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final uid = widget.userId?.toString() ?? '1';
    try {
      final res = await http.get(Uri.parse("${AppConfig.baseUrl}/get_chat_history/$uid"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final List<dynamic> conv = data['conversations'] ?? [];
          setState(() {
            _messages.clear();
            for (var m in conv) {
              _messages.add(ChatMessage(
                sender: (m['is_user'] == 1) ? 'user' : 'assistant',
                text: m['text'] ?? '',
                timestamp: DateTime.tryParse(m['timestamp']?.toString() ?? '') ?? DateTime.now(),
              ));
            }
          });
        }
      }
    } catch (e) {
      // silently fallback
    }

    if (_messages.isEmpty) {
      _addBotMessage(_getWelcomeMessage());
    }
  }

  Future<void> _saveMessage(String text, bool isUser) async {
    final uid = widget.userId?.toString() ?? '1';
    try {
      await http.post(
        Uri.parse("${AppConfig.baseUrl}/save_chat_message"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': int.tryParse(uid) ?? 1,
          'text': text,
          'is_user': isUser ? 1 : 0,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      // silently fail
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getWelcomeMessage() {
    return '''
Welcome, Dr. ${widget.patientName ?? 'Healthcare Professional'}!

I'm your Advanced Clinical Decision Support AI Assistant. I can help you with:

✓ Generate comprehensive medical reports (from predictions)
✓ Export reports as PDF for patient records
✓ Provide evidence-based medication recommendations
✓ Explain EEG patterns and findings
✓ Review drug interactions
✓ Discuss safety considerations (SUDEP, driving, pregnancy, etc.)
✓ Suggest diagnostic workup
✓ Manage patient comorbidities
✓ Answer complex clinical queries

How can I assist you today?
    ''';
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        sender: 'assistant',
        text: message,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    _saveMessage(message, false);
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        sender: 'user',
        text: message,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    _saveMessage(message, true);
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleGenerateReport() async {
    if (widget.patientName == null || widget.patientId == null) {
      _addBotMessage(
          '⚠️ Patient information not available. Please provide patient details.');
      return;
    }

    setState(() => _isLoading = true);
    _addUserMessage('Generate Report');

    try {
      ClinicalReport report;

      if (widget.latestPrediction != null) {
        // Generate seizure analysis report with prediction
        report = _reportGenerator.generateSeizureAnalysisReport(
          patientName: widget.patientName!,
          patientId: widget.patientId!,
          prediction: widget.latestPrediction!,
          physicianName: 'Dr. [Physician Name]',
          physicianLicense: '[License Number]',
          patientAge: widget.patientData?['age']?.toString(),
          patientGender: widget.patientData?['gender'],
          patientHistory: widget.patientData?['history'],
          medications: widget.patientData?['medications'],
        );
      } else {
        // Generate health status report
        report = _reportGenerator.generateHealthStatusReport(
          patientName: widget.patientName!,
          patientId: widget.patientId!,
          physicianName: 'Dr. [Physician Name]',
          physicianLicense: '[License Number]',
          patientAge: widget.patientData?['age']?.toString(),
          patientGender: widget.patientData?['gender'],
          vitalSigns: widget.patientData?['vitals'],
          patientHistory: widget.patientData?['history'],
          medications: widget.patientData?['medications'],
        );
      }

      setState(() => _generatedReport = report);

      String botResponse = '''
✅ MEDICAL REPORT GENERATED SUCCESSFULLY!

📋 Report Details:
• Report ID: ${report.reportId}
• Report Type: ${report.reportType.replaceAll('_', ' ').toUpperCase()}
• Patient: ${report.patientName} (ID: ${report.patientId})
• Generated: ${report.reportDate.toLocal()}
• Physician: ${report.physicianName}

📊 Report Content Summary:
${report.findings.take(3).map((f) => '• $f').join('')}

Available Actions:
1. 📥 Export to PDF - Download complete report
2. 📋 View Full Report - See all details
3. 🖨️ Print Report - Prepare for printing
4. 💾 Save to Patient File - Store in system

Type "Export PDF" to download this report, or ask me any clinical questions!
    ''';

      _addBotMessage(botResponse);
    } catch (e) {
      _addBotMessage('❌ Error generating report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleExportPDF() async {
    if (_generatedReport == null) {
      _addBotMessage('❌ No report to export. Please generate a report first.');
      return;
    }

    _addUserMessage('Export PDF');

    try {
      // Convert report to text format
      String reportContent = _generatedReport!.toFormattedText();
      _addBotMessage('''
📄 PDF EXPORT READY!

The complete medical report has been formatted for PDF export.

Full Report Preview:
$reportContent

═══════════════════════════════════════════

✅ To Export as PDF:

1. **Copy Report** - All text is formatted and ready
2. **Open PDF Creator** - Use Microsoft Word, Google Docs, or dedicated PDF tool
3. **Paste Content** - Insert the formatted text
4. **Add Signature** - Sign electronically or in print
5. **Save File** - Name it appropriately and save to patient records

📋 Filename Suggestion: 
   Report_${_generatedReport!.patientId}_${DateTime.now().toString().split(' ')[0]}.pdf

⚠️ REMINDER: 
• Verify all clinical information before finalization
• Include your physician signature and license number
• Store in HIPAA-compliant patient records
• Maintain backup copies as per institutional policy

Would you like me to help with anything else?
      ''');
    } catch (e) {
      _addBotMessage('❌ Error preparing PDF export: $e');
    }
  }

  Future<void> _handleMedicationInfo(String query) async {
    _addUserMessage(query);
    setState(() => _isLoading = true);

    try {
      // Extract medication name from query
      String response = _knowledgeBase.getAsmRecommendation(
        widget.latestPrediction?.seizureType ?? 'Unknown',
        widget.latestPrediction?.confidence ?? 0.0,
        widget.patientData?['comorbidities'] ?? [],
      );

      _addBotMessage('''
💊 ANTI-SEIZURE MEDICATION (ASM) RECOMMENDATIONS

$response

═══════════════════════════════════════════

📊 MEDICATION COMPARISON TABLE:

Levetiracetam (Keppra):
  ✓ No drug interactions
  ✓ Broad spectrum
  ✗ Mood/behavioral side effects
  • Dosage: 500-3000 mg/day

Lamotrigine (Lamictal):
  ✓ Mood stabilizing
  ✓ Pregnancy Category C
  ✗ Requires slow titration
  • Dosage: 100-500 mg/day

Valproate (Depakote):
  ✓ Most effective spectrum
  ✗ TERATOGENIC - avoid pregnancy
  ✗ Weight gain, hair loss
  • Dosage: 750-3000 mg/day

═══════════════════════════════════════════

NEXT STEPS:
1. Select medication based on seizure type and patient factors
2. Baseline labs before initiation (LFTs, CBC, serum ammonia if valproate)
3. Titrate per protocol (usually 1-2 week intervals)
4. Follow-up in 4-6 weeks for efficacy assessment
5. Continue dose adjustment as needed

Questions about specific medications or interactions?
      ''');
    } catch (e) {
      _addBotMessage('❌ Error retrieving medication information: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEEGGuidance(String query) async {
    _addUserMessage(query);
    setState(() => _isLoading = true);

    try {
      String response = _knowledgeBase.generateClinicianGuidance(query);
      _addBotMessage('''
📊 EEG INTERPRETATION GUIDE

$response

═══════════════════════════════════════════

CLINICAL PEARLS:
• Normal EEG does not exclude epilepsy (20-30% of untreated epilepsy)
• Sleep-deprived EEG increases sensitivity by 30-50%
• Correlation with clinical semiology essential for diagnosis
• Consider serial EEGs if clinical suspicion high
• 24-48 hour monitoring for confirmation of seizure origin

DOCUMENTATION REQUIREMENTS:
✓ Electrode placement per 10-20 system
✓ Sampling rate documented (≥250 Hz preferred)
✓ Filter settings noted
✓ Medication effects considered
✓ Clinical correlation documented
✓ Interpreter credentials and stamp

Would you like to discuss specific EEG findings?
      ''');
    } catch (e) {
      _addBotMessage('❌ Error retrieving EEG guidance: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDrugInteractions(String query) async {
    _addUserMessage(query);
    setState(() => _isLoading = true);

    try {
      _addBotMessage('''
🔗 DRUG-DRUG INTERACTIONS REFERENCE

Common Interactions with Anti-Seizure Medications:

${MedicalKnowledgeBase.interactionDatabase.entries.map((e) => '• ${e.value}').join('')}

═══════════════════════════════════════════

MANAGEMENT STRATEGIES:

1. **Monitoring Based**
   - INR monitoring (warfarin interactions)
   - Serum levels (phenytoin, valproate)
   - ECG monitoring (lacosamide)

2. **Dose Adjustment**
   - Increase warfarin dose with enzyme inducers
   - Adjust lamotrigine with valproate co-medication
   - Monitor OCP efficacy with enzyme-inducing ASMs

3. **Medication Selection**
   - Choose ASM with minimal interactions
   - Use agents with no protein binding (LEV)
   - Consider alternative therapeutic class

4. **Alternative Approaches**
   - Separate dosing times where possible
   - Consider switching to non-interacting alternatives
   - Regular pharmacy consultation

Would you like specific interaction information for your patient?
      ''');
    } catch (e) {
      _addBotMessage('❌ Error retrieving interaction data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSafetyGuidelines(String query) async {
    _addUserMessage(query);
    setState(() => _isLoading = true);

    try {
      String response = _knowledgeBase.generateClinicianGuidance(
          'safety SUDEP driving pregnancy water');

      _addBotMessage('''
⚠️ PATIENT SAFETY GUIDELINES

$response

═══════════════════════════════════════════

SAFETY COUNSELING CHECKLIST:

□ Seizure emergency action plan discussed
□ SUDEP risk discussed (1 in 500-1000 people with epilepsy)
□ Driving restrictions reviewed per jurisdiction
□ Water safety precautions provided
□ Medication adherence emphasized
□ Trigger identification and avoidance discussed
□ Pregnancy/contraception counseling (if applicable)
□ Employment safety considerations addressed
□ First aid training for family members recommended
□ Emergency contact plan established

PATIENT EDUCATION MATERIALS NEEDED:
• Seizure First Aid Guide
• SUDEP Risk Information Sheet
• Medication Adherence Reminders
• Trigger Identification Worksheet
• Emergency Action Plan Form

Documentation reminder: Counsel patient on risks and benefits. Document discussion in chart.
      ''');
    } catch (e) {
      _addBotMessage('❌ Error retrieving safety guidelines: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _addUserMessage(message);
    setState(() => _isLoading = true);

    try {
      final lowerMessage = message.toLowerCase();

      if (lowerMessage.contains('generate report')) {
        _isLoading = false;
        await _handleGenerateReport();
        return;
      } else if (lowerMessage.contains('export pdf')) {
        _isLoading = false;
        await _handleExportPDF();
        return;
      } else if (lowerMessage.contains('medication') ||
          lowerMessage.contains('asm') ||
          lowerMessage.contains('drug')) {
        _isLoading = false;
        await _handleMedicationInfo(message);
        return;
      } else if (lowerMessage.contains('eeg') ||
          lowerMessage.contains('pattern')) {
        _isLoading = false;
        await _handleEEGGuidance(message);
        return;
      } else if (lowerMessage.contains('interact') ||
          lowerMessage.contains('warfarin') ||
          lowerMessage.contains('contraceptive')) {
        _isLoading = false;
        await _handleDrugInteractions(message);
        return;
      } else if (lowerMessage.contains('safety') ||
          lowerMessage.contains('sudep') ||
          lowerMessage.contains('drive') ||
          lowerMessage.contains('water') ||
          lowerMessage.contains('pregnan')) {
        _isLoading = false;
        await _handleSafetyGuidelines(message);
        return;
      } else {
        // General clinical query
        String response = _knowledgeBase.generateClinicianGuidance(message);

        _addBotMessage('''
🔍 CLINICAL ANALYSIS

$response

═══════════════════════════════════════════

💡 SUGGESTED FOLLOW-UP ACTIONS:
• Review relevant laboratory results
• Consider scheduling additional diagnostic testing
• Consult with specialist if needed
• Document clinical decision-making in patient chart

Need more specific information?
      ''');
      }
    } catch (e) {
      _addBotMessage('❌ Error processing query: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:       AppBar(
        title: const Text('Advanced Doctor Chatbot'),
        backgroundColor: const Color(0xFF0B8F55),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Disclaimer Banner
              Container(
                color: Color(0xFFFCD34D),
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.black87, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CLINICAL DECISION SUPPORT ONLY: All recommendations must be verified against current evidence-based guidelines.',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // Quick Commands
          if (!_isLoading)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _quickCommands.map((cmd) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        _messageController.text = cmd;
                        _sendMessage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B8F55),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        cmd,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Input Area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your clinical query...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    enabled: !_isLoading,
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: Color(0xFF0B8F55),
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
          ],
          ),
        ),
        ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.sender == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Color(0xFF0B8F55) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              message.timestamp.toString().split('.')[0],
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String sender; // 'user' or 'assistant'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}



