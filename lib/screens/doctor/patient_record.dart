import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:neuroguard_ai/config/app_config.dart';

class PatientRecordScreen extends StatefulWidget {
  final String patientId; // The unique ID (e.g., "NGA-P002") passed from the list click

  const PatientRecordScreen({super.key, required this.patientId});

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen> {
  Map<String, dynamic>? _patientData;
  List<dynamic> _medicines = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPatientCompleteProfile();
  }

  Future<void> _fetchPatientCompleteProfile() async {
    final String url =
        "${AppConfig.baseUrl}/get_patient_details/${widget.patientId}";
    try {
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        setState(() {
          _patientData = responseData['patient'];
          _medicines = responseData['patient']['medicines'] ?? [];
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage =
              responseData['message'] ?? "Failed to look up medical file.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Network connection failure: Cannot reach server backend.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        backgroundColor: Color(0xff0B8F55),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Patient File: ${widget.patientId}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Summary Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Color(0xffE9FFF4),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xff0B8F55),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _patientData?['name'] ?? "N/A",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Gender: ${_patientData?['gender'] ?? 'N/A'} • Age: ${_patientData?['age'] ?? 'N/A'} Yrs",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Section: Clinical Diagnosis
                  Text(
                    "Clinical Status",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.health_and_safety,
                            "Medical Condition/Diagnostic Tag",
                            _patientData?['medical_condition'] ??
                                'No condition flagged',
                            Colors.red,
                          ),
                          Divider(),
                          _buildInfoRow(
                            Icons.analytics_outlined,
                            "Latest EEG Analysis Summary",
                            _patientData?['last_eeg_info'] ??
                                'No EEG tracking profile recorded yet.',
                            Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Section: Contact Details
                  Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.email_outlined,
                            "Email Address",
                            _patientData?['email'] ?? 'Not provided',
                            Color(0xff0B8F55),
                          ),
                          Divider(),
                          _buildInfoRow(
                            Icons.phone_android_outlined,
                            "Mobile Number",
                            _patientData?['phone'] ?? 'Not provided',
                            Color(0xff0B8F55),
                          ),
                          Divider(),
                          _buildInfoRow(
                            Icons.home_outlined,
                            "Residential Address",
                            _patientData?['address'] ?? 'Not provided',
                            Color(0xff0B8F55),
                          ),
                          Divider(),
                          _buildInfoRow(
                            Icons.contact_phone_outlined,
                            "Emergency SOS Contact",
                            _patientData?['emergency_contact'] ??
                                'Not provided',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Section: Active Prescription Log
                  Text(
                    "Active Medications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_medicines.isEmpty)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            "No prescribed medications logged for this patient.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._medicines.map(
                      (med) => Card(
                        elevation: 2,
                        margin: EdgeInsetsDirectional.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xffE9FFF4),
                            child: Icon(
                              Icons.medication,
                              color: Color(0xff0B8F55),
                            ),
                          ),
                          title: Text(
                            med['medicine_name'] ?? 'Generic',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Dose: ${med['dose'] ?? 'N/A'} • Frequency: ${med['frequency'] ?? 'N/A'}",
                          ),
                          trailing: Text(
                            med['timing'] ?? 'As directed',
                            style: TextStyle(
                              color: Color(0xff0B8F55),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      "NeuroGuard AI • Confidential Clinical File",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}




