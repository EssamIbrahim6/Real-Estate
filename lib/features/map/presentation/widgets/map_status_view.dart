import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/generated/app_localizations.dart';

enum _MapStatusViewType { loading, error, empty }

class MapStatusView extends StatelessWidget {
  final _MapStatusViewType _type;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onLoadAll;

  const MapStatusView.loading({super.key})
    : _type = _MapStatusViewType.loading,
      message = null,
      onRetry = null,
      onLoadAll = null;

  const MapStatusView.error({
    super.key,
    required this.message,
    required this.onRetry,
  }) : _type = _MapStatusViewType.error,
       onLoadAll = null;

  const MapStatusView.empty({super.key, required this.onLoadAll})
    : _type = _MapStatusViewType.empty,
      message = null,
      onRetry = null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_type) {
      case _MapStatusViewType.loading:
        return AppLoadingIndicator(
          message: l10n?.mapLoading ?? 'Loading properties on map...',
        );
      case _MapStatusViewType.error:
        return AppErrorView(message: message!, onRetry: onRetry!);
      case _MapStatusViewType.empty:
        return _EmptyMapView(
          onLoadAll: onLoadAll!,
          title:
              l10n?.mapNoValidCoordsTitle ??
              'No properties with valid coordinates found.',
          description: l10n?.mapNoValidCoordsMessage ?? 'The selected properties do not have geographic coordinates available to pin on the map.',
          loadAllLabel: l10n?.mapLoadAllProperties ?? 'Load All Properties',
        );
    }
  }
}

class _EmptyMapView extends StatelessWidget {
  const _EmptyMapView({
    required this.onLoadAll,
    required this.title,
    required this.description,
    required this.loadAllLabel,
  });

  final VoidCallback onLoadAll;
  final String title;
  final String description;
  final String loadAllLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 56,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onLoadAll,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(loadAllLabel),
            ),
          ],
        ),
      ),
    );
  }
}
