import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'dart:convert';
import 'package:neuroguard_ai/config/app_config.dart';
import 'package:neuroguard_ai/services/firebase_auth_helper.dart';

class ApiService {
  // Base URL for Node.js + MongoDB backend server
  static String get baseUrl => AppConfig.baseUrl;

  // ==========================================
  // AUTHENTICATION ENDPOINTS
  // ==========================================

  /// Register a new user (signup)
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    int? age,
    String? gender,
  }) async {
    final url = Uri.parse('$baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
          'age': age,
          'gender': gender,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || responseData['status'] == 'success') {
        if (responseData['token'] is String) {
          await FirebaseAuthHelper.storeAuthToken(responseData['token']);
        }
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect to backend: ${e.toString()}',
      };
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['token'] is String) {
          await FirebaseAuthHelper.storeAuthToken(responseData['token']);
        }
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect to backend: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // PROFILE & SETTINGS ENDPOINTS
  // ==========================================

  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    String? name,
    String? email,
    String? phone,
    int? age,
  }) async {
    final url = Uri.parse('$baseUrl/update_user_profile');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id': userId,
          'name': name,
          'email': email,
          'phone': phone,
          'age': age,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to update profile: ${e.toString()}',
      };
    }
  }

  /// Update password
  static Future<Map<String, dynamic>> updatePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/update_password');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id': userId,
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to update password: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // MEDICATIONS ENDPOINTS
  // ==========================================

  /// Get medications for a user
  static Future<Map<String, dynamic>> getMedications(int userId) async {
    final url = Uri.parse('$baseUrl/get_medications/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch medications',
          'medications': [],
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
        'medications': [],
      };
    }
  }

  /// Add a medication
  static Future<Map<String, dynamic>> addMedication({
    required int userId,
    required String medicineName,
    required String dose,
    required String frequency,
    required String timing,
    String? description,
    String? takeWith,
  }) async {
    final url = Uri.parse('$baseUrl/add_medication');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'medicine_name': medicineName,
          'dose': dose,
          'frequency': frequency,
          'timing': timing,
          'description': description ?? '',
          'take_with': takeWith ?? '',
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to add medication: ${e.toString()}',
      };
    }
  }

  /// Delete a medication
  static Future<Map<String, dynamic>> deleteMedication({
    required int userId,
    required String medicineName,
  }) async {
    final url = Uri.parse(
      '$baseUrl/delete_medication/$userId/${Uri.encodeComponent(medicineName)}',
    );

    try {
      final response = await http.delete(url);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to delete medication: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // REMINDERS ENDPOINTS
  // ==========================================

  /// Get reminders for a user
  static Future<Map<String, dynamic>> getReminders(int userId) async {
    final url = Uri.parse('$baseUrl/get_reminders/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch reminders',
          'reminders': [],
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
        'reminders': [],
      };
    }
  }

  /// Add a reminder
  static Future<Map<String, dynamic>> addReminder({
    required int userId,
    required String title,
    required String reminderType,
    required String reminderDate,
    required String reminderTime,
  }) async {
    final url = Uri.parse('$baseUrl/add_reminder');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'title': title,
          'reminder_type': reminderType,
          'reminder_date': reminderDate,
          'reminder_time': reminderTime,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to add reminder: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // NOTIFICATION SETTINGS ENDPOINTS
  // ==========================================

  /// Get notification settings
  static Future<Map<String, dynamic>> getNotificationSettings(
    int userId,
  ) async {
    final url = Uri.parse('$baseUrl/get_notification_settings/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch settings',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
      };
    }
  }

  /// Save notification settings
  static Future<Map<String, dynamic>> saveNotificationSettings({
    required int userId,
    bool allNotifications = true,
    bool emergencyAlerts = true,
    bool aiAlerts = true,
    bool patientUpdates = true,
  }) async {
    final url = Uri.parse('$baseUrl/save_notification_settings');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'all_notifications': allNotifications,
          'emergency_alerts': emergencyAlerts,
          'ai_alerts': aiAlerts,
          'patient_updates': patientUpdates,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to save settings: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // PRIVACY SETTINGS ENDPOINTS
  // ==========================================

  /// Get privacy settings
  static Future<Map<String, dynamic>> getPrivacySettings(int userId) async {
    final url = Uri.parse('$baseUrl/get_privacy_settings/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch privacy settings',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
      };
    }
  }

  /// Save privacy settings
  static Future<Map<String, dynamic>> savePrivacySettings({
    required int userId,
    bool biometricLogin = true,
    bool shareHealthData = false,
    bool emergencyAccess = true,
    bool rememberDevice = true,
    bool appLock = false,
  }) async {
    final url = Uri.parse('$baseUrl/save_privacy_settings');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'biometric_login': biometricLogin,
          'share_health_data': shareHealthData,
          'emergency_access': emergencyAccess,
          'remember_device': rememberDevice,
          'app_lock': appLock,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to save privacy settings: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // FAMILY CONTACTS ENDPOINTS
  // ==========================================

  /// Get family contacts
  static Future<Map<String, dynamic>> getFamilyContacts(int userId) async {
    final url = Uri.parse('$baseUrl/get_family_contacts/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch contacts',
          'contacts': [],
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
        'contacts': [],
      };
    }
  }

  /// Add family contact
  static Future<Map<String, dynamic>> addFamilyContact({
    required int userId,
    required String name,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseUrl/add_family_contact');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'name': name,
          'phone_number': phoneNumber,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to add contact: ${e.toString()}',
      };
    }
  }

  /// Delete family contact
  static Future<Map<String, dynamic>> deleteFamilyContact(int contactId) async {
    final url = Uri.parse('$baseUrl/delete_family_contact/$contactId');

    try {
      final response = await http.delete(url);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to delete contact: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // MEDICAL HISTORY ENDPOINTS
  // ==========================================

  /// Get medical history for a user
  static Future<Map<String, dynamic>> getMedicalHistory(int userId) async {
    final url = Uri.parse('$baseUrl/get_medical_history/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch medical history',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // PATIENT/DOCTOR ENDPOINTS
  // ==========================================

  /// Get patient details
  static Future<Map<String, dynamic>> getPatientDetails(
    String patientId,
  ) async {
    final url = Uri.parse('$baseUrl/get_patient_details/$patientId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch patient details',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
      };
    }
  }

  /// Update or add patient
  static Future<Map<String, dynamic>> updateOrAddPatient({
    required String patientId,
    required int doctorId,
    String? name,
    int? age,
    String? gender,
    String? medicalCondition,
    String? lastEegInfo,
    String? email,
    String? phone,
    String? address,
    String? emergencyContact,
    String? additionalNotes,
  }) async {
    final url = Uri.parse('$baseUrl/update_or_add_patient');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'name': name,
          'age': age,
          'gender': gender,
          'medical_condition': medicalCondition,
          'last_eeg_info': lastEegInfo,
          'email': email,
          'phone': phone,
          'address': address,
          'emergency_contact': emergencyContact,
          'additional_notes': additionalNotes,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to update patient: ${e.toString()}',
      };
    }
  }

  /// Get all patients for a doctor
  static Future<Map<String, dynamic>> getAllPatients(int doctorId) async {
    final url = Uri.parse('$baseUrl/get_all_patients?doctor_id=$doctorId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch patients',
          'patients': [],
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
        'patients': [],
      };
    }
  }

  /// Get recent patients for a doctor
  static Future<Map<String, dynamic>> getRecentPatients(int doctorId) async {
    final url = Uri.parse('$baseUrl/get_recent_patients?doctor_id=$doctorId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch recent patients',
          'patients': [],
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
        'patients': [],
      };
    }
  }

  /// Get dashboard stats
  static Future<Map<String, dynamic>> getDashboardStats(int doctorId) async {
    final url = Uri.parse('$baseUrl/get_dashboard_stats?doctor_id=$doctorId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch dashboard stats',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
      };
    }
  }

  /// Get patient screen stats
  static Future<Map<String, dynamic>> getPatientScreenStats(
    int doctorId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/get_patient_screen_stats?doctor_id=$doctorId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch patient stats',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // CHAT HISTORY ENDPOINTS
  // ==========================================

  /// Get chat history for a user
  static Future<Map<String, dynamic>> getChatHistory(int userId) async {
    final url = Uri.parse('$baseUrl/get_chat_history/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch chat history',
          'conversations': [],
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to connect: ${e.toString()}',
        'conversations': [],
      };
    }
  }

  /// Save a chat message
  static Future<Map<String, dynamic>> saveChatMessage({
    required int userId,
    required String text,
    required bool isUser,
    required String timestamp,
  }) async {
    final url = Uri.parse('$baseUrl/save_chat_message');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'text': text,
          'is_user': isUser ? 1 : 0,
          'timestamp': timestamp,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to save message: ${e.toString()}',
      };
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Check if backend is reachable
  static Future<bool> checkBackendConnection() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 404 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

