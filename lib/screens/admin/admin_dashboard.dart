import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neuroguard_ai/config/app_config.dart';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import '../../services/language_service.dart';
import '../auth/login_screen.dart';
import '../doctor/upload_eeg_screen.dart';

/// Superadmin workspace: create doctor/patient accounts and run EEG analysis.
class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> adminData;
  final LanguageProvider languageProvider;

  const AdminDashboard({super.key, required this.adminData, required this.languageProvider});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const _green = Color(0xff0B8F55);
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'doctor';
  bool _saving = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/admin/users'));
      final data = jsonDecode(res.body);
      if (mounted && data['status'] == 'success') setState(() => _users = data['users']);
    } catch (e) {
      debugPrint('[Admin] load users failed: $e');
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/create_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': _name.text.trim(), 'email': _email.text.trim(), 'password': _password.text, 'role': _role}),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      final ok = data['status'] == 'success';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message'] ?? (ok ? 'Account created.' : 'Failed to create account.')),
        backgroundColor: ok ? _green : Colors.red,
      ));
      if (ok) {
        _name.clear();
        _email.clear();
        _password.clear();
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to connect: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(languageProvider: widget.languageProvider)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
        actions: [IconButton(tooltip: 'Log out', icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Welcome, ${widget.adminData['name'] ?? 'Admin'}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.upload_file, color: _green),
                  title: const Text('Upload EEG for analysis'),
                  subtitle: const Text('EDF, CSV, TXT or DAT'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadEEGScreen())),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Create account', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'doctor', label: Text('Doctor'), icon: Icon(Icons.medical_services)),
                            ButtonSegment(value: 'patient', label: Text('Patient'), icon: Icon(Icons.person)),
                          ],
                          selected: {_role},
                          onSelectionChanged: (s) => setState(() => _role = s.first),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                          validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Temporary password',
                            helperText: '8+ characters with upper, lower, number and one of @\$!%*?&',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: _green, padding: const EdgeInsets.all(16)),
                          onPressed: _saving ? null : _createUser,
                          icon: _saving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.person_add),
                          label: Text('Create ${_role == 'doctor' ? 'doctor' : 'patient'}'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Accounts (${_users.length})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_users.isEmpty)
                const Padding(padding: EdgeInsets.all(16), child: Text('No doctor or patient accounts yet.'))
              else
                ..._users.map((u) => Card(
                      child: ListTile(
                        leading: Icon(u['role'] == 'doctor' ? Icons.medical_services : Icons.person, color: _green),
                        title: Text(u['name'] ?? ''),
                        subtitle: Text(u['email'] ?? ''),
                        trailing: Chip(label: Text(u['role'] ?? '')),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
