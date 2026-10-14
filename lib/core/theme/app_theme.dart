import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

abstract class AppTheme {
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brandNavy,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.brandNavy,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF8FAFC),
    surfaceContainer: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE8EEF4),
    surfaceContainerHighest: Color(0xFFDCE4ED),
    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),
    shadow: Color(0x1A0F172A),
    scrim: Color(0x66000000),
    inverseSurface: Color(0xFF26364A),
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFFAAB8E0),
    tertiary: Color(0xFF4E8500),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEAF5D9),
    onTertiaryContainer: Color(0xFF304F00),
    errorContainer: Color(0xFFFFEDEA),
    onErrorContainer: Color(0xFF8A1C12),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA8D84D),
    onPrimary: Color(0xFF17220A),
    secondary: AppColors.secondaryLight,
    onSecondary: Color(0xFF003A34),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF5F0000),
    surface: AppColors.darkSurface,
    onSurface: Color(0xFFF1F5F9),
    surfaceContainerLowest: Color(0xFF0B1220),
    surfaceContainerLow: Color(0xFF172337),
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: Color(0xFF29384D),
    surfaceContainerHighest: Color(0xFF34445A),
    outline: Color(0xFF64748B),
    outlineVariant: Color(0xFF3C4B60),
    shadow: Colors.black,
    scrim: Color(0x99000000),
    inverseSurface: Color(0xFFE2E8F0),
    onInverseSurface: Color(0xFF17254D),
    inversePrimary: AppColors.brandNavy,
    tertiary: Color(0xFFB7E56E),
    onTertiary: Color(0xFF233600),
    tertiaryContainer: Color(0xFF344D14),
    onTertiaryContainer: Color(0xFFE2F6BD),
    errorContainer: Color(0xFF601410),
    onErrorContainer: Color(0xFFFFDAD5),
  );

  static ThemeData get lightTheme => _buildTheme(_lightScheme);
  static ThemeData get darkTheme => _buildTheme(_darkScheme);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final textTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final roundedShape = RoundedRectangleBorder(
      borderRadius: AppDimensions.radius12,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      primaryColor: scheme.primary,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xFFF8FAFC),
      textTheme: textTheme,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: roundedShape.copyWith(
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, AppDimensions.buttonHeightMd),
          shape: roundedShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, AppDimensions.buttonHeightMd),
          shape: roundedShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, AppDimensions.buttonHeightMd),
          side: BorderSide(color: scheme.outline),
          shape: roundedShape,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p16,
          vertical: AppDimensions.p16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r24),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r24),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }
}
