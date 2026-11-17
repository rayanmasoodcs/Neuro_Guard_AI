import 'package:flutter/material.dart';

class AppTheme {
  static Color primaryDarkGreen = Color(0xFF0B8F55);
  static Color secondaryLightGreen = Color(0xFF22C55E);
  static Color surfaceWhite = Colors.white;
  static Color lightGreenBg = Color(0xFFE9FFF4);
  static Color scaffoldBg = Color(0xFFF5F8FA);

  static final ColorScheme _greenColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryDarkGreen,
    onPrimary: Colors.white,
    secondary: secondaryLightGreen,
    onSecondary: Colors.white,
    tertiary: primaryDarkGreen,
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: surfaceWhite,
    onSurface: Colors.black87,
    surfaceContainerHighest: lightGreenBg,
    onSurfaceVariant: Colors.black87,
    outline: secondaryLightGreen,
    outlineVariant: lightGreenBg,
    shadow: Colors.black26,
    scrim: Colors.black26,
    inverseSurface: Colors.black87,
    onInverseSurface: Colors.white,
    inversePrimary: secondaryLightGreen,
  );

  static ThemeData buildThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _greenColorScheme,
      primaryColor: primaryDarkGreen,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamilyFallback: ['NotoNaskhArabic', 'NotoSansSC', 'Roboto'],
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDarkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primaryDarkGreen, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkGreen,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryDarkGreen,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}


