import 'package:flutter/material.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

import '../../../../core/constants/app_dimensions.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: SizedBox(
        height: AppDimensions.buttonHeightMd,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: colors.surfaceContainerLowest,
            side: BorderSide(color: colors.outlineVariant, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppDimensions.p8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: colors.outlineVariant),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            (l10n?.commonOr ?? 'OR').toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: colors.outlineVariant),
        ),
      ],
    );
  }
}
