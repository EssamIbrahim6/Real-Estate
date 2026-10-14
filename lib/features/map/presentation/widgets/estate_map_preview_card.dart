import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 104,
                    height: 104,
                    child: estate.coverImage.isNotEmpty
                        ? Image.network(
                            estate.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.inputBackground,
                                  child: const Icon(
                                    Icons.home_outlined,
                                    color: AppColors.textMuted,
                                    size: 36,
                                  ),
                                ),
                          )
                        : Container(
                            color: AppColors.inputBackground,
                            child: const Icon(
                              Icons.home_outlined,
                              color: AppColors.textMuted,
                              size: 36,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Row: Listing type badge + close button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandNavy.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              estate.listingType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandNavy,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Semantics(
                            label: 'Close preview',
                            button: true,
                            child: InkWell(
                              onTap: onClose,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.inputBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Title
                      Text(
                        estate.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandNavy,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${estate.location.address}, ${estate.location.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Price & Beds/Baths row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'EGP ${estate.price.toInt()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brandGreen,
                                ),
                              ),
                              if (estate.pricePeriod != null) ...[
                                const SizedBox(width: 2),
                                Text(
                                  '/${estate.pricePeriod}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Beds / Baths info
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (estate.bedrooms > 0) ...[
                                const Icon(
                                  Icons.bed_outlined,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${estate.bedrooms}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (estate.bathrooms > 0) ...[
                                const Icon(
                                  Icons.bathtub_outlined,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${estate.bathrooms}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
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
    );
  }
}
