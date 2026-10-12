import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.inputBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: .min,
          children: [
            // Cover Image
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: estate.coverImage.isNotEmpty
                      ? Image.network(
                          estate.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
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
                if (estate.isFeatured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (estate.rating > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
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
              ],
            ),

            // Estate Details
            Padding(
              // padding: const EdgeInsets.all(AppDimensions.p12),
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: AppDimensions.p12,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: .min,
                children: [
                  Text(
                    estate.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpace(4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          distanceKm != null
                              ? '${distanceKm!.toStringAsFixed(1)} km • ${estate.location.city}'
                              : estate.location.city.isNotEmpty
                              ? estate.location.city
                              : estate.location.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(8),
                  Row(
                    children: [
                      if (estate.bedrooms > 0) ...[
                        const Icon(
                          Icons.bed_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${estate.bedrooms}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        horizontalSpace(8),
                      ],
                      if (estate.bathrooms > 0) ...[
                        const Icon(
                          Icons.bathtub_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${estate.bathrooms}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        horizontalSpace(8),
                      ],
                      if (estate.area > 0) ...[
                        const Icon(
                          Icons.square_foot_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${estate.area.toInt()} m²',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  verticalSpace(8),
                  Text(
                    'EGP ${estate.price.toInt()} ${estate.pricePeriod != null ? '/ ${estate.pricePeriod}' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandGreen,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
