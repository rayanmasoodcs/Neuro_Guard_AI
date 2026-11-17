import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/global_refresh_notifier.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class CallScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const CallScreen({super.key, this.patientData});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  List<dynamic> _familyContacts = [];
  bool _isLoading = true;
  bool _familyFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchFamilyContacts();
  }

  Future<void> _fetchFamilyContacts() async {
    if (_familyFetching) return;
    _familyFetching = true;

    final int activeUserId = widget.patientData?['id'] ?? 2;
    final Uri uri = Uri.parse(
      "${AppConfig.baseUrl}/get_family_contacts/$activeUserId",
    );

    debugPrint("Requesting URL: $uri");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      debugPrint("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _familyContacts = data['contacts'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching family contacts: $e');
    } finally {
      _familyFetching = false;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addContact(String name, String phone) async {
    final int activeUserId = widget.patientData?['id'] ?? 2;
    String url = "${AppConfig.baseUrl}/add_family_contact";

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "user_id": activeUserId,
              "name": name,
              "phone_number": phone,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        GlobalRefreshNotifier().notifyDataChanged();
        _fetchFamilyContacts();
      }
    } catch (e) {
      debugPrint("Failed to add contact: $e");
    }
  }

  Future<void> _deleteContact(int contactId) async {
    final int activeUserId = widget.patientData?['id'] ?? 2;
    final String url = "${AppConfig.baseUrl}/delete_family_contact/$contactId";

    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"user_id": activeUserId}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        GlobalRefreshNotifier().notifyDataChanged();
        _fetchFamilyContacts();
      }
    } catch (e) {
      debugPrint("Failed to delete contact: $e");
    }
  }

  Future<void> makeCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showAddContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Add Family Contact",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Contact Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).phoneHintPatient,
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff0B8F55),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                _addContact(
                  nameController.text.trim(),
                  phoneController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }

  Widget contactCard({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
    Widget? trailingAction,
  }) {
    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(number, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Wrapping trailing action inside a constrained container/Row with min size
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child:
                  trailingAction ??
                  ElevatedButton.icon(
                    onPressed: () => makeCall(number),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("Call"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0B8F55),
                      foregroundColor: Colors.white,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xff0B8F55),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff0B8F55)),
            )
          : RefreshIndicator(
              color: const Color(0xff0B8F55),
              onRefresh: _fetchFamilyContacts,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const Text(
                    "Emergency Helplines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  contactCard(
                    title: "Rescue 1122",
                    number: "1122",
                    icon: Icons.local_hospital,
                    color: Colors.red,
                  ),
                  contactCard(
                    title: "Police",
                    number: "15",
                    icon: Icons.local_police,
                    color: const Color(0xFF2E7D32),
                  ),
                  contactCard(
                    title: "Fire Brigade",
                    number: "16",
                    icon: Icons.fire_truck,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Family Contacts",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: _showAddContactDialog,
                        child: const CircleAvatar(
                          backgroundColor: Color(0xff0B8F55),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (_familyContacts.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "No family contacts added yet.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._familyContacts.map((contact) {
                      final String name =
                          contact['name']?.toString() ?? 'Unknown';
                      final String phone =
                          contact['phone_number']?.toString() ?? '0000000000';
                      final int id = contact['id'] ?? 0;

                      return contactCard(
                        title: name,
                        number: phone,
                        icon: Icons.family_restroom,
                        color: Colors.green,
                        trailingAction: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteContact(id),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () => makeCall(phone),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff0B8F55),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: const Text("Call"),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }
}
