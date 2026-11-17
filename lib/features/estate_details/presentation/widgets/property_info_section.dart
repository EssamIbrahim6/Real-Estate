import 'package:flutter/material.dart';

import '../../../../features/estate/domain/entities/estate_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PropertyInfoSection extends StatelessWidget {
  final EstateEntity estate;

  const PropertyInfoSection({super.key, required this.estate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = [
      _PropertyStat(
        icon: Icons.bed_outlined,
        title: l10n?.detailsBedroomsLabel ?? 'Bedrooms',
        value: '${estate.bedrooms}',
      ),
      _PropertyStat(
        icon: Icons.bathtub_outlined,
        title: l10n?.detailsBathroomsLabel ?? 'Bathrooms',
        value: '${estate.bathrooms}',
      ),
      _PropertyStat(
        icon: Icons.square_foot_outlined,
        title: l10n?.detailsAreaLabel ?? 'Area',
        value:
            l10n?.detailsArea(estate.area.toInt().toString()) ??
            '${estate.area.toInt()} sqm',
      ),
      _PropertyStat(
        icon: Icons.chair_outlined,
        title: l10n?.detailsInteriorLabel ?? 'Interior',
        value: estate.isFurnished
            ? (l10n?.detailsFurnished ?? 'Furnished')
            : (l10n?.detailsUnfurnished ?? 'Unfurnished'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 700 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 2 ? 1.4 : 1.5,
          ),
          itemBuilder: (context, index) =>
              _buildStatCard(context, stats[index]),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, _PropertyStat stat) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stat.icon, size: 21, color: colors.onTertiaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  stat.title,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyStat {
  final IconData icon;
  final String title;
  final String value;

  const _PropertyStat({
    required this.icon,
    required this.title,
    required this.value,
  });
}
