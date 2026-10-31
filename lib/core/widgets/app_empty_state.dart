import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;
  final double iconSize;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.iconSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p24,
          vertical: AppDimensions.p32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: colors.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            if (description != null && description!.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.p8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: AppDimensions.p24),
              customAction!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.p24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: AppButton(
                  text: actionLabel!,
                  onPressed: onAction,
                  height: AppDimensions.buttonHeightMd,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

