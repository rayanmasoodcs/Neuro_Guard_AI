import 'package:flutter/material.dart';
import '../../responsive/responsive.dart';
import '../../services/global_refresh_notifier.dart';
import '../../services/language_service.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';

import 'home_screen.dart';
import 'patients_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import '../auth/login_screen.dart';
import 'notification_settings_screen.dart';
import 'bluetooth_screen.dart';

class DoctorDashboard extends StatefulWidget {
  final Map<String, dynamic>? doctorData;
  final LanguageProvider languageProvider;

  const DoctorDashboard({super.key, this.doctorData, required this.languageProvider});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int selectedIndex = 0;
  final int _refreshKey = 0;

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context);
    final userId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
    // Create child pages once to preserve state and avoid re-running initState when parent rebuilds.
    _pages = [
      HomeScreen(doctorData: widget.doctorData, key: ValueKey('home')),
      PatientsScreen(doctorData: widget.doctorData, key: ValueKey('patients')),
      ReportsScreen(key: ValueKey('reports')),
      ProfileScreen(doctorData: widget.doctorData, key: ValueKey('profile')),
    ];

    GlobalRefreshNotifier().addListener(_onGlobalRefresh);
  }

  @override
  void dispose() {
    GlobalRefreshNotifier().removeListener(_onGlobalRefresh);
    super.dispose();
  }

  void _onGlobalRefresh() {
    if (!mounted) return;
    // Children listen to GlobalRefreshNotifier and will refresh themselves; avoid recreating widgets here.
    setState(() {});
  }


  void openNotification() {
    final int docId = widget.doctorData?['id'] ?? widget.doctorData?['ID'] ?? 1;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationSettingsScreen(userId: docId),
      ),
    );
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(languageProvider: widget.languageProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool watch = Responsive.isWatch(context);

    final l10n = AppLocalizations.of(context);

    final String doctorName =
        widget.doctorData?['name'] ??
        widget.doctorData?['Name'] ??
        "Dr. Wajahat Hussain";
    final String doctorEmail =
        widget.doctorData?['email'] ??
        widget.doctorData?['Email'] ??
        "doctor@email.com";

    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff0B8F55),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          l10n.doctorDashboard,
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
                  builder: (context) => DoctorBluetoothScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.bluetooth,
              color: Colors.white,
            ),
          ),

          // Notification Button
          IconButton(
            onPressed: openNotification,
            icon: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),

          // Profile Avatar Button
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              // FIXED NAVIGATION ROUTING LOGIC: Navigates cleanly to page 3 (profile tab)
              setState(() {
                selectedIndex = 3;
              });
            },
            child: CircleAvatar(
              radius: watch ? 16 : 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.medical_services_rounded,
                color: Color(0xff0B8F55),
              ),
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xff0B8F55)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.medical_services,
                  color: Color(0xff0B8F55),
                  size: 35,
                ),
              ),
              accountName: Text(doctorName),
              accountEmail: Text(doctorEmail),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text(l10n.dashboardNav),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people_alt),
              title: Text(l10n.patientsNav),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text(l10n.reportsNav),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(l10n.profileNav),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
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
                    builder: (context) => DoctorBluetoothScreen(),
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
      // Use IndexedStack to keep child state alive and avoid unnecessary rebuilds
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ), // Accesses persistent pages
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
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: l10n.patientsNav,
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: l10n.reportsNav,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: l10n.profileNav,
          ),
        ],
      ),
    );
  }
}





