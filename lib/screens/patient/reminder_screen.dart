import 'package:flutter/material.dart';
import 'package:neuroguard_ai/config/app_config.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';

class RemindersScreen extends StatefulWidget {
  final String? patientId;

  const RemindersScreen({super.key, this.patientId});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _remindersList = [];
  bool _isLoadingView = true;
  bool _isSavingItem = false;
  String _errorMessage = "";

  final TextEditingController _titleController = TextEditingController();
  String _selectedType = "Medication";
  DateTime? _chosenDate;
  TimeOfDay? _chosenTime;

  String get baseUrl {
    if (kIsWeb) return AppConfig.baseUrl;
    try {
      if (Platform.isAndroid) return "http://10.0.2.2:5000";
    } catch (_) {}
    return AppConfig.baseUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchRemindersFeed();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchRemindersFeed() async {
    setState(() {
      _isLoadingView = true;
      _errorMessage = "";
    });

    // Parse the ID as an integer first, then back to string to remove leading zeros
    final int cleanId = int.tryParse(widget.patientId ?? "1") ?? 1;
    final String url = "$baseUrl/get_reminders/$cleanId";

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: 7));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _remindersList = responseData['reminders'] ?? [];
            _isLoadingView = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? "No reminders found.";
            _isLoadingView = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Server error: ${response.statusCode}. Please check your backend code.";
          _isLoadingView = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Connection error: $error";
        _isLoadingView = false;
      });
    }
  }

  Future<void> _submitNewReminder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_chosenDate == null || _chosenTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Select Date & Time")));
      return;
    }

    setState(() => _isSavingItem = true);

    final String url = "$baseUrl/add_reminder";
    final String formattedDate =
        "${_chosenDate!.year}-${_chosenDate!.month.toString().padLeft(2, '0')}-${_chosenDate!.day.toString().padLeft(2, '0')}";
    final String formattedTime =
        "${_chosenTime!.hour.toString().padLeft(2, '0')}:${_chosenTime!.minute.toString().padLeft(2, '0')}";

    // UPDATED: Cast user_id to int to ensure compatibility with backend database integer schema
    final Map<String, dynamic> payload = {
      "user_id": int.tryParse(widget.patientId ?? "1") ?? 1,
      "title": _titleController.text.trim(),
      "reminder_type": _selectedType,
      "reminder_date": formattedDate,
      "reminder_time": formattedTime,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(Duration(seconds: 7));

      if (response.statusCode == 201) {
        GlobalRefreshNotifier().notifyDataChanged();
        _titleController.clear();
        setState(() {
          _chosenDate = null;
          _chosenTime = null;
        });
        _fetchRemindersFeed();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Reminder scheduled!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed: Status ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSavingItem = false);
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
          "Reminders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchRemindersFeed,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingView
            ? Center(
                child: CircularProgressIndicator(color: Color(0xff0B8F55)),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.padding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set New Reminder",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: _selectedType,
                                items: ["Medication", "Appointment"]
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) => setState(
                                  () => _selectedType = val ?? "Medication",
                                ),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).reminderType,
                                  prefixIcon: Icon(
                                    Icons.layers_outlined,
                                    color: Color(0xff0B8F55),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: _selectedType == "Medication"
                                      ? "Medicine Name"
                                      : "Appointment Title",
                                  prefixIcon: Icon(
                                    _selectedType == "Medication"
                                        ? Icons.medication_outlined
                                        : Icons.health_and_safety_outlined,
                                    color: Color(0xff0B8F55),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? "Required"
                                    : null,
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        DateTime? d = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            Duration(days: 365),
                                          ),
                                        );
                                        if (d != null) {
                                          setState(() => _chosenDate = d);
                                        }
                                      },
                                      icon: Icon(
                                        Icons.calendar_month,
                                        color: Color(0xff0B8F55),
                                      ),
                                      label: Text(
                                        _chosenDate == null
                                            ? "Select Date"
                                            : "${_chosenDate!.day}/${_chosenDate!.month}",
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        TimeOfDay? t = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (t != null) {
                                          setState(() => _chosenTime = t);
                                        }
                                      },
                                      icon: Icon(
                                        Icons.access_time,
                                        color: Color(0xff0B8F55),
                                      ),
                                      label: Text(
                                        _chosenTime == null
                                            ? "Select Time"
                                            : _chosenTime!.format(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isSavingItem
                                      ? null
                                      : _submitNewReminder,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Color(0xff0B8F55),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isSavingItem
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "Save Action Schedule",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context)),
                    Text(
                      "Active Reminders Log",
                      style: TextStyle(
                        fontSize: Responsive.titleSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ..._remindersList.map((item) {
                      return Card(
                        margin: EdgeInsetsDirectional.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xffE9FFF4),
                            child: Icon(
                              Icons.healing_outlined,
                              color: Color(0xff0B8F55),
                            ),
                          ),
                          title: Text(item['title'] ?? ""),
                          subtitle: Text("Type: ${item['reminder_type']}"),
                          trailing: Text(
                            "${item['reminder_time']}${item['reminder_date']}",
                            textAlign: TextAlign.right,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}









