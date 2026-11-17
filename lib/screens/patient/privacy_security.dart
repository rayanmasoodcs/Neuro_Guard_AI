import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class PatientPrivacySecurityScreen extends StatefulWidget {
  final Map<String, dynamic>?
  patientData; // Dynamic multi-tenant configuration parameters

  const PatientPrivacySecurityScreen({super.key, this.patientData});

  @override
  State<PatientPrivacySecurityScreen> createState() =>
      _PatientPrivacySecurityScreenState();
}

class _PatientPrivacySecurityScreenState
    extends State<PatientPrivacySecurityScreen> {
  bool biometricLogin = true;
  bool shareHealthData = false;
  bool emergencyAccess = true;
  bool rememberDevice = true;
  bool appLock = false;

  bool isLoading = true; // Tracks the state synchronization phase on startup
  bool isSaving =
      false; // Controls loading layout lifecycle inside the save changes button

  @override
  void initState() {
    super.initState();
    _loadPrivacyFromDatabase();
  }

  // 1. Fetch saved toggle states from database on screen startup
  Future<void> _loadPrivacyFromDatabase() async {
    final int activeUserId =
        widget.patientData?['id'] ??
        widget.patientData?['ID'] ??
        widget.patientData?['user_pk_id'] ??
        2;

    final String url =
        "${AppConfig.baseUrl}/get_privacy_settings/$activeUserId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['settings'] != null) {
          final settings = data['settings'];
          setState(() {
            // Decodes standard 0 or 1 integer flags into valid widget form values
            biometricLogin =
                settings['biometric_login'] == 1 ||
                settings['biometric_login'] == true;
            shareHealthData =
                settings['share_health_data'] == 1 ||
                settings['share_health_data'] == true;
            emergencyAccess =
                settings['emergency_access'] == 1 ||
                settings['emergency_access'] == true;
            rememberDevice =
                settings['remember_device'] == 1 ||
                settings['remember_device'] == true;
            appLock = settings['app_lock'] == 1 || settings['app_lock'] == true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading privacy profiles: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 2. Save current privacy preferences to the database via API post request
  Future<void> _savePrivacyToDatabase() async {
    setState(() => isSaving = true);

    final int activeUserId =
        widget.patientData?['id'] ??
        widget.patientData?['ID'] ??
        widget.patientData?['user_pk_id'] ??
        2;

    String url = "${AppConfig.baseUrl}/save_privacy_settings";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": activeUserId,
          "biometric_login": biometricLogin,
          "share_health_data": shareHealthData,
          "emergency_access": emergencyAccess,
          "remember_device": rememberDevice,
          "app_lock": appLock,
        }),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == 'success') {
        GlobalRefreshNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Privacy and Security settings updated successfully!",
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
          content: Text("Failed to process server update: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
          "Privacy & Security",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: Color(0xff0B8F55)),
              )
            : RefreshIndicator(
                color: Color(0xff0B8F55),
                onRefresh: _loadPrivacyFromDatabase,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  children: [
                    Text(
                      "Privacy & Security Settings",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Manage your account privacy and security preferences.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: Icon(
                              Icons.fingerprint,
                              color: Color(0xff0B8F55),
                            ),
                            title: Text("Biometric Login"),
                            value: biometricLogin,
                            onChanged: (value) {
                              setState(() {
                                biometricLogin = value;
                              });
                            },
                          ),
                          Divider(height: 1),
                          SwitchListTile(
                            secondary: Icon(
                              Icons.health_and_safety,
                              color: Colors.red,
                            ),
                            title: Text("Share Health Data"),
                            value: shareHealthData,
                            onChanged: (value) {
                              setState(() {
                                shareHealthData = value;
                              });
                            },
                          ),
                          Divider(height: 1),
                          SwitchListTile(
                            secondary: Icon(
                              Icons.emergency,
                              color: Colors.orange,
                            ),
                            title: Text("Emergency Access"),
                            subtitle: Text(
                              "Allow emergency access during critical situations",
                            ),
                            value: emergencyAccess,
                            onChanged: (value) {
                              setState(() {
                                emergencyAccess = value;
                              });
                            },
                          ),
                          Divider(height: 1),
                          SwitchListTile(
                            secondary: Icon(
                              Icons.devices,
                              color: Color(0xFF2E7D32),
                            ),
                            title: Text("Remember This Device"),
                            value: rememberDevice,
                            onChanged: (value) {
                              setState(() {
                                rememberDevice = value;
                              });
                            },
                          ),
                          Divider(height: 1),
                          SwitchListTile(
                            secondary: Icon(
                              Icons.lock,
                              color: Color(0xFF0B8F55),
                            ),
                            title: Text(AppLocalizations.of(context).appLock),
                            subtitle: Text(
                              "Require authentication when opening the app",
                            ),
                            value: appLock,
                            onChanged: (value) {
                              setState(() {
                                appLock = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Manual Submission Action Mechanism Block
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isSaving ? null : _savePrivacyToDatabase,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 25),
                    Center(
                      child: Text(
                        "NeuroGuard AI • Patient Privacy & Security",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}








