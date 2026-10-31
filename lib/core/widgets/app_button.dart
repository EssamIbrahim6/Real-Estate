import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_dimensions.dart';

enum AppButtonType { primary, secondary, outlined, text }

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _handleTap() {
    if (widget.isLoading || widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget child = widget.isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: widget.type == AppButtonType.primary
                  ? colors.onPrimary
                  : colors.primary,
            ),
          )
        : (widget.icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.icon!,
                    const SizedBox(width: AppDimensions.p8),
                    Text(widget.text),
                  ],
                )
              : Text(widget.text));

    return Listener(
      onPointerDown: (_) {
        if (!widget.isLoading && widget.onPressed != null) {
          setState(() => _isPressed = true);
        }
      },
      onPointerUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      onPointerCancel: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: _buildButton(context, child),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, Widget child) {
    final colors = Theme.of(context).colorScheme;
    final callback = widget.isLoading || widget.onPressed == null
        ? null
        : _handleTap;

    switch (widget.type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r16),
            ),
          ),
          child: child,
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.secondary,
            foregroundColor: colors.onSecondary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r16),
            ),
          ),
          onPressed: callback,
          child: child,
        );
      case AppButtonType.outlined:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r16),
            ),
          ),
          onPressed: callback,
          child: child,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: callback,
          child: child,
        );
    }
  }
}
