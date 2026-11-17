/// Drop-in replacement for `package:http/http.dart` that attaches the stored
/// session token to requests sent to the NeuroGuard backend.
///
/// Import as `import '.../services/api_http.dart' as http;` and keep using
/// `http.get` / `http.post` / `http.delete` unchanged. Requests to any other
/// host are sent without the token.
library;

import 'dart:convert';

import 'package:http/http.dart' as base;
import 'package:neuroguard_ai/config/app_config.dart';
import 'firebase_auth_helper.dart';

export 'package:http/http.dart' hide get, post, put, delete, patch, head;

Future<Map<String, String>> _withAuth(Uri url, Map<String, String>? headers) async {
  final merged = <String, String>{...?headers};
  if (url.toString().startsWith(AppConfig.baseUrl) &&
      !merged.keys.any((k) => k.toLowerCase() == 'authorization')) {
    final auth = (await FirebaseAuthHelper.getAuthHeaders())['Authorization'];
    if (auth != null) merged['Authorization'] = auth;
  }
  return merged;
}

Future<base.Response> get(Uri url, {Map<String, String>? headers}) async =>
    base.get(url, headers: await _withAuth(url, headers));

Future<base.Response> post(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) async =>
    base.post(url, headers: await _withAuth(url, headers), body: body, encoding: encoding);

Future<base.Response> put(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) async =>
    base.put(url, headers: await _withAuth(url, headers), body: body, encoding: encoding);

Future<base.Response> delete(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) async =>
    base.delete(url, headers: await _withAuth(url, headers), body: body, encoding: encoding);
