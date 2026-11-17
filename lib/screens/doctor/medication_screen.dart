import 'package:flutter/material.dart';
import 'package:neuroguard_ai/config/app_config.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';

class MedicationScreen extends StatefulWidget {
  final Map<String, dynamic>? doctorData;

  const MedicationScreen({super.key, this.doctorData});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Form Field Controllers
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _timingController = TextEditingController();
  final TextEditingController _takeWithController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    _medicineNameController.dispose();
    _doseController.dispose();
    _frequencyController.dispose();
    _timingController.dispose();
    _takeWithController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    String url = "${AppConfig.baseUrl}/add_medication";
    final String cleanPatientId = _patientIdController.text.trim().padLeft(
      2,
      '0',
    );

    final Map<String, dynamic> payload = {
      "patient_id": cleanPatientId,
      "user_id": widget.doctorData?['id'] ?? widget.doctorData?['user_id'],
      "medicine_name": _medicineNameController.text.trim(),
      "dose": _doseController.text.trim(),
      "description": _descriptionController.text.trim().isEmpty
          ? "nothing"
          : _descriptionController.text.trim(),
      "frequency": _frequencyController.text.trim(),
      "timing": _timingController.text.trim(),
      "take_with": _takeWithController.text.trim().isEmpty
          ? "Water"
          : _takeWithController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == 'success') {
          GlobalRefreshNotifier().notifyDataChanged();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Color(0xff0B8F55),
                content: Text(AppLocalizations.of(context).medicationSaved),
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(data['message'] ?? AppLocalizations.of(context).medicationSaveFailed),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(AppLocalizations.of(context).serverError),
            ),
          );
        }
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
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        title: Text(
          "Prescribe Medication",
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
                  child: CircleAvatar(
                    radius: watch ? 30 : 45,
                    backgroundColor: Color(0xffE9FFF4),
                    child: Icon(
                      Icons.medication_rounded,
                      size: watch ? 30 : 45,
                      color: Color(0xff0B8F55),
                    ),
                  ),
                ),
                SizedBox(height: 25),

                _buildTextField(
                  label: "Patient ID (e.g., 01, 02)",
                  controller: _patientIdController,
                  icon: Icons.badge_outlined,
                  required: true,
                ),
                _buildTextField(
                  label: "Medicine Name (e.g., Panadol)",
                  controller: _medicineNameController,
                  icon: Icons.medication_outlined,
                  required: true,
                ),
                _buildTextField(
                  label: "Dosage Strength (e.g., 500mg, 2 tablets)",
                  controller: _doseController,
                  icon: Icons.gavel,
                  required: true,
                ),
                _buildTextField(
                  label: "Frequency (e.g., Twice Daily, Every 8 Hours)",
                  controller: _frequencyController,
                  icon: Icons.repeat,
                  required: true,
                ),
                _buildTextField(
                  label: "Timing (e.g., Before Meals, After Meals)",
                  controller: _timingController,
                  icon: Icons.access_time,
                  required: true,
                ),
                _buildTextField(
                  label: "Take With (e.g., Water, Milk - Default is Water)",
                  controller: _takeWithController,
                  icon: Icons.local_drink_outlined,
                ),
                _buildTextField(
                  label: "Clinical Instructions / Special Description",
                  controller: _descriptionController,
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),

                SizedBox(height: Responsive.spacing(context)),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submitMedication,
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
                            "Save Prescription",
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
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 16),
      child: TextFormField(
        controller: controller,
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
                  ? "This field cannot be empty."
                  : null
            : null,
      ),
    );
  }
}








