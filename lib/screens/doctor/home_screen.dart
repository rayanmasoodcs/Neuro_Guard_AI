import 'package:flutter/material.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'update_patient_screen.dart';
import 'upload_eeg_screen.dart';
import 'notification_settings_screen.dart';
import 'patient_record.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>?
  doctorData; // Dynamic multi-tenant session parameters

  const HomeScreen({super.key, this.doctorData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Live dashboard states initialized with safe fallbacks
  int totalPatients = 0;
  int emergencyAlerts = 0;
  int eegReports = 0;
  double? modelDetectionRate;
  List<dynamic> recentPatientsList = [];
  bool isLoadingStats = true;
  bool isLoadingPatients = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardMetrics();
    _fetchRecentPatients();
  }

  bool _statsFetching = false;
  bool _patientsFetching = false;

  // Fetch count figures dynamically from your backend API matching doctor context
  Future<void> _fetchDashboardMetrics() async {
    if (_statsFetching) return;
    _statsFetching = true;

    final int docId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    final Uri uri = Uri.parse("${AppConfig.baseUrl}/get_dashboard_stats?doctor_id=$docId");

    try {
      final response = await http.get(uri).timeout(Duration(seconds: 8));
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            if (mounted) {
              setState(() {
                totalPatients = data['total_patients'] ?? 0;
                emergencyAlerts = data['emergency_count'] ?? 0;
                eegReports = data['eeg_reports'] ?? 0;
                modelDetectionRate = (data['model_detection_rate'] as num?)?.toDouble();
              });
            }
          }
        } catch (e) {
          debugPrint('Failed to parse dashboard stats JSON: $e');
        }
      }
    } on Exception catch (e) {
      debugPrint("Error fetching dashboard counters: $e");
    } finally {
      _statsFetching = false;
      if (mounted) setState(() => isLoadingStats = false);
    }
  }

  // Fetch the last 3 registered patients assigned to this doctor session
  Future<void> _fetchRecentPatients() async {
    if (_patientsFetching) return;
    _patientsFetching = true;

    final int docId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    final Uri uri = Uri.parse("${AppConfig.baseUrl}/get_recent_patients?doctor_id=$docId");

    try {
      final response = await http.get(uri).timeout(Duration(seconds: 8));
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          if (data['status'] == 'success' && data['patients'] != null) {
            if (mounted) setState(() => recentPatientsList = data['patients']);
          }
        } catch (e) {
          debugPrint('Failed to parse recent patients JSON: $e');
        }
      }
    } on Exception catch (e) {
      debugPrint("Error loading recent patient profiles: $e");
    } finally {
      _patientsFetching = false;
      if (mounted) setState(() => isLoadingPatients = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);
    final bool desktop = Responsive.isDesktop(context);
    final l10n = AppLocalizations.of(context);

    final String doctorName =
        widget.doctorData?['name'] ?? widget.doctorData?['Name'] ?? "Doctor";

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: watch ? 22 : 32,
                    backgroundColor: Color(0xff0B8F55),
                    child: Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: watch ? 22 : 32,
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.welcomeBack(doctorName).replaceAll(RegExp(r' 👋$'), ' 👋'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.titleSize(context),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          l10n.welcomeSubtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: Responsive.subtitleSize(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final int docId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationSettingsScreen(userId: docId),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xff0B8F55),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.padding(context)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Color(0xff0B8F55), Color(0xff22C55E)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todaysOverview,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.titleSize(context),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      l10n.overviewDescription,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: Responsive.subtitleSize(context),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xff0B8F55),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.analytics),
                      label: Text(l10n.viewAiAnalysis),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  if (watch) {
                    crossAxisCount = 1;
                  } else if (Responsive.isTablet(context)) {
                    crossAxisCount = 2;
                  } else if (desktop) {
                    crossAxisCount = 4;
                  } else {
                    crossAxisCount = 2;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: watch ? 2.7 : 1.15,
                    children: [
                      _statCard(
                        title: l10n.patientsStat,
                        value: isLoadingStats
                            ? "..."
                            : totalPatients.toString(),
                        icon: Icons.people_alt_rounded,
                        color: Color(0xFF2E7D32),
                      ),
                      _statCard(
                        title: l10n.eegReportsStat,
                        value: isLoadingStats ? "..." : eegReports.toString(),
                        icon: Icons.description_rounded,
                        color: Color(0xFF0B8F55),
                      ),
                      _statCard(
                        title: l10n.emergencyStat,
                        value: isLoadingStats
                            ? "..."
                            : emergencyAlerts.toString().padLeft(2, '0'),
                        icon: Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      _statCard(
                        title: l10n.aiAccuracyStat,
                        value: modelDetectionRate == null ? "n/a" : "${(modelDetectionRate! * 100).round()}%",
                        icon: Icons.psychology_rounded,
                        color: Color(0xFF0B8F55),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              Text(
                l10n.aiSummary,
                style: TextStyle(
                  fontSize: Responsive.titleSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xffE9FFF4),
                          child: Icon(
                            Icons.psychology,
                            color: Color(0xff0B8F55),
                          ),
                        ),
                        title: Text(l10n.aiPrediction),
                        subtitle: Text(l10n.aiPredictionSubtitle),
                      ),
                      Divider(),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xffFFF4E5),
                          child: Icon(
                            Icons.analytics_outlined,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(l10n.todaysAnalysis),
                        subtitle: Text(l10n.todaysAnalysisSubtitle),
                      ),
                      Divider(),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xffFFECEC),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                        ),
                        title: Text(l10n.emergencyAlerts),
                        subtitle: Text(
                          isLoadingStats
                              ? l10n.loadingAlerts
                              : l10n.emergencyAlertsSubtitle(emergencyAlerts),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              Text(
                l10n.recentPatients,
                style: TextStyle(
                  fontSize: Responsive.titleSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: isLoadingPatients
                    ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff0B8F55),
                          ),
                        ),
                      )
                    : recentPatientsList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            l10n.noPatientsYet,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: List.generate(recentPatientsList.length, (
                          index,
                        ) {
                          final patient = recentPatientsList[index];
                          final String pName =
                              patient['name'] ?? "Unknown Patient";
                          final String pCondition =
                              patient['medical_condition'] ?? "General Review";
                          final String targetPatientId =
                              patient['patient_id'] ?? "NGA-P001";

                          Color avatarColor = Color(0xff0B8F55);
                          Color bgColor = Color(0xffE9FFF4);
                          String subtitleLabel = pCondition;

                          if (pCondition == "Need Urgent Review" ||
                              pCondition == "Emergency Alert" ||
                              pCondition == "Critical") {
                            avatarColor = Colors.red;
                            bgColor = Color(0xffFFECEC);
                            subtitleLabel = "Emergency Alert";
                          } else if (pCondition == "Observation Required" ||
                              pCondition == "Observation") {
                            avatarColor = Colors.orange;
                            bgColor = Color(0xffFFF4E5);
                            subtitleLabel = "Observation Required";
                          }

                          return Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: bgColor,
                                  child: Icon(Icons.person, color: avatarColor),
                                ),
                                title: Text(
                                  pName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(subtitleLabel),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                // WIRED NAVIGATION TO PATIENT RECORD SCREEN
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientRecordScreen(
                                        patientId: targetPatientId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (index < recentPatientsList.length - 1)
                                Divider(height: 1),
                            ],
                          );
                        }),
                      ),
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              Text(
                l10n.quickActions,
                style: TextStyle(
                  fontSize: Responsive.titleSize(context),
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
                          builder: (context) => UpdatePatientScreen(
                            doctorData: widget.doctorData,
                          ),
                        ),
                      ).then((_) {
                        _fetchDashboardMetrics();
                        _fetchRecentPatients();
                      });
                    },
                    icon: Icon(Icons.edit),
                    label: Text(l10n.update),
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xff0B8F55),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadEEGScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.upload_file),
                    label: Text(l10n.uploadEeg),
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xff0B8F55),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      final int docId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationSettingsScreen(userId: docId),
                        ),
                      );
                    },
                    icon: Icon(Icons.notifications_active),
                    label: Text(l10n.alerts),
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xff0B8F55),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              Center(
                child: Column(
                  children: [
                    Divider(),
                    SizedBox(height: 15),
                    Text(
                      l10n.appName,
                      style: TextStyle(
                        color: Color(0xff0B8F55),
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.subtitleSize(context),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      l10n.appTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Doctor Home • ${l10n.version}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      l10n.copyright,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}






