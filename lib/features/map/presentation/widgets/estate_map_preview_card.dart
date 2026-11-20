import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../estate/domain/entities/estate_entity.dart';

/// Floating preview card displayed at the bottom of the map when an estate marker is tapped.
class EstateMapPreviewCard extends StatelessWidget {
  final EstateEntity estate;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const EstateMapPreviewCard({
    super.key,
    required this.estate,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    final listingType = switch (estate.listingType.toLowerCase()) {
      'sale' => l10n?.searchForSale ?? 'For Sale',
      'rent' => l10n?.searchForRent ?? 'For Rent',
      _ => estate.listingType,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final imageSize = isCompact ? 76.0 : 96.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.all(isCompact ? 10 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: estate.coverImage.isNotEmpty
                                ? Image.network(
                                    estate.coverImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) => _buildImagePlaceholder(colors),
                                  )
                                : _buildImagePlaceholder(colors),
                          ),
                        ),
                        SizedBox(width: isCompact ? 10 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        listingType.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: colors.onSurfaceVariant,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Semantics(
                                    label:
                                        l10n?.mapClosePreview ??
                                        'Close preview',
                                    button: true,
                                    child: InkWell(
                                      onTap: onClose,
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 19,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                estate.localizedTitle(langCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      '${estate.location.localizedAddress(langCode)}, ${estate.location.localizedCity(langCode)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${l10n?.commonEgp ?? 'EGP'} ${estate.price.toInt()}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: colors.primary,
                                                ),
                                          ),
                                        ),
                                        if (estate.pricePeriod != null) ...[
                                          const SizedBox(width: 3),
                                          Text(
                                            '/${estate.pricePeriod}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (!isCompact) ...[
                                    if (estate.bedrooms > 0) ...[
                                      Icon(
                                        Icons.bed_outlined,
                                        size: 15,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${estate.bedrooms}',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (estate.bathrooms > 0) ...[
                                      Icon(
                                        Icons.bathtub_outlined,
                                        size: 14,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${estate.bathrooms}',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colors) {
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Icon(
        Icons.home_outlined,
        color: colors.onSurfaceVariant,
        size: 34,
      ),
    );
  }
}
