import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:latlong2/latlong.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/property_location_selection.dart';

class PropertyLocationPickerScreen extends StatefulWidget {
  const PropertyLocationPickerScreen({
    super.key,
    this.initialSelection,
    this.resolveSelection,
  });

  final PropertyLocationSelection? initialSelection;
  final Future<PropertyLocationSelection> Function(LatLng point)?
  resolveSelection;

  @override
  State<PropertyLocationPickerScreen> createState() =>
      _PropertyLocationPickerScreenState();
}

class _PropertyLocationPickerScreenState
    extends State<PropertyLocationPickerScreen> {
  late final MapController _mapController;
  LatLng? _selectedPoint;
  bool _isResolving = false;
  bool _mapLoadError = false;
  int _mapRetryToken = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final initial = widget.initialSelection;
    if (initial?.isValid == true) {
      _selectedPoint = LatLng(initial!.latitude, initial.longitude);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _selectPoint(LatLng point) {
    setState(() => _selectedPoint = point);
    _mapController.move(point, _mapController.camera.zoom);
  }

  Future<void> _confirmSelection() async {
    final point = _selectedPoint;
    if (point == null ||
        !PropertyLocationSelection(
          latitude: point.latitude,
          longitude: point.longitude,
        ).isValid) {
      return;
    }

    setState(() => _isResolving = true);
    final selection = widget.resolveSelection == null
        ? await _resolveSelection(point)
        : await widget.resolveSelection!(point);

    if (!mounted) return;
    setState(() => _isResolving = false);
    Navigator.of(context).pop<PropertyLocationSelection>(selection);
  }

  Future<PropertyLocationSelection> _resolveSelection(LatLng point) async {
    try {
      final placemarks = await geocoding.Geocoding()
          .placemarkFromCoordinates(point.latitude, point.longitude)
          .timeout(const Duration(seconds: 5), onTimeout: () => const []);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final addressParts =
            [
                  placemark.name,
                  placemark.street,
                  placemark.subLocality,
                  placemark.locality,
                  placemark.administrativeArea,
                  placemark.country,
                ]
                .whereType<String>()
                .map((part) => part.trim())
                .where((part) => part.isNotEmpty)
                .toSet();
        final address = addressParts.join(', ');
        final city = placemark.locality?.trim();
        return PropertyLocationSelection(
          latitude: point.latitude,
          longitude: point.longitude,
          address: address.isEmpty ? null : address,
          city: city?.isEmpty == true ? null : city,
          addressLookupUnavailable: address.isEmpty,
        );
      }
    } catch (error) {
      debugPrint('Property location reverse geocoding failed: $error');
    }

    return PropertyLocationSelection(
      latitude: point.latitude,
      longitude: point.longitude,
      addressLookupUnavailable: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final selectedPoint = _selectedPoint;
    final canConfirm =
        selectedPoint != null &&
        PropertyLocationSelection(
          latitude: selectedPoint.latitude,
          longitude: selectedPoint.longitude,
        ).isValid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.propertyLocationPickerTitle ?? 'Select property location',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: selectedPoint ?? const LatLng(0, 0),
                    initialZoom: selectedPoint == null ? 2 : 15,
                    onTap: (_, point) => _selectPoint(point),
                  ),
                  children: [
                    TileLayer(
                      key: ValueKey<int>(_mapRetryToken),
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.real_estate_app',
                      errorTileCallback: (_, error, stackTrace) {
                        debugPrint('Property map tile failed to load: $error');
                        if (mounted && !_mapLoadError) {
                          setState(() => _mapLoadError = true);
                        }
                      },
                    ),
                    if (selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedPoint,
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.location_pin,
                              size: 44,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                PositionedDirectional(
                  top: 16,
                  start: 16,
                  end: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        l10n?.propertyLocationPickerHint ??
                            'Tap the map or move it and select its center.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                if (_mapLoadError)
                  PositionedDirectional(
                    top: 78,
                    start: 16,
                    end: 16,
                    child: Card(
                      color: colors.errorContainer,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 12,
                          end: 4,
                          top: 4,
                          bottom: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi_off_outlined,
                              color: colors.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n?.propertyMapLoadingError ?? 'Map tiles are unavailable. Check your connection or retry.',
                                style: TextStyle(
                                  color: colors.onErrorContainer,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n?.propertyMapRetry ?? 'Retry map',
                              onPressed: () => setState(() {
                                _mapLoadError = false;
                                _mapRetryToken++;
                              }),
                              icon: Icon(
                                Icons.refresh,
                                color: colors.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (selectedPoint == null)
                  PositionedDirectional(
                    bottom: 16,
                    start: 16,
                    end: 16,
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          _selectPoint(_mapController.camera.center),
                      icon: const Icon(Icons.my_location),
                      label: Text(
                        l10n?.propertyLocationSelectMapCenter ??
                            'Select map center',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (selectedPoint == null)
                    Text(
                      l10n?.myPropertiesLocationRequired ??
                          'Select a location before continuing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    )
                  else ...[
                    Text(
                      l10n?.propertyLocationSelectionReady ?? 'Location selected. Confirm to use it for this property.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const ValueKey('confirm-property-location'),
                    onPressed: !canConfirm || _isResolving
                        ? null
                        : _confirmSelection,
                    child: _isResolving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            l10n?.propertyLocationConfirm ?? 'Confirm location',
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
