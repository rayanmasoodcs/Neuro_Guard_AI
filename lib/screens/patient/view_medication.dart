import 'package:flutter/material.dart';
import 'package:neuroguard_ai/config/app_config.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';

class ViewMedicationScreen extends StatefulWidget {
  final String? userId; // Accepts the logged-in user ID context dynamically

  const ViewMedicationScreen({super.key, this.userId});

  @override
  State<ViewMedicationScreen> createState() => _ViewMedicationScreenState();
}

class _ViewMedicationScreenState extends State<ViewMedicationScreen> {
  List<dynamic> _medications = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Base API URL config
  final String baseUrl = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  // GET: Fetch medications by user_id
  Future<void> _fetchMedications() async {
    // Ensuring we use the ID consistent with the users table
    final String rawId = (widget.userId ?? "1").toString().trim();
    final String url = "$baseUrl/get_medications/$rawId";

    debugPrint("DEBUG: Requesting URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _medications = data['medications'] ?? [];
            _isLoading = false;
            _errorMessage = '';
          });
        } else {
          throw Exception(data['message'] ?? "No data returned.");
        }
      } else {
        throw Exception(
          "Server connection failed (Code: ${response.statusCode})",
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception:", "").trim();
        _isLoading = false;
      });
    }
  }

  // POST: Add new medication using user_id
  Future<void> _addMedication(Map<String, String> medData) async {
    final String rawId = (widget.userId ?? "1").toString().trim();
    final String url = "$baseUrl/add_medication";

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": rawId, // Updated to use user_id
          "medicine_name": medData['name'],
          "dose": medData['dose'],
          "description": medData['description'],
          "frequency": medData['frequency'],
          "timing": medData['timing'],
          "take_with": medData['take_with'],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        GlobalRefreshNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Medication added successfully!")),
        );
        _fetchMedications();
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Failed to add medication");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${e.toString().replaceAll('Exception:', '').trim()}",
          ),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  // DELETE: Remove medication dynamically from DB via API
  Future<void> _deleteMedication(String medName) async {
    final String rawId = (widget.userId ?? "1").toString().trim();
    final String url = "$baseUrl/delete_medication/$rawId/$medName";

    setState(() => _isLoading = true);

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        GlobalRefreshNotifier().notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully removed medication: $medName")),
        );
        _fetchMedications();
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Failed to delete medication");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${e.toString().replaceAll('Exception:', '').trim()}",
          ),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  // Dialog formulation to receive user inputs for new medication
  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final doseController = TextEditingController();
    final freqController = TextEditingController();
    final timingController = TextEditingController();
    final instructionsController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Add New Medication",
          style: TextStyle(
            color: Color(0xff0B8F55),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Medicine Name"),
              ),
              TextField(
                controller: doseController,
                decoration: InputDecoration(
                  labelText: "Dosage (e.g. 250mg)",
                ),
              ),
              TextField(
                controller: freqController,
                decoration: InputDecoration(
                  labelText: "Frequency (e.g. Twice Daily)",
                ),
              ),
              TextField(
                controller: timingController,
                decoration: InputDecoration(
                  labelText: "Timing (e.g. 08:00 AM)",
                ),
              ),
              TextField(
                controller: instructionsController,
                decoration: InputDecoration(
                  labelText: "Take with (e.g. Water)",
                ),
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: "Doctor Notes"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0B8F55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addMedication({
                  'name': nameController.text,
                  'dose': doseController.text,
                  'frequency': freqController.text,
                  'timing': timingController.text,
                  'take_with': instructionsController.text,
                  'description': notesController.text,
                });
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context).add, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          "Medication Routine",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        backgroundColor: Color(0xff0B8F55),
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: Color(0xff0B8F55),
          onRefresh: _fetchMedications,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xff0B8F55)),
                )
              : _errorMessage.isNotEmpty
              ? _buildStaticCenteredLayout(
                  Icons.error_outline,
                  "Error Loading Routine",
                  _errorMessage,
                )
              : _medications.isEmpty
              ? _buildStaticCenteredLayout(
                  Icons.medication,
                  "View Your Medication",
                  "Your medication routine will be displayed here.",
                )
              : ListView.builder(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final item = _medications[index];
                    return _buildMedicationCard(item);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildStaticCenteredLayout(
    IconData icon,
    String titleText,
    String subtitleText,
  ) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Container(
          padding: EdgeInsets.all(Responsive.padding(context)),
          alignment: Alignment.center,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Color(0xff0B8F55)),
            SizedBox(height: 20),
            Text(
              titleText,
              style: TextStyle(
                fontSize: Responsive.titleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: Responsive.subtitleSize(context),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> item) {
    final String medName = item['medicine_name'] ?? "Unnamed Medicine";
    final String dose = item['dose'] ?? "N/A";
    final String description = item['description'] ?? "";
    final String frequency = item['frequency'] ?? "N/A";
    final String timing = item['timing'] ?? "N/A";
    final String takeWith = item['take_with'] ?? "N/A";

    return Card(
      elevation: 4,
      margin: EdgeInsetsDirectional.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Color(0xffE9FFF4),
                child: Icon(Icons.medication, color: Color(0xff0B8F55)),
              ),
              title: Text(
                medName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xff0B8F55),
                ),
              ),
              subtitle: Text("Dosage: $dose | Frequency: $frequency"),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete Medication"),
                      content: Text(
                        "Are you sure you want to remove $medName?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context).cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteMedication(medName);
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            SizedBox(height: 5),
            _buildInfoRow(Icons.access_time, "Timing:", timing),
            _buildInfoRow(
              Icons.restaurant,
              "Instructions:",
              "Take with $takeWith",
            ),
            if (description.isNotEmpty && description != "nothing") ...[
              SizedBox(height: 10),
              Text(
                "Doctor Notes:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xff0B8F55)),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}










