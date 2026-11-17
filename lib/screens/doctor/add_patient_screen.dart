import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class AddPatientScreen extends StatefulWidget {
  final Map<String, dynamic>?
  doctorData; // Receives active clinician contextual tokens

  const AddPatientScreen({super.key, this.doctorData});

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
  final TextEditingController _eegController = TextEditingController();
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
  int? _calculatedAgeInt;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _eegController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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

      final String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      setState(() {
        _calculatedAgeInt = age;
        _ageController.text = "$formattedDate ($age Years)";
      });
    }
  }

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

    // CHANGED: Added robust ID extraction
    final int activeDoctorId =
        widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    debugPrint("DEBUG: Sending Doctor ID: $activeDoctorId");

    String url = "${AppConfig.baseUrl}/update_or_add_patient";

    final Map<String, dynamic> payload = {
      "patient_id": _idController.text.trim(),
      "doctor_id": activeDoctorId,
      "name": _nameController.text.trim(),
      "age": _calculatedAgeInt ?? 0, // CHANGED: Added fallback
      "gender": _selectedGender ?? "Not Specified", // CHANGED: Added fallback
      "medical_condition": _selectedCondition,
      "last_eeg_info": _eegController.text.trim().isEmpty
          ? "No EEG processed yet"
          : _eegController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "emergency_contact": _contactController.text.trim(),
      "additional_notes": _notesController.text.trim(),
    };

    try {
      // CHANGED: Added required headers for Flask get_json()
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          if (!mounted) return;
          GlobalRefreshNotifier().notifyDataChanged();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xff0B8F55),
              content: Text(data['message']),
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception(
          "Server connection failure code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to register patient: ${e.toString()}"),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
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
                    backgroundColor: Color.fromRGBO(11, 143, 85, 0.1),
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
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? "Please select patient birth date."
                        : null,
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
                _buildTextField(
                  label: "Last EEG Info (e.g. today, last month)",
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
                  label: "Additional Notes / History",
                  controller: _notesController,
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                SizedBox(height: Responsive.spacing(context)),
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
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
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
        ),
      ),
    );
  }
}










