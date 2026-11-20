import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ReviewCommentField extends StatelessWidget {
  const ReviewCommentField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      maxLines: 4,
      maxLength: 300,
      style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface),
      decoration: InputDecoration(
        hintText:
            l10n?.detailsReviewCommentHint ??
            'Share your thoughts about this estate...',
        filled: true,
        fillColor: colors.surfaceContainerLow,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
