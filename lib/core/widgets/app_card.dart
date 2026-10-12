import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppDimensions.radius12;

    return Card(
      elevation: elevation ?? AppDimensions.elevationLow,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimensions.p16),
          child: child,
        ),
      ),
    );
  }
}
