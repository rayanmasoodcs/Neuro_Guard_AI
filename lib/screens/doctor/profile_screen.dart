import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import '../../services/language_service.dart';
import 'package:neuroguard_ai/config/app_config.dart';

// Direct import of your Login Screen to bypass named route requirements
import '../auth/login_screen.dart';

import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_and_security_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const ProfileScreen({super.key, this.doctorData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = widget.doctorData;
    _fetchProfile();
    GlobalRefreshNotifier().addListener(_onRefresh);
  }

  @override
  void dispose() {
    GlobalRefreshNotifier().removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final int userId = _profileData?['id'] ?? widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_medical_history/$userId"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['history'] != null) {
          if (mounted) {
            setState(() {
              _profileData = data['history'];
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    // Case-insensitive database key lookups to guarantee dynamic synchronization
    final int doctorDatabaseId = _profileData?['id'] ?? widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    final String doctorName =
        _profileData?['name'] ?? widget.doctorData?['name'] ?? widget.doctorData?['Name'] ?? "Dr. Your Name";
    final String doctorEmail =
        _profileData?['email'] ?? widget.doctorData?['email'] ?? widget.doctorData?['Email'] ?? "doctor@email.com";

    // DYNAMIC REPAIR: Dynamically reads your exact text registration row phone field
    final String doctorPhone = _profileData?['phone'] != null
        ? _profileData!['phone'].toString()
        : widget.doctorData?['phone'] != null
        ? widget.doctorData!['phone'].toString()
        : widget.doctorData?['Phone'] != null
        ? widget.doctorData!['Phone'].toString()
        : "0300 123456";

    // FIXED: Directly pushes LoginScreen using rootNavigator to completely escape the Dashboard tabs
    void showLogoutDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Logout Confirmation",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Are you sure you want to logout from this profile?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                },
                child: Text(AppLocalizations.of(context).cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog

                  // Direct navigation to LoginScreen - completely clearing out all navigation history
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(languageProvider: LanguageProvider.instance),
                    ),
                    (route) => false, // Clears everything out
                  );
                },
                child: Text(AppLocalizations.of(context).logout),
              ),
            ],
          );
        },
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.padding(context)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0B8F55), Color(0xff22C55E)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: watch ? 40 : 60,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: watch ? 40 : 60,
                      color: Color(0xff0B8F55),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    doctorName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Neurologist",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    doctorEmail,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.spacing(context)),

            // Doctor Information Card Layout (Matches your exact screenshot styling fields)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context)),
                child: Column(
                  children: [
                    _profileTile(
                      icon: Icons.badge_outlined,
                      title: "Doctor ID",
                      value:
                          "NGA-DR-${doctorDatabaseId.toString().padLeft(3, '0')}", // Dynamic Formatted ID string
                    ),
                    Divider(),
                    _profileTile(
                      icon: Icons.phone_outlined,
                      title: "Phone",
                      value: doctorPhone, // Dynamic real phone field
                    ),
                    Divider(),
                    _profileTile(
                      icon: Icons.email_outlined,
                      title: "Email Address",
                      value: doctorEmail, // Dynamic login email field
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: Responsive.spacing(context)),

            // Settings Component Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xffE9FFF4),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Color(0xff0B8F55),
                      ),
                    ),
                    title: Text(
                      "Edit Profile",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorEditProfileScreen(doctorData: _profileData ?? widget.doctorData),
                        ),
                      ).then((_) => _fetchProfile());
                    },

                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xffE9FFF4),
                      child: Icon(Icons.lock_outline, color: Color(0xff0B8F55)),
                    ),
                    title: Text(
                      "Change Password",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChangePasswordScreen(userId: doctorDatabaseId),
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
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationSettingsScreen(
                            userId: doctorDatabaseId,
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
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PrivacySecurityScreen(userId: doctorDatabaseId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.spacing(context)),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  showLogoutDialog(context);
                },
                icon: Icon(Icons.logout),
                label: Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
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
            SizedBox(height: 8),
            Text(
              "AI Powered Epileptic Seizure Monitoring System",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Text(
              "Doctor Profile • Version 1.0.0",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            SizedBox(height: 5),
            Text(
              "© 2026 NeuroGuard AI",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Color(0xffE9FFF4),
        child: Icon(icon, color: Color(0xff0B8F55)),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}







