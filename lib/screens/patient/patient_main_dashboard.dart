import 'package:flutter/material.dart';
import '../../services/global_refresh_notifier.dart';
import '../../services/language_service.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import '../../responsive/responsive.dart';
import '../wearable/smartwatch_dashboard.dart';
import 'patient_dashboard.dart';
import 'patient_profile.dart';
import 'reminder_screen.dart';
import '../auth/login_screen.dart';
import 'bluetooth_screen.dart';

class PatientMainDashboard extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  final LanguageProvider languageProvider;

  const PatientMainDashboard({super.key, this.patientData, required this.languageProvider});

  @override
  State<PatientMainDashboard> createState() => _PatientMainDashboardState();
}

class _PatientMainDashboardState extends State<PatientMainDashboard> {
  int selectedIndex = 0;
  int _refreshKey = 0;

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context);
    final userId = widget.patientData?['id'] ?? widget.patientData?['ID'] ?? 2;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // Decide text direction based on current locale
        final isRtl = widget.languageProvider.locale.languageCode == 'ar' || widget.languageProvider.locale.languageCode == 'ur';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SizedBox(
            height: 360,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.selectLanguage,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: LanguageProvider.supportedLanguages.length,
                    separatorBuilder: (_, _) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final lang = LanguageProvider.supportedLanguages[index];
                      final code = lang['code']!;
                      final isSelected = widget.languageProvider.locale.languageCode == code;

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        leading: Text(lang['flag']!, style: TextStyle(fontSize: 26)),
                        title: Text(lang['nativeName']!),
                        trailing: isSelected ? Icon(Icons.check_circle, color: Color(0xFF0B8F55)) : null,
                        onTap: () async {
                          await widget.languageProvider.setLanguage(code, userId);
                          // Ensure the modal closes after language change
                          if (mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.languageSwitched(lang['nativeName']!)),
                              backgroundColor: Color(0xFF0B8F55),
                            ),
                          );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    GlobalRefreshNotifier().addListener(_onGlobalRefresh);

    // Build pages once to preserve their internal state and avoid re-triggering initState on parent rebuilds
    _pages = [
      PatientHomeScreen(patientData: widget.patientData, key: ValueKey('home')),
      RemindersScreen(patientId: widget.patientData?['id']?.toString(), key: ValueKey('reminders')),
      PatientProfileScreen(patientData: widget.patientData, key: ValueKey('profile')),
    ];
  }

  @override
  void dispose() {
    GlobalRefreshNotifier().removeListener(_onGlobalRefresh);
    super.dispose();
  }

  void _onGlobalRefresh() {
    if (!mounted) return;
    setState(() {
      _refreshKey++;
    });
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(languageProvider: widget.languageProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isWatch(context)) {
      return SmartwatchDashboard(
        patientData: widget.patientData,
        languageProvider: widget.languageProvider,
      );
    }
    final l10n = AppLocalizations.of(context);

    final String patientName =
        widget.patientData?['name'] ??
        widget.patientData?['Name'] ??
        "Patient User";
    final String patientEmail =
        widget.patientData?['email'] ??
        widget.patientData?['Email'] ??
        "patient@email.com";

    return Scaffold(
      backgroundColor: Color(0xFFF6FAF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF0B8F55),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          l10n.patientDashboard,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Language Button
          IconButton(
            onPressed: _showLanguagePicker,
            icon: Icon(Icons.language, color: Colors.white),
            tooltip: l10n.selectLanguage,
          ),
          // Bluetooth Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientBluetoothScreen(),
                ),
              );
            },
            icon: Icon(Icons.bluetooth, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0B8F55)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF0B8F55), size: 35),
              ),
              accountName: Text(patientName),
              accountEmail: Text(patientEmail),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text(l10n.homeNav),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text(l10n.remindersNav),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(l10n.profileNav),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text(l10n.bluetoothDevices),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientBluetoothScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(l10n.logout, style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                logout();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: l10n.homeNav,
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: l10n.remindersNav,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: l10n.profileNav,
          ),
        ],
      ),
    );
  }
}



