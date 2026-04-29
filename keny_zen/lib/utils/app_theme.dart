import 'package:flutter/material.dart';

// stores app-wide calm blue theme
class AppTheme {
  // calm blue color palette
  static const Color deepBlue = Color(0xFF0D47A1);
  static const Color oceanBlue = Color(0xFF1565C0);
  static const Color softBlue = Color(0xFF64B5F6);
  static const Color paleBlue = Color(0xFFE3F2FD);
  static const Color calmBackground = Color(0xFFF1F8FF);
  static const Color tealAccent = Color(0xFF26A69A);

  // reusable calm gradient
  static const LinearGradient calmGradient = LinearGradient(
    colors: [
      deepBlue,
      oceanBlue,
      softBlue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // light theme for Keny-Zen
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: calmBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: deepBlue,
      primary: deepBlue,
      secondary: tealAccent,
      surface: Colors.white,
    ),

    // app bar styling
    appBarTheme: const AppBarTheme(
      backgroundColor: deepBlue,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 3,
    ),

    // button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // floating button styling
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: deepBlue,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // card styling
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: deepBlue.withAlpha(35),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // input styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: deepBlue, width: 2),
      ),
    ),

    // bottom nav styling
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: deepBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
    ),
  );
}