import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../features/estate/domain/entities/estate_entity.dart';

class EstateMapSection extends StatelessWidget {
  final EstateLocationEntity location;
  final VoidCallback? onTap;

  const EstateMapSection({super.key, required this.location, this.onTap});

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(
      location.latitude != 0.0
          ? location.latitude
          : 30.0444, // Default Cairo fallback
      location.longitude != 0.0 ? location.longitude : 31.2357,
    );

    final mapWidget = Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: latLng,
              initialZoom: 14.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag
                    .none, // Static preview to prevent scroll hijacking
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.real_estate_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: latLng,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.brandGreen,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (onTap != null)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandNavy.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'View Full Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: mapWidget,
      );
    }

    return mapWidget;
  }
}
