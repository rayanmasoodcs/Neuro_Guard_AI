import 'package:flutter/material.dart';
import 'package:neuroguard_ai/config/app_config.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';

class UpdatePatientScreen extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const UpdatePatientScreen({super.key, this.doctorData});

  @override
  State<UpdatePatientScreen> createState() => _UpdatePatientScreenState();
}

class _UpdatePatientScreenState extends State<UpdatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  // Input controller instances
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _eegController =
      TextEditingController(); // ADDED: Controller for last_eeg_info updates
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _conditions = [
    "Stable",
    "Critical",
    "Need Urgent Review",
    "Under Observation",
  ];
  String? _selectedCondition;
  String? _selectedGender;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _eegController.dispose(); // ADDED: Clean up your EEG controller reference
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Opens calendar and calculates age in years automatically
  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff0B8F55),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final DateTime today = DateTime.now();
      int age = today.year - pickedDate.year;

      if (today.month < pickedDate.month ||
          (today.month == pickedDate.month && today.day < pickedDate.day)) {
        age--;
      }

      setState(() {
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _updatePatientData() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if at least the ID is provided before attempting an update request
    if (_idController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Please provide a Target Patient ID to identify the file.",
          ),
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    final int activeDoctorId =
        widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? widget.doctorData?['user_id'] ?? 1;

    if (activeDoctorId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Doctor identity not found. Please log in again."),
        ),
      );
      return;
    }

    String url = "${AppConfig.baseUrl}/update_or_add_patient";
    final Map<String, dynamic> payload = {
      "patient_id": _idController.text.trim(),
      "doctor_id": activeDoctorId,
      "name": _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      "age": _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim()),
      "gender": _selectedGender,
      "medical_condition": _selectedCondition,
      "last_eeg_info": _eegController.text.trim().isEmpty
          ? null
          : _eegController.text
                .trim(), // ADDED: Part of network serialization block payload
      "email": _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      "phone": _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      "address": _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      "emergency_contact": _contactController.text.trim().isEmpty
          ? null
          : _contactController.text.trim(),
      "additional_notes": _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
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
          GlobalRefreshNotifier().notifyDataChanged();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xff0B8F55),
              content: Text(data['message']),
            ),
          );
          if (!mounted) return;
          Navigator.pop(context);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception(
          "Server integration response failure code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to update patient data: ${e.toString()}"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).updatePatientFile,
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
                      Icons.edit_note_rounded,
                      size: watch ? 30 : 45,
                      color: Color(0xff0B8F55),
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // REQUIRED REMOVED: Reconfigured to a non-restrictive text validation scheme
                _buildTextField(
                  label: "Target Patient ID (Locate File)",
                  controller: _idController,
                  icon: Icons.badge_outlined,
                  required: false,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 16, start: 4),
                  child: Text(
                    "Fill only fields you wish to modify. Leaving fields blank leaves previous logs unchanged.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                _buildTextField(
                  label: "Full Name",
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),

                Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 16),
                  child: TextFormField(
                    controller: _ageController,
                    readOnly: true,
                    onTap: () => _selectBirthDate(context),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).ageLabel,
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xff0B8F55),
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
                  ),
                ),

                _buildDropdownField(
                  label: "Gender",
                  value: _selectedGender,
                  items: ["Male", "Female", "Other"],
                  icon: Icons.wc_outlined,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),

                _buildDropdownField(
                  label: "Medical Condition Status",
                  value: _selectedCondition,
                  items: _conditions,
                  icon: Icons.healing_outlined,
                  onChanged: (val) => setState(() => _selectedCondition = val),
                ),

                // ADDED: Last EEG Information Form update text element
                _buildTextField(
                  label: "Last EEG Info Update (e.g. today, last month)",
                  controller: _eegController,
                  icon: Icons.analytics_outlined,
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
                  label: "Additional Notes / History updates",
                  controller: _notesController,
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),

                SizedBox(height: Responsive.spacing(context)),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isUpdating ? null : _updatePatientData,
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xff0B8F55),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isUpdating
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            "Commit Profile Updates",
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
                  ? "This target sequence field is required"
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








