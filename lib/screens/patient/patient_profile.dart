import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import 'notification_setting.dart';
import 'change_password.dart';
import 'privacy_security.dart';
import 'edit_profile.dart';
import '../auth/login_screen.dart';
import '../../services/language_service.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class PatientProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const PatientProfileScreen({super.key, this.patientData});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  Map<String, dynamic>? _profileMap;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountProfileLogs();
  }

  Future<void> _fetchAccountProfileLogs() async {
    final int targetUserId =
        widget.patientData?['id'] ??
        widget.patientData?['ID'] ??
        widget.patientData?['user']?['id'] ??
        2;

    final String url =
        "${AppConfig.baseUrl}/get_medical_history/$targetUserId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['history'] != null) {
          if (mounted) {
            setState(() {
              _profileMap = responseData['history'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Profile account records sync error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Are you sure you want to log out of your profile?",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog pop up

                // Native routing solution resets the session stack tracking safely
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(languageProvider: LanguageProvider.instance)),
                  (route) => false,
                );
              },
              child: Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    final String dynamicName =
        _profileMap?['name'] ??
        _profileMap?['account_name'] ??
        widget.patientData?['name'] ??
        "Patient Name";

    final String dynamicEmail =
        _profileMap?['email'] ??
        _profileMap?['account_email'] ??
        widget.patientData?['email'] ??
        "patient@email.com";

    final String dynamicPid = _profileMap?['patient_id'] ?? "NGA-P001";

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        backgroundColor: Color(0xff0B8F55),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Patient Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoadingProfile
            ? Center(
                child: CircularProgressIndicator(color: Color(0xff0B8F55)),
              )
            : RefreshIndicator(
                color: Color(0xff0B8F55),
                onRefresh: _fetchAccountProfileLogs,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  child: Column(
                    children: [
                      // Header Profile Container Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(Responsive.padding(context)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff0B8F55), Color(0xff22C55E)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: watch ? 40 : 60,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: watch ? 42 : 60,
                                color: Color(0xff0B8F55),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              dynamicName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Patient ID : $dynamicPid",
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 5),
                            Text(
                              dynamicEmail,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context)),

                      // Settings Options Panel List Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xffE9FFF4),
                                child: Icon(
                                  Icons.person_outline,
                                  color: Color(0xff0B8F55),
                                ),
                              ),
                              title: Text(
                                "Edit Profile",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      patientData:
                                          _profileMap ?? widget.patientData,
                                    ),
                                  ),
                                ).then((shouldRefresh) {
                                  if (shouldRefresh == true) {
                                    _fetchAccountProfileLogs();
                                  }
                                });
                              },
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xffE9FFF4),
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xff0B8F55),
                                ),
                              ),
                              title: Text(
                                "Change Password",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientChangePasswordScreen(
                                          patientData:
                                              _profileMap ?? widget.patientData,
                                        ),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xffE9FFF4),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xff0B8F55),
                                ),
                              ),
                              title: Text(
                                "Notification Settings",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationSettingsScreen(
                                          patientData: _profileMap ?? widget.patientData,
                                        ),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xffE9FFF4),
                                child: Icon(
                                  Icons.security_outlined,
                                  color: Color(0xff0B8F55),
                                ),
                              ),
                              title: Text(
                                "Privacy & Security",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientPrivacySecurityScreen(
                                          patientData: _profileMap ?? widget.patientData,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context)),

                      // Logout Execution Panel Button Section
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: Icon(Icons.logout),
                          label: Text(
                            "Logout",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context)),
                      Divider(),
                      SizedBox(height: 15),
                      Text(
                        "NeuroGuard AI",
                        style: TextStyle(
                          color: Color(0xff0B8F55),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Patient Profile • Version 1.0.0",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}




