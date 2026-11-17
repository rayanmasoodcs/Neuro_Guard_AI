import 'dart:convert';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:neuroguard_ai/config/app_config.dart';

/// AlertsService - Comprehensive alerts management for NeuroGuard AI
/// 
/// This singleton service handles:
/// 1. Storing seizure events with date/time for alert scheduling
/// 2. Retrieving upcoming medication and appointment alerts
/// 3. Managing emergency alerts that trigger even when app is closed
/// 4. Integrating with the backend notification scheduler
/// 
/// The service communicates with Node.js + MongoDB endpoints at /api/seizure/*
class AlertsService {
  static final AlertsService _instance = AlertsService._internal();

  factory AlertsService() {
    return _instance;
  }

  AlertsService._internal();

  /// Get base URL based on platform (web vs mobile)
  String get baseUrl {
    if (kIsWeb) return AppConfig.baseUrl;
    try {
      if (Platform.isAndroid) return "http://10.0.2.2:5000";
    } catch (_) {}
    return AppConfig.baseUrl;
  }

  /// Store a seizure event occurrence with date/time
  /// 
  /// When a seizure is detected or recorded, store it with the date/time
  /// so the backend can match it with upcoming medication and appointment times
  /// to trigger appropriate notifications.
  /// 
  /// Args:
  ///   userId: Logged-in user ID
  ///   seizureType: Type of seizure (e.g., 'Generalized Tonic-Clonic')
  ///   eventDate: Date of seizure occurrence (YYYY-MM-DD)
  ///   eventTime: Time of seizure occurrence (HH:mm:ss)
  ///   severity: Severity level ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')
  ///   patientId: Optional patient ID for records
  ///   description: Detailed description of the event
  /// 
  /// Returns: Map with status and event_id if successful
  Future<Map<String, dynamic>> storeSeizureEvent({
    required int userId,
    required String seizureType,
    required String eventDate,
    required String eventTime,
    required String severity,
    String? patientId,
    String? description,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/seizure/store_seizure_event');
      
      // Create request payload
      final requestBody = {
        'user_id': userId,
        'seizure_type': seizureType,
        'event_date': eventDate,
        'event_time': eventTime,
        'severity': severity,
        'patient_id': patientId,
        'description': description,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to store seizure event: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Connection error: $e',
      };
    }
  }

  /// Retrieve seizure events for a user
  /// 
  /// Fetches stored seizure events with optional date range filtering
  /// 
  /// Args:
  ///   userId: User ID to fetch events for
  ///   days: Number of days to look back (default: 30)
  ///   limit: Maximum number of results to return (default: 50)
  /// 
  /// Returns: List of seizure events with metadata
  Future<List<Map<String, dynamic>>> getSeizureEvents({
    required int userId,
    int days = 30,
    int limit = 50,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/seizure/get_seizure_events/$userId?days=$days&limit=$limit',
      );

      final response = await http.get(url)
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['events'] ?? []);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching seizure events: $e');
      return [];
    }
  }

  /// Get upcoming alerts for medication and appointments
  /// 
  /// Retrieves alerts that should trigger notifications based on:
  /// 1. Seizure events matching medication reminder times
  /// 2. Seizure events matching appointment times
  /// 3. Emergency conditions requiring immediate notification
  /// 
  /// Args:
  ///   userId: User ID
  ///   hoursAhead: How many hours ahead to check for upcoming alerts (default: 24)
  /// 
  /// Returns: List of upcoming alerts with notification details
  Future<List<Map<String, dynamic>>> getUpcomingAlerts({
    required int userId,
    int hoursAhead = 24,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/seizure/get_upcoming_alerts/$userId?hours_ahead=$hoursAhead',
      );

      final response = await http.get(url)
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['upcoming_alerts'] ?? []);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching upcoming alerts: $e');
      return [];
    }
  }

  /// Acknowledge a seizure event and add doctor's notes
  /// 
  /// Called by doctors to acknowledge a seizure event and add clinical notes
  /// for the patient's medical record.
  /// 
  /// Args:
  ///   eventId: The seizure event ID to acknowledge
  ///   doctorNotes: Clinical notes about the seizure
  ///   medicationAdjustment: Optional medication adjustment notes
  /// 
  /// Returns: Map with acknowledgment status
  Future<Map<String, dynamic>> acknowledgeSeizureEvent({
    required int eventId,
    required String doctorNotes,
    String? medicationAdjustment,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/seizure/acknowledge_seizure_event/$eventId',
      );

      final requestBody = {
        'acknowledged': true,
        'doctor_notes': doctorNotes,
        'medication_adjustment': medicationAdjustment,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to acknowledge seizure event',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Connection error: $e',
      };
    }
  }

  /// Send an emergency alert notification
  /// 
  /// Triggers emergency alert that works even when app is closed.
  /// Uses Firebase Cloud Messaging (FCM) on the backend.
  /// 
  /// Args:
  ///   userId: User ID
  ///   patientId: Patient identifier
  ///   alertType: Type of emergency ('SEIZURE_DETECTED', 'FALL_DETECTED', 'MULTIPLE_SEIZURES')
  ///   message: Alert message to display
  ///   severity: Severity level ('HIGH' or 'CRITICAL')
  ///   emergencyContacts: List of emergency contact info
  /// 
  /// Returns: Map with alert ID and status
  Future<Map<String, dynamic>> sendEmergencyAlert({
    required int userId,
    required String patientId,
    required String alertType,
    required String message,
    required String severity,
    List<String>? emergencyContacts,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/seizure/send_emergency_alert');

      final requestBody = {
        'user_id': userId,
        'patient_id': patientId,
        'alert_type': alertType,
        'message': message,
        'severity': severity,
        'emergency_contacts': emergencyContacts,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to send emergency alert: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Connection error: $e',
      };
    }
  }

  /// Trigger a notification for a specific event
  /// 
  /// Used internally by the notification scheduler or manually by the app
  /// to send a notification for a seizure event-related alert.
  /// 
  /// Args:
  ///   eventId: The seizure event ID
  ///   userId: User ID
  ///   notificationType: Type of notification ('medication' or 'appointment')
  ///   title: Notification title
  ///   message: Notification message
  ///   sendEmergencyAlert: Whether this should be sent as emergency alert
  /// 
  /// Returns: Map with notification status
  Future<Map<String, dynamic>> triggerNotification({
    required int eventId,
    required int userId,
    required String notificationType,
    required String title,
    required String message,
    bool sendEmergencyAlert = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/seizure/trigger_notification');

      final requestBody = {
        'event_id': eventId,
        'user_id': userId,
        'notification_type': notificationType,
        'title': title,
        'message': message,
        'send_emergency_alert': sendEmergencyAlert,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to trigger notification',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Connection error: $e',
      };
    }
  }

  /// Format datetime for backend API (YYYY-MM-DD HH:mm:ss)
  String formatDateTimeForAPI(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  /// Format date for backend API (YYYY-MM-DD)
  String formatDateForAPI(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  /// Format time for backend API (HH:mm:ss)
  String formatTimeForAPI(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  /// Parse DateTime from API response
  DateTime parseAPIDateTime(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }
}




