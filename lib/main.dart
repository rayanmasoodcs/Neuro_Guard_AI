import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'services/language_service.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final languageProvider = LanguageProvider();
  runApp(NeuroGuardAI(languageProvider: languageProvider));
}

class NeuroGuardAI extends StatelessWidget {
  final LanguageProvider languageProvider;
  const NeuroGuardAI({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'NeuroGuard AI',
          debugShowCheckedModeBanner: false,
          locale: languageProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(languageProvider: languageProvider),
        );
      },
    );
  }
}

