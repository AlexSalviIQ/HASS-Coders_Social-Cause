import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Blues - vibrant
  static const Color deepBlue = Color(0xFF1565C0);
  static const Color deepBlueDark = Color(0xFF0D47A1);
  static const Color deepBlueLight = Color(0xFF42A5F5);
  // Greens - vibrant
  static const Color emeraldGreen = Color(0xFF00C853);
  static const Color emeraldGreenDark = Color(0xFF00A846);
  static const Color emeraldGreenLight = Color(0xFF69F0AE);
  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F7FA);
  static const Color lightGrey = Color(0xFFE0E4EA);
  static const Color mediumGrey = Color(0xFF8E99A4);
  static const Color darkGrey = Color(0xFF4A5568);
  static const Color charcoal = Color(0xFF1A202C);
  // Chat
  static const Color aiBubble = Color(0xFFE3F2FD);
  static const Color userBubble = Color(0xFF00C853);
  // Status
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  // Dark mode
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF21262D);
  static const Color darkBorder = Color(0xFF30363D);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.deepBlue,
    scaffoldBackgroundColor: AppColors.offWhite,
    colorScheme: ColorScheme.light(
      primary: AppColors.deepBlue,
      secondary: AppColors.emeraldGreen,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.charcoal,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.deepBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shadowColor: AppColors.deepBlue.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGrey.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deepBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.deepBlueLight,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppColors.deepBlueLight,
      secondary: AppColors.emeraldGreen,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 1,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.deepBlueLight,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
