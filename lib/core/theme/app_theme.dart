import 'package:flutter/material.dart';
import 'package:viteezy/core/theme/app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'saansTrial',
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      error: AppColors.errorColor,
      surface: AppColors.surfaceColor,
      background: AppColors.backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.textOnPrimary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnPrimary,
        fontFamily: 'saansTrial',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
      ),
    ),
    // textTheme removed - using TextStyles methods directly instead
    // textTheme: TextTheme(
    //   displayLarge: TextStyles.heading1,
    //   displayMedium: TextStyles.heading2,
    //   displaySmall: TextStyles.heading3,
    //   headlineMedium: TextStyles.heading4,
    //   titleLarge: TextStyles.titleLarge,
    //   titleMedium: TextStyles.titleMedium,
    //   bodyLarge: TextStyles.bodyLarge,
    //   bodyMedium: TextStyles.bodyMedium,
    //   bodySmall: TextStyles.bodySmall,
    //   labelLarge: TextStyles.button,
    // ),
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: AppColors.surfaceColor,
    //   border: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
    //   ),
    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
    //   ),
    //   errorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(8),
    //     borderSide: const BorderSide(color: AppColors.errorColor),
    //   ),
    // ),
  );

  // Dark Theme (optional)
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'saansTrial',
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.textPrimary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      error: AppColors.errorColor,
      surface: AppColors.primaryDark,
      background: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.textOnPrimary,
    ),
    cardTheme: CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );
}
