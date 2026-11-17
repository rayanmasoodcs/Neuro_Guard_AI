import 'package:flutter/material.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String? patientId; // Accepts active patient ID context dynamically

  const MedicalHistoryScreen({super.key, this.patientId});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  Map<String, dynamic>? _historyData;
  List<dynamic> _medicinesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicalHistory();
  }

  Future<void> _fetchMedicalHistory() async {
    final String activeId = widget.patientId ?? "02";
    final String url = "${AppConfig.baseUrl}/get_medical_history/$activeId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _historyData = responseData['history'];
            _medicinesList = responseData['history']?['medicines'] ?? [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error retrieving clinical timeline logs: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        backgroundColor: Color(0xff0B8F55),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Medical History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: Color(0xff0B8F55)),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.padding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PRESERVED ORIGINAL SCREENSHOT HEADER UI
                    Text(
                      "Patient Medical History",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Previous diagnoses, EEG reports, medications, and seizure history will be displayed here.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: Responsive.subtitleSize(context),
                      ),
                    ),
                    SizedBox(height: 25),

                    // PRESERVED SCREENSHOT CENTER CARD CONTAINER WITH REPAIRED LAYOUT LOGIC
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(24),
                      child: _historyData == null
                          ? Center(
                              child: Text(
                                "History records will appear hereafter fetching data from the database.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHistoryRow(
                                  Icons.account_box_outlined,
                                  "Patient Name",
                                  _historyData!['name'] ?? "N/A",
                                ),
                                Divider(height: 24),
                                _buildHistoryRow(
                                  Icons.cake_outlined,
                                  "Age / Gender",
                                  "${_historyData!['age'] ?? 'N/A'} yrs • ${_historyData!['gender'] ?? 'N/A'}",
                                ),
                                Divider(height: 24),
                                _buildHistoryRow(
                                  Icons.healing_outlined,
                                  "Current Condition",
                                  _historyData!['medical_condition'] ??
                                      "General Review",
                                ),

                                // DYNAMIC CONDITIONAL REMOVAL RULE: Skips rendering rows cleanly if data is absent
                                if (_historyData!['last_eeg_info'] != null &&
                                    _historyData!['last_eeg_info']
                                        .toString()
                                        .trim()
                                        .isNotEmpty &&
                                    _historyData!['last_eeg_info'] !=
                                        "No EEG processed yet") ...[
                                  Divider(height: 24),
                                  _buildHistoryRow(
                                    Icons.analytics_outlined,
                                    "Last EEG Tracking Assessment",
                                    _historyData!['last_eeg_info'],
                                  ),
                                ],

                                if (_historyData!['additional_notes'] != null &&
                                    _historyData!['additional_notes']
                                        .toString()
                                        .trim()
                                        .isNotEmpty &&
                                    _historyData!['additional_notes'] !=
                                        "nothing") ...[
                                  Divider(height: 24),
                                  _buildHistoryRow(
                                    Icons.description_outlined,
                                    "Clinical Notes / History",
                                    _historyData!['additional_notes'],
                                  ),
                                ],

                                // DYNAMIC MEDICINES SECTION: Renders professionally when records exist
                                if (_medicinesList.isNotEmpty) ...[
                                  Divider(height: 24),
                                  SizedBox(height: 5),
                                  Text(
                                    "Active Prescribed Medications",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xff0B8F55),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ..._medicinesList.map((med) {
                                    return Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        bottom: 8.0,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Color(0xffF5F8FA),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.medication_outlined,
                                              color: Color(0xff0B8F55),
                                              size: 18,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "${med['medicine_name']} (${med['dose']})",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              med['frequency'] ?? "N/A",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHistoryRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Color(0xffE9FFF4),
          radius: 20,
          child: Icon(icon, color: Color(0xff0B8F55), size: 20),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}





