import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

class AppTheme {
  // Cores principais
  static const Color background = Color(0xFF0D0D12);
  static const Color surface = Color(0xFF17171F);
  static const Color primary = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color border = Color(0xFF292934);

  // Cores semânticas
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color muted = textSecondary;

  // Tipografia
  static const TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: AppDimensions.fontXXL,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: AppDimensions.fontXL,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: AppDimensions.fontLG,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(fontSize: AppDimensions.fontMD, color: textPrimary),
    bodyMedium: TextStyle(fontSize: AppDimensions.fontMD, color: textSecondary),
    bodySmall: TextStyle(fontSize: AppDimensions.fontSM, color: textSecondary),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: border),
        ),
      ),
    );
  }
}
