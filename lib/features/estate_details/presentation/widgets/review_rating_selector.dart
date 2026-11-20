import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ReviewRatingSelector extends StatelessWidget {
  const ReviewRatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n?.detailsRatingSemantics(rating) ?? 'Rating: $rating out of 5',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final value = index + 1;
          final isSelected = value <= rating;
          final colors = Theme.of(context).colorScheme;
          return IconButton(
            key: ValueKey<String>('review-star-$value'),
            tooltip:
                l10n?.detailsStarRatingTooltip(value) ??
                'Select a $value-star rating',
            onPressed: () => onChanged(value),
            icon: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isSelected ? colors.tertiary : colors.onSurfaceVariant,
              size: 34,
            ),
          );
        }),
      ),
    );
  }
}
