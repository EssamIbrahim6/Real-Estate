import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ListingResultsHeader extends StatelessWidget {
  final int resultCount;

  const ListingResultsHeader({super.key, required this.resultCount});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.home_work_outlined,
              color: colors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.listingsResultsTitle ?? 'Homes to explore',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n?.listingsResultsCount(resultCount) ??
                      '$resultCount properties selected for you',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$resultCount',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
