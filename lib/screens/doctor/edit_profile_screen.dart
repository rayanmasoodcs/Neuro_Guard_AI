import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class DoctorEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const DoctorEditProfileScreen({super.key, this.doctorData});

  @override
  State<DoctorEditProfileScreen> createState() => _DoctorEditProfileScreenState();
}

class _DoctorEditProfileScreenState extends State<DoctorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text =
        widget.doctorData?['name'] ??
        widget.doctorData?['account_name'] ??
        "";
    ageController.text =
        widget.doctorData?['age']?.toString() ?? "";
    emailController.text =
        widget.doctorData?['email'] ??
        widget.doctorData?['account_email'] ??
        "";
    phoneController.text =
        widget.doctorData?['phone'] ??
        widget.doctorData?['account_phone'] ??
        "";
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    if (nameController.text.trim().isEmpty &&
        ageController.text.trim().isEmpty &&
        emailController.text.trim().isEmpty &&
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(AppLocalizations.of(context).emptyFieldsWarning),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final String url = "${AppConfig.baseUrl}/update_user_profile";

    final int activeUserId =
        widget.doctorData?['id'] ??
        widget.doctorData?['ID'] ??
        widget.doctorData?['user_pk_id'] ??
        1;

    final Map<String, dynamic> payload = {
      "id": activeUserId,
      "name": nameController.text.trim(),
      "age": ageController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        if (mounted) {
          GlobalRefreshNotifier().notifyDataChanged();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xff0B8F55),
              content: Text(AppLocalizations.of(context).profileUpdated),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(responseData['message'] ?? AppLocalizations.of(context).profileUpdateFailed),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _profileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xff0B8F55)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff0B8F55), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xff0B8F55),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(watch ? 12 : Responsive.padding(context)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: watch ? 35 : 55,
                        backgroundColor: Color(0xffE9FFF4),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: watch ? 40 : 65,
                          color: Color(0xff0B8F55),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  "Account Core Credentials",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 15),

                _profileField(controller: nameController, label: "Full Name", icon: Icons.person_outline),
                _profileField(controller: ageController, label: "Age", icon: Icons.cake_outlined, keyboardType: TextInputType.number),
                _profileField(controller: emailController, label: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                _profileField(controller: phoneController, label: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone),

                SizedBox(height: Responsive.spacing(context)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfileChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0B8F55),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(AppLocalizations.of(context).saveChanges, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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








