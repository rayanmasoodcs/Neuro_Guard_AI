import 'package:flutter/material.dart';
import 'package:neuroguard_ai/config/app_config.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Input controller instances
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Dropdown list items configured to separate strict evaluation filters perfectly
  final List<String> _conditions = ["Stable", "Critical", "Need Urgent Review"];
  String? _selectedCondition;
  String? _selectedGender;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Submit patient payload dynamically to Python API
  Future<void> _savePatientData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).selectCondition),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    String url = "${AppConfig.baseUrl}/update_or_add_patient";
    final Map<String, dynamic> payload = {
      "patient_id": _idController.text.trim(),
      "name": _nameController.text.trim(),
      "age": int.tryParse(_ageController.text.trim()),
      "gender": _selectedGender,
      "medical_condition": _selectedCondition,
      "last_eeg_info": "No EEG processed yet",
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "emergency_contact": _contactController.text.trim(),
      "additional_notes": _notesController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xff0B8F55),
              content: Text(data['message']),
            ),
          );
          Navigator.pop(
            context,
          ); // Return and invoke refresh callbacks automatically
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception(
          "Server integration response failure code: ${response.statusCode}",
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to register patient: ${e.toString()}"),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register New Patient",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xff0B8F55),
        iconTheme: IconThemeData(color: Colors.white),
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
                  child: CircleAvatar(
                    radius: watch ? 30 : 45,
                    backgroundColor: Color(0xffE9FFF4),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      size: watch ? 30 : 45,
                      color: Color(0xff0B8F55),
                    ),
                  ),
                ),
                SizedBox(height: 25),

                _buildTextField(
                  label: "Patient ID (e.g. 01, 02)",
                  controller: _idController,
                  icon: Icons.badge_outlined,
                  required: true,
                ),
                _buildTextField(
                  label: "Full Name",
                  controller: _nameController,
                  icon: Icons.person_outline,
                  required: true,
                ),
                _buildTextField(
                  label: "Age",
                  controller: _ageController,
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  required: true,
                ),

                // Gender Selection Dropdown Box
                _buildDropdownField(
                  label: "Gender",
                  value: _selectedGender,
                  items: ["Male", "Female", "Other"],
                  icon: Icons.wc_outlined,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),

                // Medical Condition Strict Selection Dropdown Box
                _buildDropdownField(
                  label: "Medical Condition Status",
                  value: _selectedCondition,
                  items: _conditions,
                  icon: Icons.healing_outlined,
                  onChanged: (val) => setState(() => _selectedCondition = val),
                ),

                _buildTextField(
                  label: "Email Address",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                ),
                _buildTextField(
                  label: "Phone Number",
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  label: "Residential Address",
                  controller: _addressController,
                  icon: Icons.home_outlined,
                ),
                _buildTextField(
                  label: "Emergency Contact Number",
                  controller: _contactController,
                  icon: Icons.contact_phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  label: "Additional Notes / History",
                  controller: _notesController,
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),

                SizedBox(height: Responsive.spacing(context)),

                // Action Submission Button Container
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _savePatientData,
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xff0B8F55),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Save Patient Profile",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xff0B8F55)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff0B8F55), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty)
                  ? "This field is required"
                  : null
            : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
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
}









