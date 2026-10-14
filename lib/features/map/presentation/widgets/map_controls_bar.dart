import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Floating controls bar for the map: Zoom in, Zoom out, Fit all markers, and My Location.
class MapControlsBar extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitAll;
  final VoidCallback onMyLocation;
  final bool isLocating;

  const MapControlsBar({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitAll,
    required this.onMyLocation,
    this.isLocating = false,
  });

  Widget _buildButton({
    required Widget icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Semantics(
      label: tooltip,
      button: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 44, height: 44, child: Center(child: icon)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: const Icon(Icons.add, size: 20, color: AppColors.brandNavy),
          onTap: onZoomIn,
          tooltip: 'Zoom in',
        ),
        const SizedBox(height: 8),
        _buildButton(
          icon: const Icon(Icons.remove, size: 20, color: AppColors.brandNavy),
          onTap: onZoomOut,
          tooltip: 'Zoom out',
        ),
        const SizedBox(height: 8),
        _buildButton(
          icon: const Icon(
            Icons.filter_center_focus_rounded,
            size: 20,
            color: AppColors.brandNavy,
          ),
          onTap: onFitAll,
          tooltip: 'Fit all properties',
        ),
        const SizedBox(height: 8),
        _buildButton(
          icon: isLocating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandNavy,
                  ),
                )
              : const Icon(
                  Icons.my_location_rounded,
                  size: 20,
                  color: AppColors.brandNavy,
                ),
          onTap: onMyLocation,
          tooltip: 'My location',
        ),
      ],
    );
  }
}
