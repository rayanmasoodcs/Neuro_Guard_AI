import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class PrivacySecurityScreen extends StatefulWidget {
  final int userId;

  const PrivacySecurityScreen({
    super.key,
    this.userId = 1,
  });

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool profileVisibility = true;
  bool shareActivity = true;
  bool allowMessages = true;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final String url =
        "${AppConfig.baseUrl}/get_doctor_privacy_settings/${widget.userId}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['settings'] != null) {
          final settings = data['settings'];
          setState(() {
            profileVisibility = (settings['profile_visibility'] ?? 1) == 1;
            shareActivity = (settings['share_activity'] ?? 1) == 1;
            allowMessages = (settings['allow_messages'] ?? 1) == 1;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading privacy settings: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _savePrivacySettings() async {
    setState(() {
      isSaving = true;
    });

    String url = "${AppConfig.baseUrl}/save_doctor_privacy_settings";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "profile_visibility": profileVisibility,
          "share_activity": shareActivity,
          "allow_messages": allowMessages,
        }),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == 'success') {
        GlobalRefreshNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).privacySaved),
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
          "Privacy & Security",
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
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xffE9FFF4),
                            child: Icon(
                              Icons.security,
                              color: Color(0xff0B8F55),
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Account Security",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Your medical data is protected with secure access controls.",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Security Preferences",
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
                          value: profileVisibility,
                          onChanged: (value) {
                            setState(() {
                              profileVisibility = value;
                            });
                          },
                          activeThumbColor: Color(0xff0B8F55),
                          secondary: Icon(
                            Icons.visibility,
                            color: Color(0xff0B8F55),
                          ),
                          title: Text(
                            "Profile Visibility",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Control who can view your doctor profile",
                          ),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          value: shareActivity,
                          onChanged: (value) {
                            setState(() {
                              shareActivity = value;
                            });
                          },
                          activeThumbColor: Color(0xff0B8F55),
                          secondary: Icon(
                            Icons.share,
                            color: Color(0xff0B8F55),
                          ),
                          title: Text(
                            "Share Activity",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Share your clinical activity with colleagues",
                          ),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          value: allowMessages,
                          onChanged: (value) {
                            setState(() {
                              allowMessages = value;
                            });
                          },
                          activeThumbColor: Color(0xff0B8F55),
                          secondary: Icon(
                            Icons.message_outlined,
                            color: Color(0xff0B8F55),
                          ),
                          title: Text(
                            "Allow Messages",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Allow patients to send you direct messages",
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : _savePrivacySettings,
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
                        isSaving
                            ? "Saving Settings..."
                            : "Save Security Settings",
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
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}









