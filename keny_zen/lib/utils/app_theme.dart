import 'package:flutter/material.dart';

// stores app-wide calm blue theme
class AppTheme {
  // calm blue color palette
  static const Color deepBlue = Color(0xFF1565C0);
  static const Color softBlue = Color(0xFF64B5F6);
  static const Color paleBlue = Color(0xFFE3F2FD);
  static const Color calmBackground = Color(0xFFF3F9FF);

  // light theme for Keny-Zen
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: calmBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: deepBlue,
      primary: deepBlue,
      secondary: softBlue,
      surface: Colors.white,
    ),

    // app bar styling
    appBarTheme: const AppBarTheme(
      backgroundColor: deepBlue,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
    ),

    // button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    // floating button styling
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: deepBlue,
      foregroundColor: Colors.white,
    ),

    // card styling
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // input styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: deepBlue, width: 2),
      ),
    ),

    // bottom nav styling
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: deepBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
  );
}