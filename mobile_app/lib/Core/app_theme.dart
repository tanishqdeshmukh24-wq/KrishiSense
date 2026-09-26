import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentGreen,
    ),

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryGreen,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGreen,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        side: const BorderSide(
          color: Color(0xFFE3EAE4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.primaryGreen,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.secondaryText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.secondaryText,
      ),
    ),
  );
}