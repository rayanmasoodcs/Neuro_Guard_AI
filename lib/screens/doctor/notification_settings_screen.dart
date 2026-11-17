import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final dynamic userId;

  const NotificationSettingsScreen({
    super.key,
    this.userId = 1,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool notificationsEnabled = true;
  bool emailNotifications = true;
  bool appointmentAlerts = true;
  bool reminderAlerts = true;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsFromDatabase();
  }

  Future<void> _loadSettingsFromDatabase() async {
    final String url =
        "${AppConfig.baseUrl}/get_doctor_notification_settings/${widget.userId}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['settings'] != null) {
          final settings = data['settings'];
          setState(() {
            notificationsEnabled = (settings['push_notifications'] ?? settings['all_notifications'] ?? 1) == 1;
            emailNotifications = settings['email_notifications'] ?? true;
            appointmentAlerts = settings['appointment_notifications'] ?? true;
            reminderAlerts = settings['reminder_notifications'] ?? true;
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

  Future<void> _saveSettingsToDatabase() async {
    setState(() {
      isSaving = true;
    });

    String url = "${AppConfig.baseUrl}/save_doctor_notification_settings";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "push_notifications": notificationsEnabled,
          "email_notifications": emailNotifications,
          "appointment_notifications": appointmentAlerts,
          "reminder_notifications": reminderAlerts,
        }),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == 'success') {
        GlobalRefreshNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).notificationsSaved),
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
          : SingleChildScrollView(
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
                          value: emailNotifications,
                          onChanged: notificationsEnabled
                              ? (value) {
                                  setState(() {
                                    emailNotifications = value;
                                  });
                                }
                              : null,
                          activeThumbColor: Color(0xff0B8F55),
                          secondary: Icon(
                            Icons.email_outlined,
                            color: Color(0xff0B8F55),
                          ),
                          title: Text(
                            "Email Notifications",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Receive email notifications for important updates",
                          ),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          value: appointmentAlerts,
                          onChanged: notificationsEnabled
                              ? (value) {
                                  setState(() {
                                    appointmentAlerts = value;
                                  });
                                }
                              : null,
                          activeThumbColor: Color(0xff0B8F55),
                          secondary: Icon(
                            Icons.calendar_today,
                            color: Color(0xff0B8F55),
                          ),
                          title: Text(
                            "Appointment Notifications",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Receive appointment scheduling alerts",
                          ),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          value: reminderAlerts,
                          onChanged: notificationsEnabled
                              ? (value) {
                                  setState(() {
                                    reminderAlerts = value;
                                  });
                                }
                              : null,
                          activeThumbColor: Color(0xff0B8F55),
                          secondary: Icon(
                            Icons.alarm,
                            color: Color(0xff0B8F55),
                          ),
                          title: Text(
                            "Reminder Notifications",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Receive medication and task reminders",
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
    );
  }
}









