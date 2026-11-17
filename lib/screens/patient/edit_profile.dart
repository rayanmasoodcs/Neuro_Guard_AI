import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>?
  patientData; // Receives live user profile map data object on initialization

  const EditProfileScreen({super.key, this.patientData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Simplified controller fields strictly reflecting your active database layout schema columns
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController =
      TextEditingController(); // ADDED: Age Controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Safely parse initial data values passed from active login session mapping tree keys
    nameController.text =
        widget.patientData?['name'] ??
        widget.patientData?['account_name'] ??
        "";
    ageController.text =
        widget.patientData?['age']?.toString() ??
        ""; // ADDED: Safely parses integer/string age value
    emailController.text =
        widget.patientData?['email'] ??
        widget.patientData?['account_email'] ??
        "";
    phoneController.text =
        widget.patientData?['phone'] ??
        widget.patientData?['account_phone'] ??
        "";
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose(); // ADDED: Dispose age controller safely
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    // Check if ALL fields are empty and prevent submission
    if (nameController.text.trim().isEmpty &&
        ageController.text.trim().isEmpty &&
        emailController.text.trim().isEmpty &&
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "All fields are empty. Please enter at least one detail to update.",
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    String url = "${AppConfig.baseUrl}/update_user_profile";

    final int activeUserId =
        widget.patientData?['id'] ??
        widget.patientData?['ID'] ??
        widget.patientData?['user_pk_id'] ??
        2;

    final Map<String, dynamic> payload = {
      "id": activeUserId,
      "name": nameController.text.trim(),
      "age": ageController.text.trim(), // ADDED: Include age in payload
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
              content: Text(
                "Profile details updated successfully! Please refresh profile view.",
              ),
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // Pops view window and triggers state refresh hooks
        }
      } else {
        throw Exception(
          responseData['message'] ??
              "Failed to finalize details validation parameters.",
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
        setState(() => _isSaving = false);
      }
    }
  }

  Widget profileField({
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 15),

                profileField(
                  controller: nameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),
                profileField(
                  controller: ageController,
                  label: "Age",
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
                profileField(
                  controller: emailController,
                  label: "Email Address",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                profileField(
                  controller: phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: Responsive.spacing(context)),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfileChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0B8F55),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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



