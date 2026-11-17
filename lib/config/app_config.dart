import 'package:flutter/foundation.dart';

/// Central runtime configuration for the NeuroGuard Node.js + MongoDB API.
///
/// Local development defaults:
/// - Web/desktop/iOS: 127.0.0.1:5000 (Node.js + MongoDB)
/// - Android emulator: 10.0.2.2:5000 (Node.js + MongoDB)
///
/// Override with: flutter run --dart-define=NEUROGUARD_API_URL=https://api.example.com
class AppConfig {
  AppConfig._();

  static const String? overrideBaseUrl = String.fromEnvironment(
    'NEUROGUARD_API_URL',
  );

  static String get baseUrl {
    final override = overrideBaseUrl;
    if (override != null && override.isNotEmpty) {
      return override.replaceFirst(RegExp(r'/+$'), '');
    }

    if (kIsWeb) return 'http://127.0.0.1:5000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:5000';
    }
  }
}
