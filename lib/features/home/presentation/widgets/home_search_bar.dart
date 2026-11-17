import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeSearchBar({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primary, colors.primary.withValues(alpha: 0.84)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              PositionedDirectional(
                end: -32,
                top: -54,
                child: Container(
                  width: 156,
                  height: 156,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.onPrimary.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.homeHeroTitle ?? 'Find a place to call home',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.12,
                          ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      l10n?.homeHeroSubtitle ??
                          'A home that fits your life is just a search away.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.76),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Material(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: onSearchTap,
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: colors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  l10n?.homeSearchHint ??
                                      'Search address, city, or property...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 18,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
