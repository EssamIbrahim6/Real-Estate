import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

enum AppButtonType { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonType type;
  final Widget? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeightMd,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon!,
                    const SizedBox(width: AppDimensions.p8),
                    Text(text),
                  ],
                )
              : Text(text));

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(context, child),
    );
  }

  Widget _buildButton(BuildContext context, Widget child) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}
