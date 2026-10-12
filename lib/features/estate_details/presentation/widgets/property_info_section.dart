import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../features/estate/domain/entities/estate_entity.dart';

class PropertyInfoSection extends StatelessWidget {
  final EstateEntity estate;

  const PropertyInfoSection({super.key, required this.estate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.bed_outlined,
          title: 'Bedrooms',
          value: '${estate.bedrooms}',
        ),
        const SizedBox(width: AppDimensions.p12),
        _buildStatCard(
          icon: Icons.bathtub_outlined,
          title: 'Bathrooms',
          value: '${estate.bathrooms}',
        ),
        const SizedBox(width: AppDimensions.p12),
        _buildStatCard(
          icon: Icons.square_foot_outlined,
          title: 'Total Area',
          value: '${estate.area.toInt()} m²',
        ),
        const SizedBox(width: AppDimensions.p12),
        _buildStatCard(
          icon: Icons.chair_outlined,
          title: 'Interior',
          value: estate.isFurnished ? 'Furnished' : 'Unfurnished',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.brandNavy),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.brandNavy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
