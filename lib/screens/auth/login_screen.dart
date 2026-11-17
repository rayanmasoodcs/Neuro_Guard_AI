import 'package:flutter/material.dart';
import 'signup_screen.dart';
// Importing the responsive class tool you created
import '../../responsive/responsive.dart';
// Importing the API service file to communicate with MongoDB
import '../../database/api_service.dart';
import '../../services/language_service.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';

// Dynamically target and import your dashboard views based on your project file structure
import '../doctor/doctor_dashboard.dart';
import '../patient/patient_main_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final LanguageProvider languageProvider;
  const LoginScreen({super.key, required this.languageProvider});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  final List<Map<String, String>> _googleAccounts = [
    {
      "name": "Wajahat Hussain",
      "email": "wajahat.hussain@gmail.com",
    },
    {
      "name": "Student Profile",
      "email": "2023-uam-1811@student.edu",
    },
  ];

  // Login processing logic
  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).fillAllFields)),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Make request via your established database service file pipeline
    final result = await ApiService.loginUser(email: email, password: password);

    setState(() {
      isLoading = false;
    });

    if (result['status'] == 'success') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).loginSuccess),
          ),
        );
      }

      try {
        // CASE-INSENSITIVE FALLBACK: Extracts the user payload map checking all potential key spellings
        final dynamic rawUser =
            result['user'] ?? result['User'] ?? result['data'] ?? result;
        final Map<String, dynamic> userData = (rawUser is Map<String, dynamic>)
            ? rawUser
            : {};

        // EXTRACT THE ROLE FROM THE RESPONSE (Checking both lowercase and uppercase variations)
        final String role = (userData['role'] ?? userData['Role'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        final dynamic userId = userData['id'] ?? userData['ID'] ?? userData['_id'] ?? 1;

        // Load saved language for this user safely
        try {
          await widget.languageProvider.loadSavedLanguage(userId);
        } catch (e) {
          debugPrint('[LOGIN WARNING] Could not load saved language: $e');
        }

        if (!mounted) return;

        // CONDITIONAL ROLE-BASED NAVIGATION ROUTING Passing clean User Map Down
        if (role == 'doctor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(
                doctorData: userData,
                languageProvider: widget.languageProvider,
              ),
            ),
          );
        } else if (role == 'patient') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PatientMainDashboard(
                patientData: userData,
                languageProvider: widget.languageProvider,
              ),
            ),
          );
        } else {
          // Fallback error check if database role field string is missing or misspelled
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).roleConfigError),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e, stack) {
        debugPrint('[LOGIN ERROR] Failed to navigate to dashboard: $e\n$stack');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigation error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        final String errorMsg = result['message']?.toString() ?? AppLocalizations.of(context).connectionFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWatch = Responsive.isWatch(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffE9FFF4), Color(0xffF7FBFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context),
                  vertical: Responsive.spacing(context),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.cardWidth(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isWatch ? 18 : 35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.08),
                        blurRadius: 40,
                        spreadRadius: 3,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isWatch ? 10 : 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: "logo",
                          child: Container(
                            height: Responsive.logoSize(context),
                            width: Responsive.logoSize(context),
                            decoration: BoxDecoration(
                              color: Color(0xff0B8F55),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.health_and_safety_rounded,
                              color: Colors.white,
                              size: Responsive.logoSize(context) * 0.55,
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context)),
                        Text(
                          l10n.loginTitle,
                          style: TextStyle(
                            fontSize: Responsive.titleSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (!isWatch) ...[
                          SizedBox(height: 10),
                          Text(
                            l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Responsive.subtitleSize(context),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                        SizedBox(height: Responsive.spacing(context)),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : l10n.emailLabel,
                            hintText: l10n.emailHint,
                            hintStyle: TextStyle(fontSize: isWatch ? 11 : 14),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Color(0xff0B8F55),
                              size: isWatch ? 16 : 22,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isWatch ? 8 : 14,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isWatch ? 10 : 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context) * 0.75),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : l10n.passwordLabel,
                            hintText: l10n.passwordHint,
                            hintStyle: TextStyle(fontSize: isWatch ? 11 : 14),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color(0xff0B8F55),
                              size: isWatch ? 16 : 22,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: isWatch ? 16 : 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isWatch ? 8 : 14,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isWatch ? 10 : 18,
                              ),
                            ),
                          ),
                        ),
                        if (!isWatch)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                l10n.forgotPassword,
                                style: TextStyle(
                                  color: Color(0xff0B8F55),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: Responsive.spacing(context)),
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.buttonHeight(context),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff0B8F55),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isWatch ? 10 : 18,
                                ),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    l10n.loginButton,
                                    style: TextStyle(
                                      fontSize: isWatch ? 11 : 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                        if (!isWatch) ...[
                          SizedBox(height: Responsive.spacing(context)),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(l10n.orDivider),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.spacing(context)),
                          SizedBox(
                            width: double.infinity,
                            height: Responsive.buttonHeight(context),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 16,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.chooseAccount,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            l10n.toContinue,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Divider(color: Colors.grey.shade200),
                                          ..._googleAccounts.map(
                                            (account) => ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Color(
                                                  0xff0B8F55,
                                                ).withValues(alpha: 0.1),
                                                child: Text(
                                                  account["name"]![0],
                                                  style: TextStyle(
                                                    color: Color(0xff0B8F55),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                account["name"]!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                account["email"]!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  emailController.text =
                                                      account["email"]!;
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Icon(
                                                Icons.add_to_photos_outlined,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            title: Text(
                                              l10n.useAnotherAccount,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.g_mobiledata,
                                size: 30,
                                color: Color(0xff0B8F55),
                              ),
                              label: Text(
                                l10n.continueWithGoogle,
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: Responsive.spacing(context)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isWatch ? l10n.newPrompt : l10n.signupPrompt,
                              style: TextStyle(fontSize: isWatch ? 11 : 14),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(
                                      languageProvider: widget.languageProvider,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                isWatch ? l10n.registerPrompt : l10n.createAccount,
                                style: TextStyle(
                                  color: Color(0xff0B8F55),
                                  fontWeight: FontWeight.bold,
                                  fontSize: isWatch ? 11 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}



