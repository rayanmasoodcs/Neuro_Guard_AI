import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class PatientChangePasswordScreen extends StatefulWidget {
  final Map<String, dynamic>?
  patientData; // Dynamic multi-tenant configuration blocks

  const PatientChangePasswordScreen({super.key, this.patientData});

  @override
  State<PatientChangePasswordScreen> createState() =>
      _PatientChangePasswordScreenState();
}

class _PatientChangePasswordScreenState
    extends State<PatientChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);
    String url = "${AppConfig.baseUrl}/update_password";

    // Trace active system key strings context cleanly
    final int activeUserId =
        widget.patientData?['id'] ??
        widget.patientData?['ID'] ??
        widget.patientData?['user_pk_id'] ??
        2;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": activeUserId,
          "current_password": currentPasswordController.text,
          "new_password": newPasswordController.text,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        if (mounted) {
          GlobalRefreshNotifier().notifyDataChanged();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xff0B8F55),
              content: Text("Password updated successfully."),
            ),
          );

          // Clear field controller items upon successful execution sequence loops
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();

          Navigator.pop(context);
        }
      } else {
        throw Exception(
          responseData['message'] ?? "Credential modification request denied.",
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString().replaceAll("Exception:", "").trim()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
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
          "Change Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: hideCurrent,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).currentPassword,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(0xff0B8F55),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideCurrent ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xff0B8F55),
                      ),
                      onPressed: () {
                        setState(() {
                          hideCurrent = !hideCurrent;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff0B8F55),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (val) => (val == null || val.isEmpty)
                      ? "Please provide your current password."
                      : null,
                ),

                SizedBox(height: 20),

                TextFormField(
                  controller: newPasswordController,
                  obscureText: hideNew,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).newPassword,
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color(0xff0B8F55),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideNew ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xff0B8F55),
                      ),
                      onPressed: () {
                        setState(() {
                          hideNew = !hideNew;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff0B8F55),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter a new password.";
                    }
                    if (val.length < 6) {
                      return "Password must be at least 6 characters long.";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirm,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).confirmPassword,
                    prefixIcon: Icon(
                      Icons.lock_reset,
                      color: Color(0xff0B8F55),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xff0B8F55),
                      ),
                      onPressed: () {
                        setState(() {
                          hideConfirm = !hideConfirm;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff0B8F55),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please confirm your new password.";
                    }
                    if (val != newPasswordController.text) {
                      return "Passwords do not match.";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isUpdating ? null : _changePassword,
                    icon: _isUpdating
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.save),
                    label: Text(
                      _isUpdating ? "Processing..." : "Update Password",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}






