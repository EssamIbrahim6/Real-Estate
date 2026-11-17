import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../estate/domain/entities/estate_entity.dart';

class EstateCard extends StatelessWidget {
  final EstateEntity estate;
  final double? distanceKm;
  final VoidCallback? onTap;
  final double width;

  const EstateCard({
    super.key,
    required this.estate,
    this.distanceKm,
    this.onTap,
    this.width = 240,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final displayTitle = estate.localizedTitle(langCode);
    final displayCity = estate.location.localizedCity(langCode);
    final displayAddress = estate.location.localizedAddress(langCode);
    final isAvailable = estate.isAvailable;
    final imageHeight = width.isFinite && width < 280 ? 160.0 : 190.0;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover Image
              Stack(
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: estate.coverImage.isNotEmpty
                        ? Image.network(
                            estate.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: colors.surfaceContainerHighest,
                              child: Icon(
                                Icons.home_outlined,
                                color: colors.onSurfaceVariant,
                                size: 36,
                              ),
                            ),
                          )
                        : Container(
                            color: colors.surfaceContainerHighest,
                            child: Icon(
                              Icons.home_outlined,
                              color: colors.onSurfaceVariant,
                              size: 36,
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.45, 1],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.62),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (estate.isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'FEATURED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.onTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  if (isAvailable && estate.rating > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              estate.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!isAvailable)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          l10n?.detailsEstateUnavailable ?? 'Unavailable',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.onError,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    start: 15,
                    bottom: 13,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${l10n?.commonEgp ?? "EGP"} ${estate.price.toInt()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (estate.pricePeriod != null && isAvailable) ...[
                          const SizedBox(width: 5),
                          Text(
                            '/ ${estate.pricePeriod}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Estate Details
              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: AppDimensions.p16,
                  vertical: 13,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    verticalSpace(4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            distanceKm != null
                                ? '${distanceKm!.toStringAsFixed(1)} km • $displayCity'
                                : displayCity.isNotEmpty
                                ? displayCity
                                : displayAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(10),
                    Row(
                      children: [
                        if (estate.bedrooms > 0) ...[
                          Icon(
                            Icons.bed_outlined,
                            size: 15,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${estate.bedrooms}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          horizontalSpace(8),
                        ],
                        if (estate.bathrooms > 0) ...[
                          Icon(
                            Icons.bathtub_outlined,
                            size: 15,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${estate.bathrooms}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          horizontalSpace(8),
                        ],
                        if (estate.area > 0) ...[
                          Icon(
                            Icons.square_foot_outlined,
                            size: 15,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${estate.area.toInt()} m²',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
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
    );
  }
}
