import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class NotificationSettingsScreen extends StatefulWidget {
  // FIXED: Now receives the core session map cleanly from active log-in templates
  final Map<String, dynamic>? patientData;

  const NotificationSettingsScreen({super.key, this.patientData});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool notificationsEnabled = true;
  bool emergencyAlerts = true;
  bool aiAlerts = true;
  bool patientUpdates = true;

  bool isLoading = true; // Tracks the loading state from backend on startup
  bool isSaving = false; // Controls saving indicator inside the button

  @override
  void initState() {
    super.initState();
    _loadSettingsFromDatabase();
  }

  // 1. Fetch saved toggle states from database on screen startup
  Future<void> _loadSettingsFromDatabase() async {
    final int activeUserId =
        widget.patientData?['id'] ??
        widget.patientData?['ID'] ??
        widget.patientData?['user_pk_id'] ??
        2;

    final String url =
        "${AppConfig.baseUrl}/get_notification_settings/$activeUserId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['settings'] != null) {
          final settings = data['settings'];
          setState(() {
            // FIXED: Converts database integer bit-flags (0 or 1) safely into widget boolean flags
            notificationsEnabled =
                settings['all_notifications'] == 1 ||
                settings['all_notifications'] == true;
            emergencyAlerts =
                settings['emergency_alerts'] == 1 ||
                settings['emergency_alerts'] == true;
            aiAlerts =
                settings['ai_alerts'] == 1 || settings['ai_alerts'] == true;
            patientUpdates =
                settings['patient_updates'] == 1 ||
                settings['patient_updates'] == true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 2. Save current toggle states back to the database
  Future<void> _saveSettingsToDatabase() async {
    setState(() {
      isSaving = true;
    });

    final int activeUserId =
        widget.patientData?['id'] ??
        widget.patientData?['ID'] ??
        widget.patientData?['user_pk_id'] ??
        2;

    String url = "${AppConfig.baseUrl}/save_notification_settings";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": activeUserId,
          "all_notifications":
              notificationsEnabled, // Sends true/false directly
          "emergency_alerts": emergencyAlerts, // Sends true/false directly
          "ai_alerts": aiAlerts, // Sends true/false directly
          "patient_updates": patientUpdates, // Sends true/false directly
        }),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == 'success') {
        GlobalRefreshNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Notification settings saved to database successfully!",
            ),
            backgroundColor: Color(0xff0B8F55),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${result['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to connect: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),

      appBar: AppBar(
        backgroundColor: Color(0xff0B8F55),

        elevation: 0,

        title: Text(
          "Notification Settings",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Color(0xff0B8F55)),
            )
          : RefreshIndicator(
              color: Color(0xff0B8F55),
              onRefresh: _loadSettingsFromDatabase,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(Responsive.padding(context)),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Card(
                      elevation: 4,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: SwitchListTile(
                        value: notificationsEnabled,

                        onChanged: (value) {
                          setState(() {
                            notificationsEnabled = value;
                          });
                        },

                        activeThumbColor: Color(0xff0B8F55),

                        secondary: CircleAvatar(
                          backgroundColor: Color(0xffE9FFF4),

                          child: Icon(
                            Icons.notifications_active,

                            color: Color(0xff0B8F55),
                          ),
                        ),

                        title: Text(
                          "All Notifications",

                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(
                          "Enable or disable all app notifications",
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      "Alert Preferences",

                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),
                    Card(
                      elevation: 4,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Column(
                        children: [
                          SwitchListTile(
                            value: emergencyAlerts,

                            onChanged: notificationsEnabled
                                ? (value) {
                                    setState(() {
                                      emergencyAlerts = value;
                                    });
                                  }
                                : null,

                            activeThumbColor: Color(0xff0B8F55),

                            secondary: Icon(
                              Icons.warning_amber_rounded,

                              color: Colors.red,
                            ),

                            title: Text(
                              "Emergency Alerts",

                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            subtitle: Text(
                              "Receive urgent patient seizure alerts",
                            ),
                          ),

                          Divider(height: 1),

                          SwitchListTile(
                            value: aiAlerts,

                            onChanged: notificationsEnabled
                                ? (value) {
                                    setState(() {
                                      aiAlerts = value;
                                    });
                                  }
                                : null,

                            activeThumbColor: Color(0xff0B8F55),

                            secondary: Icon(
                              Icons.psychology,

                              color: Color(0xff0B8F55),
                            ),

                            title: Text(
                              "AI Prediction Alerts",

                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            subtitle: Text(
                              "Get AI seizure prediction updates",
                            ),
                          ),

                          Divider(height: 1),

                          SwitchListTile(
                            value: patientUpdates,

                            onChanged: notificationsEnabled
                                ? (value) {
                                    setState(() {
                                      patientUpdates = value;
                                    });
                                  }
                                : null,

                            activeThumbColor: Color(0xff0B8F55),

                            secondary: Icon(
                              Icons.people_alt_outlined,

                              color: Color(0xff0B8F55),
                            ),

                            title: Text(
                              "Patient Updates",

                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            subtitle: Text(
                              "Receive patient activity updates",
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,

                      child: FilledButton.icon(
                        onPressed: isSaving ? null : _saveSettingsToDatabase,

                        icon: isSaving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.save),

                        label: Text(
                          isSaving ? "Saving Settings..." : "Save Settings",

                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        style: FilledButton.styleFrom(
                          backgroundColor: Color(0xff0B8F55),

                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}




