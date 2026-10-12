import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Design Tokens
  static const Color brandGreen = Color(
    0xFF72D600,
  ); // Lime-green primary button
  static const Color brandNavy = Color(0xFF17254D); // Dark navy title & text
  static const Color brandNavyLight = Color(0xFF26364A);
  static const Color brandAccent = Color(0xFF1D5270);
  static const Color inputBackground = Color(
    0xFFF5F4F9,
  ); // Light lavender/gray input
  static const Color inputBorder = Color(0xFFE8E7ED);

  // Primary Palette
  static const Color primary = Color(0xFF17254D);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color greenColors = Color(0xFF72D600);

  // Secondary / Accent Palette
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color secondaryDark = Color(0xFF115E59);

  // Neutral Palette
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8E7ED);
  static const Color border = Color(0xFFE2E8F0);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);

  // Text Colors
  static const Color textPrimary = Color(0xFF17254D);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textMuted = Color(0xFFA0A5B5);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color transparent = Colors.transparent;
}
