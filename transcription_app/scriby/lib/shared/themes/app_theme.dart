import 'package:flutter/material.dart';

/// Scriby App Theme Configuration
/// Follows Material Design 3 principles with custom Scriby branding
class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF10B981); // Emerald
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  
  // Recording States Colors
  static const Color recordingColor = Color(0xFFDC2626); // Red for recording
  static const Color processingColor = Color(0xFFF59E0B); // Amber for processing
  static const Color completedColor = Color(0xFF10B981); // Green for completed
  
  // Neutral Colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color onSurfaceLight = Color(0xFF1F2937);
  static const Color onSurfaceDark = Color(0xFFE5E7EB);

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceLight,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurfaceLight,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: onSurfaceLight,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceLight,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurfaceLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: onSurfaceLight,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: onSurfaceLight,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceLight,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceLight,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: onSurfaceLight,
        ),
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1F1F1F),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Typography (same as light theme but with dark colors)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurfaceDark,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: onSurfaceDark,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceDark,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurfaceDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: onSurfaceDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: onSurfaceDark,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceDark,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceDark,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: onSurfaceDark,
        ),
      ),
    );
  }
}
