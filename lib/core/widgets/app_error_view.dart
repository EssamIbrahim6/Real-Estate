import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.message, this.onRetry});

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
                color: colors.errorContainer.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.25),
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
                Icons.error_outline_rounded,
                size: 40,
                color: colors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.p24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: AppButton(
                  text: AppStrings.retry,
                  onPressed: onRetry,
                  type: AppButtonType.outlined,
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
