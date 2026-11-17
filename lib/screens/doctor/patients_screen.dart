import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import 'add_patient_screen.dart';
import 'update_patient_screen.dart';
import 'medication_screen.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class PatientsScreen extends StatefulWidget {
  final Map<String, dynamic>? doctorData; // Dynamic multi-tenant session map

  const PatientsScreen({super.key, this.doctorData});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  int totalPatients = 0;
  int criticalPatients = 0;
  int stablePatients = 0;

  List<dynamic> allPatientsList = [];
  List<dynamic> filteredPatientsList = []; // Holds matching search entries

  bool isLoadingStats = true;
  bool isLoadingList = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchScreenMetrics();
    _fetchAllPatients();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPatientsList = allPatientsList;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      filteredPatientsList = allPatientsList.where((patient) {
        final String name = (patient['name'] ?? "").toString().toLowerCase();
        final String condition = (patient['medical_condition'] ?? "")
            .toString()
            .toLowerCase();
        return name.contains(lowercaseQuery) ||
            condition.contains(lowercaseQuery);
      }).toList();
    });
  }

  Future<void> _fetchScreenMetrics() async {
    final int docId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    final String url =
        "${AppConfig.baseUrl}/get_patient_screen_stats?doctor_id=$docId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            totalPatients = data['total'] ?? 0;
            criticalPatients = data['critical'] ?? 0;
            stablePatients = data['stable'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading calculation counts: $e");
    } finally {
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  Future<void> _fetchAllPatients() async {
    final int docId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    final String url =
        "${AppConfig.baseUrl}/get_all_patients?doctor_id=$docId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['patients'] != null) {
          setState(() {
            allPatientsList = data['patients'];
            filteredPatientsList = data['patients'];
          });
          if (searchController.text.isNotEmpty) {
            _filterSearch(searchController.text);
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading database array entries: $e");
    } finally {
      setState(() {
        isLoadingList = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(watch ? 12 : Responsive.padding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patients",
              style: TextStyle(
                fontSize: watch ? 22 : Responsive.titleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Manage, monitor and review all registered patients.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: watch ? 12 : Responsive.subtitleSize(context),
              ),
            ),
            SizedBox(height: Responsive.spacing(context)),

            // 1. SEARCH FIELD (TOP OF PAGE)
            TextField(
              controller: searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchPatient,
                prefixIcon: Icon(Icons.search, color: Color(0xff0B8F55)),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                          _filterSearch("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0B8F55),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            SizedBox(height: Responsive.spacing(context)),

            // 2. PATIENT LIST (MOVED ABOVE STATISTICS)
            Text(
              "Patient List",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: watch ? 18 : Responsive.titleSize(context),
              ),
            ),
            SizedBox(height: 15),

            isLoadingList
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: Color(0xff0B8F55),
                      ),
                    ),
                  )
                : filteredPatientsList.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No patient records match your criteria.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(filteredPatientsList.length, (
                      index,
                    ) {
                      final patient = filteredPatientsList[index];
                      final String pName = patient['name'] ?? "Unknown Patient";
                      final int pAge = patient['age'] ?? 0;
                      final String pCondition =
                          patient['medical_condition'] ?? "General Review";

                      String statusLabel = "Stable";
                      Color statusColor = Colors.green;

                      if (pCondition.contains("Emergency") ||
                          pCondition == "Need Urgent Review") {
                        statusLabel = "Emergency";
                        statusColor = Colors.red;
                      } else if (pCondition == "Critical") {
                        statusLabel = "Critical";
                        statusColor = Colors.redAccent;
                      } else if (pCondition == "Observation Required" ||
                          pCondition == "Observation") {
                        statusLabel = "Observation";
                        statusColor = Colors.orange;
                      }

                      return Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 10),
                        child: _patientCard(
                          name: pName,
                          age: "$pAge Years",
                          status: statusLabel,
                          statusColor: statusColor,
                        ),
                      );
                    }),
                  ),

            SizedBox(height: Responsive.spacing(context)),

            // 3. PATIENT STATISTICS BLOCK CARD (MOVED BELOW LIST)
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  watch ? 12 : Responsive.padding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Patient Statistics",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: watch ? 16 : 20,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(
                          isLoadingStats ? "..." : totalPatients.toString(),
                          "Total",
                          Color(0xFF2E7D32),
                        ),
                        _statItem(
                          isLoadingStats
                              ? "..."
                              : criticalPatients.toString().padLeft(2, '0'),
                          "Critical",
                          Colors.red,
                        ),
                        _statItem(
                          isLoadingStats ? "..." : stablePatients.toString(),
                          "Stable",
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: Responsive.spacing(context) * 1.5),

            // 4. QUICK ACTIONS PANEL
            Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: watch ? 18 : Responsive.titleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddPatientScreen(doctorData: widget.doctorData),
                      ),
                    ).then((_) {
                      _fetchScreenMetrics();
                      _fetchAllPatients();
                    });
                  },
                  icon: Icon(Icons.person_add),
                  label: Text(AppLocalizations.of(context).addPatient),
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xff0B8F55),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdatePatientScreen(doctorData: widget.doctorData),
                      ),
                    ).then((_) {
                      _fetchScreenMetrics();
                      _fetchAllPatients();
                    });
                  },
                  icon: Icon(Icons.edit),
                  label: Text(AppLocalizations.of(context).updatePatient),
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xff0B8F55),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicationScreen(doctorData: widget.doctorData),
                      ),
                    );
                  },
                  icon: Icon(Icons.medication),
                  label: Text(AppLocalizations.of(context).medicationType),
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xff0B8F55),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(context)),
            SizedBox(height: Responsive.spacing(context) * 1.5),
            Center(
              child: Column(
                children: [
                  Divider(),
                  SizedBox(height: 15),
                  Text(
                    "NeuroGuard AI",
                    style: TextStyle(
                      color: Color(0xff0B8F55),
                      fontWeight: FontWeight.bold,
                      fontSize: watch ? 14 : Responsive.subtitleSize(context),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "AI Powered Epileptic Seizure Monitoring System",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Patients • Version 1.0.0",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "© 2026 NeuroGuard AI",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientCard({
    required String name,
    required String age,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(Icons.person, color: Color(0xff0B8F55)),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Age: $age"),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _statItem(String value, String title, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}











