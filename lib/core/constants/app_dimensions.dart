import 'package:flutter/material.dart';

abstract class AppDimensions {
  // Padding & Margin
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  // Border Radius
  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;
  static const double rFull = 999.0;

  static const BorderRadius radius8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius radius12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(r24));

  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Button Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
