/// NeuroGuard AI - Client-Side Firebase Auth Helper & Request Interceptor
/// =========================================================================
/// Provides unified client-side authentication header retrieval for Flutter.
/// Attaches Firebase ID Token or local session token to all outgoing HTTP REST requests.
library;

import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthHelper {
  static const String _tokenStorageKey = 'auth_token';

  /// Retrieve active authorization headers for HTTP requests.
  /// If a stored token (Firebase ID token or HS256 JWT) exists, attaches `Authorization: Bearer <token>`.
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenStorageKey);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Store the authenticated token locally.
  static Future<void> storeAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenStorageKey, token);
  }

  /// Clear session on logout.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenStorageKey);
  }
}
