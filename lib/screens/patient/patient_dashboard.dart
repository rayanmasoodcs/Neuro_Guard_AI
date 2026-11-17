import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import 'view_medication.dart';
import 'view_healthreport.dart';
import 'patient_profile.dart';
import 'history_screen.dart';
import 'reminder_screen.dart';
import 'call_screen.dart';
import 'realtime_sensor_data_screen.dart';
import 'chatbot_screen.dart';
import 'prediction_and_sensor_dashboard.dart';
import 'package:neuroguard_ai/config/app_config.dart';
import 'dart:async';
import '../../services/sensor_data_service.dart';
import '../../models/sensor_data_model.dart';
import '../../services/firebase_auth_helper.dart';

class PatientHomeScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const PatientHomeScreen({super.key, this.patientData});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  List<dynamic> _medicinesList = [];
  bool _isLoadingData = true;

  int _medicationCount = 0;
  int _reminderCount = 0;
  int _appointmentCount = 0;

  SensorDataModel? _latestSensorData;
  StreamSubscription? _sensorSub;
  String _latestPredictionMsg = "Fetching latest prediction...";

  String get _activeId =>
      widget.patientData?['id']?.toString() ??
      widget.patientData?['ID']?.toString() ??
      widget.patientData?['user_pk_id']?.toString() ??
      "";

  @override
  void initState() {
    super.initState();
    _fetchDynamicDashboardMetrics();
    _sensorSub = SensorDataService().sensorDataStream.listen((data) {
      if (mounted) {
        setState(() {
          _latestSensorData = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchDynamicDashboardMetrics() async {
    final String activeId = _activeId;

    try {
      final headers = await FirebaseAuthHelper.getAuthenticatedHeaders();
      // Fetch Medications, Reminders, and Prediction in parallel
      final medResponse = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_medications/$activeId"),
        headers: headers,
      );
      final remResponse = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_reminders/$activeId"),
        headers: headers,
      );
      final predResponse = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_latest_prediction"),
        headers: headers,
      );

      List<dynamic> fetchedMedicines = [];
      List<dynamic> fetchedReminders = [];
      String fetchedPrediction = "No recent prediction data.";

      if (medResponse.statusCode == 200) {
        final medData = jsonDecode(medResponse.body);
        if (medData['status'] == 'success') {
          fetchedMedicines = medData['medications'] ?? [];
        }
      }

      if (remResponse.statusCode == 200) {
        final remData = jsonDecode(remResponse.body);
        if (remData['status'] == 'success') {
          fetchedReminders = remData['reminders'] ?? [];
        }
      }

      if (predResponse.statusCode == 200) {
        final predData = jsonDecode(predResponse.body);
        if (predData['status'] == 'success' && predData['prediction'] != null) {
          fetchedPrediction = predData['prediction']['predictionResult'] ?? "No recent prediction data.";
        }
      }

      if (mounted) {
        setState(() {
          _medicinesList = fetchedMedicines;
          _medicationCount = fetchedMedicines.length;

          // Filter Reminders (Pill/Medication)
          _reminderCount = fetchedReminders
              .where(
                (r) =>
                    r['reminder_type'] == 'Medication' ||
                    r['reminder_type'] == 'Pill',
              )
              .length;

          // Filter Appointments (Doctor Visits)
          _appointmentCount = fetchedReminders
              .where(
                (r) =>
                    r['reminder_type'] == 'Appointment' ||
                    r['reminder_type'] == 'Doctor Visit',
              )
              .length;

          _latestPredictionMsg = fetchedPrediction;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint("Error syncing dynamic dashboard metrics: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);
    final bool desktop = Responsive.isDesktop(context);

    final String currentPatientName =
        widget.patientData?['name'] ?? "Patient User";

    return SafeArea(
      child: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff0B8F55)),
            )
          : RefreshIndicator(
              color: const Color(0xff0B8F55),
              onRefresh: _fetchDynamicDashboardMetrics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(Responsive.padding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: watch ? 24 : 32,
                          backgroundColor: const Color(0xff0B8F55),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: watch ? 24 : 32,
                          ),
                        ),
                        SizedBox(width: Responsive.spacing(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back, $currentPatientName 👋",
                                style: TextStyle(
                                  fontSize: Responsive.titleSize(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Stay healthy and follow your treatment plan.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: Responsive.subtitleSize(context),
                                ),
                              ),
                            ],
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
                        gradient: const LinearGradient(
                          colors: [Color(0xff0B8F55), Color(0xff22C55E)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Health Status",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.titleSize(context),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _latestPredictionMsg,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.subtitleSize(context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xff0B8F55),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ViewHealthReportScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.health_and_safety),
                                  label: const Text("View Health Report"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xff0B8F55),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PredictionAndSensorDashboard(
                                              userId: int.tryParse(_activeId) ?? 0,
                                              patientId: _activeId,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.sensors),
                                  label: const Text("Live Sensors"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xff0B8F55),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatbotScreen(userId: _activeId),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat_rounded),
                              label: const Text("Chat with AI Assistant"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Responsive.spacing(context) * 1.5),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = watch ? 1 : (desktop ? 4 : 2);

                        Widget statCard({
                          required String title,
                          required String value,
                          required IconData icon,
                          required Color color,
                          required Color colorBackground,
                          VoidCallback? onTap,
                        }) {
                          return GestureDetector(
                            onTap: onTap,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: colorBackground,
                                      child: Icon(icon, color: color, size: 30),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      value,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: watch ? 2.5 : 1.15,
                          children: [
                            statCard(
                              title: "Medication",
                              value: "$_medicationCount",
                              icon: Icons.medication,
                              color: const Color(0xFF2E7D32),
                              colorBackground: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                            ),
                            statCard(
                              title: "Reminders",
                              value: "$_reminderCount",
                              icon: Icons.alarm,
                              color: Colors.orange,
                              colorBackground: Colors.orange.withValues(alpha: 0.15),
                            ),
                            statCard(
                              title: "Appointments",
                              value: "$_appointmentCount",
                              icon: Icons.calendar_month,
                              color: Colors.green,
                              colorBackground: Colors.green.withValues(alpha: 0.15),
                            ),
                            statCard(
                              title: "Live Sensors",
                              value: "5",
                              icon: Icons.sensors,
                              color: Colors.red,
                              colorBackground: Colors.red.withValues(alpha: 0.15),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PredictionAndSensorDashboard(
                                          userId: int.tryParse(_activeId) ?? 0,
                                          patientId: _activeId,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: Responsive.spacing(context) * 1.5),

                    Text(
                      "Medication Reminder",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: _medicinesList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  "No medications prescribed yet.",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: List.generate(_medicinesList.length, (
                                index,
                              ) {
                                final med = _medicinesList[index];
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: index % 2 == 0
                                            ? const Color(0xffE9FFF4)
                                            : const Color(0xffFFF4E5),
                                        child: Icon(
                                          Icons.medication,
                                          color: index % 2 == 0
                                              ? const Color(0xff0B8F55)
                                              : Colors.orange,
                                        ),
                                      ),
                                      title: Text(
                                        med['medicine_name'] ?? "Unknown",
                                      ),
                                      subtitle: Text(
                                        "${med['timing']} • ${med['dose']} (${med['frequency']})",
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewMedicationScreen(
                                                userId: _activeId,
                                              ),
                                        ),
                                      ).then((_) => _fetchDynamicDashboardMetrics()),
                                    ),
                                    if (index != _medicinesList.length - 1)
                                      const Divider(height: 1),
                                  ],
                                );
                              }),
                            ),
                    ),

                    SizedBox(height: Responsive.spacing(context) * 1.5),

                    Text(
                      "Health Parameters",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildParameterBox(
                                    title: "Heart Rate",
                                    value: _latestSensorData?.heartRate?.toStringAsFixed(1) ?? "--",
                                    unit: "bpm",
                                    icon: Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildParameterBox(
                                    title: "Temperature",
                                    value: _latestSensorData?.bodyTemperature?.toStringAsFixed(1) ?? "--",
                                    unit: "°C",
                                    icon: Icons.thermostat,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildParameterBox(
                                    title: "O2 Saturation",
                                    value: "98", // Usually SP02 is not in BLE stream, keeping static or map later
                                    unit: "%",
                                    icon: Icons.air,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildParameterBox(
                                    title: "Motion",
                                    value: _latestSensorData?.getMotionIntensity() ?? "--",
                                    unit: "Activity",
                                    icon: Icons.trending_up,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B8F55),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PredictionAndSensorDashboard(
                                            userId: int.tryParse(_activeId) ?? 0,
                                            patientId: _activeId,
                                          ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.show_chart),
                                label: const Text("View Detailed Sensor Analysis"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: Responsive.spacing(context) * 1.5),

                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewMedicationScreen(
                                    userId: _activeId,
                                  ),
                            ),
                          ).then((_) => _fetchDynamicDashboardMetrics()),
                          icon: const Icon(Icons.medication),
                          label: const Text("Medication"),
                        ),
                        FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RemindersScreen(
                                patientId: _activeId,
                              ),
                            ),
                          ).then((_) => _fetchDynamicDashboardMetrics()),
                          icon: const Icon(Icons.alarm),
                          label: const Text("Reminder"),
                        ),
                        FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicalHistoryScreen(
                                patientData: widget.patientData,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.history),
                          label: const Text("History"),
                        ),
                        FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientProfileScreen(
                                patientData: widget.patientData,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.person),
                          label: const Text("Profile"),
                        ),
                      ],
                    ),

                    SizedBox(height: Responsive.spacing(context) * 1.5),

                    Text(
                      "Emergency Contact",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xffFFECEC),
                          child: Icon(Icons.phone_in_talk, color: Colors.red),
                        ),
                        title: const Text("Emergency Helpline"),
                        subtitle: const Text("+92 300 1234567"),
                        trailing: FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallScreen(
                                patientData: widget.patientData,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildParameterBox({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



