import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

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

  Widget _buildButton(
    BuildContext context, {
    required Widget icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: tooltip,
      button: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: colors.shadow.withValues(alpha: 0.24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(width: 48, height: 48, child: Center(child: icon)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          context,
          icon: Icon(Icons.add, size: 20, color: iconColor),
          onTap: onZoomIn,
          tooltip: l10n?.mapZoomIn ?? 'Zoom in',
        ),
        const SizedBox(height: 8),
        _buildButton(
          context,
          icon: Icon(Icons.remove, size: 20, color: iconColor),
          onTap: onZoomOut,
          tooltip: l10n?.mapZoomOut ?? 'Zoom out',
        ),
        const SizedBox(height: 8),
        _buildButton(
          context,
          icon: Icon(
            Icons.filter_center_focus_rounded,
            size: 20,
            color: iconColor,
          ),
          onTap: onFitAll,
          tooltip: l10n?.mapFitAll ?? 'Fit all properties',
        ),
        const SizedBox(height: 8),
        _buildButton(
          context,
          icon: isLocating
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Icon(Icons.my_location_rounded, size: 20, color: iconColor),
          onTap: onMyLocation,
          tooltip: l10n?.mapMyLocation ?? 'My location',
        ),
      ],
    );
  }
}
