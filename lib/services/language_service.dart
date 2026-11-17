import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:neuroguard_ai/config/app_config.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale('en');
  int? _currentUserId;

  Locale get locale => _locale;
  int? get currentUserId => _currentUserId;

  static LanguageProvider? _instance;
  static LanguageProvider get instance {
    assert(_instance != null, 'LanguageProvider.instance accessed before initialization. Call LanguageProvider.initialize() first.');
    return _instance!;
  }

  LanguageProvider() {
    _instance = this;
  }

  static final String _prefsKey = 'user_language';

  static final List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'nativeName': 'English', 'flag': '🇬🇧'},
    {'code': 'es', 'nativeName': 'Español', 'flag': '🇪🇸'},
    {'code': 'ur', 'nativeName': 'اردو', 'flag': '🇵🇰'},
    {'code': 'ar', 'nativeName': 'العربية', 'flag': '🇸🇦'},
    {'code': 'fr', 'nativeName': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'nativeName': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'tr', 'nativeName': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'zh', 'nativeName': '中文（简体）', 'flag': '🇨🇳'},
  ];

  /// Load saved language for the current user from SharedPreferences.
  /// Falls back to 'en' if nothing is saved.
  Future<void> loadSavedLanguage(dynamic userId) async {
    _currentUserId = (userId is int) ? userId : int.tryParse(userId?.toString() ?? '');
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('$_prefsKey$userId');
    if (savedLang != null && _isSupported(savedLang)) {
      _locale = Locale(savedLang);
    } else {
      _locale = Locale('en');
    }
    notifyListeners();
  }

  /// Change the application language and persist it.
  Future<void> setLanguage(String languageCode, dynamic userId) async {
    if (!_isSupported(languageCode)) return;
    _currentUserId = (userId is int) ? userId : int.tryParse(userId?.toString() ?? '');
    _locale = Locale(languageCode);

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKey$userId', languageCode);

    // Save to backend
    try {
      await http.post(
        Uri.parse("${AppConfig.baseUrl}/save_language_preference"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'language': languageCode}),
      );
    } catch (_) {
      // Backend save is best-effort; local persistence is primary
    }

    notifyListeners();
  }

  /// Get the language name for display purposes
  static String languageName(String code) {
    for (final lang in supportedLanguages) {
      if (lang['code'] == code) return lang['nativeName']!;
    }
    return 'English';
  }

  /// Get the flag emoji for a language code
  static String languageFlag(String code) {
    for (final lang in supportedLanguages) {
      if (lang['code'] == code) return lang['flag']!;
    }
    return '🇬🇧';
  }

  bool _isSupported(String code) {
    return supportedLanguages.any((l) => l['code'] == code);
  }
}

