import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import '../../responsive/responsive.dart';
import '../../database/api_service.dart';
import '../../services/language_service.dart';

class SignupScreen extends StatefulWidget {
  final LanguageProvider languageProvider;
  const SignupScreen({super.key, required this.languageProvider});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? selectedRole = "Patient";
  String? selectedGender;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  void _submitSignup() async {
    if (_formKey.currentState!.validate()) {
      if (selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).selectGender),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final result = await ApiService.registerUser(
          name: nameController.text.trim(),
          email: emailController.text.trim().toLowerCase(),
          phone: phoneController.text.trim(),
          password: passwordController.text,
          role: selectedRole ?? 'patient',
          age: int.tryParse(ageController.text.trim()),
          gender: selectedGender,
        );

        if (result['status'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).signupSuccess),
              backgroundColor: const Color(0xff0B8F55),
            ),
          );
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Registration failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network pipeline error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWatch = Responsive.isWatch(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffE9FFF4), Color(0xffF7FBFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWatch ? 10 : 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: .08),
                      blurRadius: 40,
                      spreadRadius: 3,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWatch ? 15 : 35),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "logo",
                          child: Container(
                            height: Responsive.logoSize(context),
                            width: Responsive.logoSize(context),
                            decoration: const BoxDecoration(
                              color: Color(0xff0B8F55),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: Responsive.logoSize(context) * .55,
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context)),
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: Responsive.titleSize(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join NeuroGuard AI",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.subtitleSize(context),
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Name Field
                        TextFormField(
                          controller: nameController,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : "Full Name",
                            hintText: "As printed on your CNIC",
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xff0B8F55),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please provide your official name";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Age Field
                        TextFormField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : "Age",
                            hintText: "Enter your age in years",
                            prefixIcon: const Icon(
                              Icons.cake_outlined,
                              color: Color(0xff0B8F55),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Age is required";
                            }
                            final val = int.tryParse(value.trim());
                            if (val == null || val <= 0 || val > 120) {
                              return "Enter a valid age between 1 and 120";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Gender Dropdown Field
                        DropdownButtonFormField<String>(
                          initialValue: selectedGender,
                          decoration: InputDecoration(
                            labelText: isWatch ? null : "Gender",
                            hintText: "Select Gender",
                            prefixIcon: const Icon(
                              Icons.wc_rounded,
                              color: Color(0xff0B8F55),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: "Male", child: Text("Male")),
                            DropdownMenuItem(value: "Female", child: Text("Female")),
                            DropdownMenuItem(value: "Other", child: Text("Other")),
                          ],
                          onChanged: (val) {
                            setState(() {
                              selectedGender = val;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select your gender";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Role Selection Segmented Control
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "Patient";
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selectedRole == "Patient"
                                          ? const Color(0xff0B8F55)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Patient",
                                        style: TextStyle(
                                          color: selectedRole == "Patient"
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "Doctor";
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selectedRole == "Doctor"
                                          ? const Color(0xff0B8F55)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Doctor",
                                        style: TextStyle(
                                          color: selectedRole == "Doctor"
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : "Email Address",
                            hintText: "name@example.com",
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xff0B8F55),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email is required";
                            }
                            if (!_emailRegExp.hasMatch(value.trim())) {
                              return "Enter a valid email address";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Phone Field
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : "Phone Number",
                            hintText: "+92 300 1234567",
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              color: Color(0xff0B8F55),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Phone number is required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Password Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : "Password",
                            hintText: "Minimum 8 chars, uppercase & special",
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xff0B8F55),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (!_passwordRegExp.hasMatch(value)) {
                              return "Must contain uppercase, lowercase, number & symbol";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context)),

                        // Confirm Password Field
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          style: TextStyle(fontSize: isWatch ? 11 : 15),
                          decoration: InputDecoration(
                            labelText: isWatch ? null : "Confirm Password",
                            hintText: "Re-enter your password",
                            prefixIcon: const Icon(
                              Icons.lock_reset_outlined,
                              color: Color(0xff0B8F55),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword = !obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (value != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context) * 1.5),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0B8F55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Back to Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff0B8F55),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Version 1.0.0",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "© 2026 NeuroGuard AI",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
