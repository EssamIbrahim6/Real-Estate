import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.textLight,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.titleLarge,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: AppDimensions.elevationLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.radius12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightMd,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radius12,
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p16,
          vertical: AppDimensions.p16,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.darkBackground,
        // onSurface: AppColors.darkTextPrimary,
        onError: AppColors.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        // iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          // color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: AppDimensions.elevationLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.radius12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.darkBackground,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightMd,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radius12,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.darkBackground,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p16,
          vertical: AppDimensions.p16,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.error),
        ),
        // hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextMuted),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
    );
  }
}
