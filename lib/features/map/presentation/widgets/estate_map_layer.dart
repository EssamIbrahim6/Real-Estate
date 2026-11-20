import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../estate/domain/entities/estate_entity.dart';
import 'estate_map_marker.dart';
import 'estate_map_preview_card.dart';
import 'map_controls_bar.dart';

class EstateMapLayer extends StatelessWidget {
  final MapController mapController;
  final List<EstateEntity> estates;
  final EstateEntity? selectedEstate;
  final LatLng? userLocation;
  final bool isLocating;
  final LatLng initialCenter;
  final double initialZoom;
  final CameraFit? initialCameraFit;
  final VoidCallback onMapReady;
  final VoidCallback onMapTap;
  final ValueChanged<EstateEntity> onEstateTap;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitAll;
  final VoidCallback onMyLocation;
  final ValueChanged<EstateEntity> onOpenEstate;
  final VoidCallback onClosePreview;

  const EstateMapLayer({
    super.key,
    required this.mapController,
    required this.estates,
    required this.selectedEstate,
    required this.userLocation,
    required this.isLocating,
    required this.initialCenter,
    required this.initialZoom,
    required this.initialCameraFit,
    required this.onMapReady,
    required this.onMapTap,
    required this.onEstateTap,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitAll,
    required this.onMyLocation,
    required this.onOpenEstate,
    required this.onClosePreview,
  });

  @override
  Widget build(BuildContext context) {
    final isPreviewOpen = selectedEstate != null;

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
            initialCameraFit: initialCameraFit,
            onMapReady: onMapReady,
            onTap: (tapPosition, point) => onMapTap(),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.real_estate_app',
            ),
            MarkerLayer(
              markers: [
                ...estates.map((estate) {
                  final isSelected = selectedEstate?.id == estate.id;
                  final location = LatLng(
                    estate.location.latitude,
                    estate.location.longitude,
                  );
                  return Marker(
                    point: location,
                    width: isSelected ? 120 : 108,
                    height: isSelected ? 56 : 50,
                    alignment: Alignment.topCenter,
                    child: EstateMapMarker(
                      estate: estate,
                      isSelected: isSelected,
                      onTap: () => onEstateTap(estate),
                    ),
                  );
                }),
                if (userLocation != null)
                  Marker(
                    point: userLocation!,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          top: isPreviewOpen ? 16 : null,
          bottom: isPreviewOpen ? null : 24,
          child: MapControlsBar(
            isLocating: isLocating,
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
            onFitAll: onFitAll,
            onMyLocation: onMyLocation,
          ),
        ),
        if (selectedEstate != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: EstateMapPreviewCard(
                estate: selectedEstate!,
                onTap: () => onOpenEstate(selectedEstate!),
                onClose: onClosePreview,
              ),
            ),
          ),
      ],
    );
  }
}
