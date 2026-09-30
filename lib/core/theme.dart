import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE63946);
  static const Color secondaryColor = Color(0xFF457B9D);
  static const Color accentColor = Color(0xFFA8DADC);
  static const Color backgroundColor = Color(0xFF1D3557);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color surfaceColor = Color(0xFF1E293B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
