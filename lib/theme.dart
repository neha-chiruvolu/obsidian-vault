import 'package:flutter/material.dart';

/// Obsidian palette: black metal, steel blue, emerald, teal and mustard gold.
class AppColors {
  static const bg = Color(0xFF050709);
  static const panelTop = Color(0xFF1A2025);
  static const panelBottom = Color(0xFF0C1013);
  static const well = Color(0xFF07090B);
  static const mustard = Color(0xFFE3A917);
  static const goldLight = Color(0xFFFFD66B);
  static const goldDark = Color(0xFF8A5E00);
  static const onGold = Color(0xFF1A1200);
  static const green = Color(0xFF18C98A);
  static const teal = Color(0xFF14B8A6);
  static const blue = Color(0xFF3B93D1);
  static const navy = Color(0xFF2A6C9B);
  static const ink = Color(0xFFE9EEF1);
  static const muted = Color(0xFF7F8E98);
  static const red = Color(0xFFE5484D);
}

TextStyle mono(double size, Color color,
        {FontWeight weight = FontWeight.w700, double spacing = 1}) =>
    TextStyle(
      fontFamily: 'monospace',
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: spacing,
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.mustard,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.mustard,
    secondary: AppColors.teal,
    tertiary: AppColors.green,
    surface: const Color(0xFF12171A),
    onSurface: AppColors.ink,
  );

  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: const Color(0xFF12171A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.ink,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF080B0D),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.muted,
      border: b(Colors.white12),
      enabledBorder: b(Colors.white12),
      focusedBorder: b(AppColors.mustard, 1.5),
      errorBorder: b(AppColors.red),
      focusedErrorBorder: b(AppColors.red, 1.5),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.muted),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1E262B),
      contentTextStyle: const TextStyle(color: AppColors.ink),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
  );
}

class Breakpoints {
  static bool isMobile(double w) => w < 600;
  static bool isTablet(double w) => w >= 600 && w < 900;
  static bool isDesktop(double w) => w >= 900;
}
