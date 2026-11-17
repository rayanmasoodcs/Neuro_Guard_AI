import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final Map<String, dynamic>?
  patientData; // Captures the full logged-in user session map
  final String? userId; // Alternative fallback direct ID string

  const MedicalHistoryScreen({super.key, this.patientData, this.userId});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  Map<String, dynamic>? _historyData;
  List<dynamic> _medicinesList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMedicalHistory();
  }

  Future<void> _fetchMedicalHistory() async {
    // Prioritize session maps first, then explicit string variables, then user ID 2 (Sarah ch)
    final String activeId =
        widget.patientData?['id']?.toString() ??
        widget.patientData?['ID']?.toString() ??
        widget.patientData?['user_pk_id']?.toString() ??
        widget.userId ??
        "";

    final String url = "${AppConfig.baseUrl}/get_medical_history/$activeId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          if (mounted) {
            setState(() {
              _historyData = responseData['history'];
              _medicinesList = responseData['history']?['medicines'] ?? [];
              _errorMessage = '';
              _isLoading = false;
            });
          }
          return;
        }
      }
      setState(() {
        _errorMessage = "Could not find medical history for this account.";
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error retrieving clinical timeline logs from MySQL: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Connection error. Failed to reach backend.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

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
            : _errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(
                  watch ? 12 : Responsive.padding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Patient Medical History",
                      style: TextStyle(
                        fontSize: watch ? 20 : Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Previous diagnoses, EEG reports, medications, and seizure history will be displayed here.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: watch ? 12 : Responsive.subtitleSize(context),
                      ),
                    ),
                    SizedBox(height: 25),

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FIELD 1: Patient Name
                          _buildHistoryRow(
                            Icons.account_box_outlined,
                            "Patient Name",
                            _historyData!['name'] ??
                                _historyData!['account_name'] ??
                                "N/A",
                          ),
                          Divider(height: 24),

                          // FIELD 2: Age / Gender
                          _buildHistoryRow(
                            Icons.cake_outlined,
                            "Age / Gender",
                            "${_historyData!['age'] ?? '23'} yrs • ${_historyData!['gender'] ?? 'Male'}",
                          ),

                          // If the patient has dynamic medications assigned, display them directly underneath
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
                                padding: EdgeInsetsDirectional.only(bottom: 8.0),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF5F8FA),
                                    borderRadius: BorderRadius.circular(14),
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
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        med['frequency'] ?? "N/A",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
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





