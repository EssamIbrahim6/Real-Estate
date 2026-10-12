import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../domain/models/map_screen_args.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/estate_map_marker.dart';
import '../widgets/estate_map_preview_card.dart';
import '../widgets/map_controls_bar.dart';

/// Fullscreen interactive map view displaying real-estate properties.
class EstateMapScreen extends StatefulWidget {
  final MapScreenArgs? args;

  const EstateMapScreen({super.key, this.args});

  @override
  State<EstateMapScreen> createState() => _EstateMapScreenState();
}

class _EstateMapScreenState extends State<EstateMapScreen> {
  late final MapController _mapController;
  bool _isMapReady = false;

  // Default Cairo coordinates as fallback
  static const LatLng _cairoFallback = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    context.read<MapCubit>().init(
      initialEstates: widget.args?.estates,
      targetEstate: widget.args?.targetEstate,
      title: widget.args?.title,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitAllEstates(List<LatLng> points) {
    if (!_isMapReady || points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 15.0);
    } else {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: points,
          padding: const EdgeInsets.all(60.0),
        ),
      );
    }
  }

  Future<void> _handleMyLocation() async {
    final cubit = context.read<MapCubit>();
    cubit.setLocatingUser(true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled on this device.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        cubit.setLocatingUser(false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission is required to center on your position.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
        cubit.setLocatingUser(false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      cubit.setUserLocation(userLatLng);
      if (_isMapReady) {
        _mapController.move(userLatLng, 15.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not determine location: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      cubit.setLocatingUser(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {
        if (_isMapReady &&
            state.targetEstate != null &&
            MapCubit.isValidCoordinate(
              state.targetEstate!.location.latitude,
              state.targetEstate!.location.longitude,
            )) {
          _mapController.move(
            LatLng(
              state.targetEstate!.location.latitude,
              state.targetEstate!.location.longitude,
            ),
            15.0,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(state.title),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.read<MapCubit>().fetchEstates(),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MapState state) {
    if (state.status == MapStatus.loading && state.validEstates.isEmpty) {
      return const AppLoadingIndicator(message: 'Loading properties on map...');
    }

    if (state.status == MapStatus.error && state.validEstates.isEmpty) {
      return AppErrorView(
        message: state.errorMessage ?? 'Failed to load properties on the map.',
        onRetry: () => context.read<MapCubit>().init(
          initialEstates: widget.args?.estates,
          targetEstate: widget.args?.targetEstate,
          title: widget.args?.title,
        ),
      );
    }

    if (state.status == MapStatus.empty && state.validEstates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_off_rounded,
                size: 56,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'No properties with valid coordinates found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The selected properties do not have geographic coordinates available to pin on the map.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => context.read<MapCubit>().fetchEstates(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Load All Properties'),
              ),
            ],
          ),
        ),
      );
    }

    final validPoints = state.validEstates
        .map((e) => LatLng(e.location.latitude, e.location.longitude))
        .toList();

    final LatLng initialCenter;
    if (state.targetEstate != null &&
        MapCubit.isValidCoordinate(
          state.targetEstate!.location.latitude,
          state.targetEstate!.location.longitude,
        )) {
      initialCenter = LatLng(
        state.targetEstate!.location.latitude,
        state.targetEstate!.location.longitude,
      );
    } else if (validPoints.isNotEmpty) {
      initialCenter = validPoints.first;
    } else {
      initialCenter = _cairoFallback;
    }

    final CameraFit? initialFit =
        (state.targetEstate == null && validPoints.length > 1)
        ? CameraFit.coordinates(
            coordinates: validPoints,
            padding: const EdgeInsets.all(60.0),
          )
        : null;

    final isPreviewOpen = state.selectedEstate != null;

    return Stack(
      children: [
        // Map widget
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: state.targetEstate != null ? 15.0 : 13.0,
            initialCameraFit: initialFit,
            onMapReady: () {
              _isMapReady = true;
              if (state.targetEstate != null &&
                  MapCubit.isValidCoordinate(
                    state.targetEstate!.location.latitude,
                    state.targetEstate!.location.longitude,
                  )) {
                _mapController.move(
                  LatLng(
                    state.targetEstate!.location.latitude,
                    state.targetEstate!.location.longitude,
                  ),
                  15.0,
                );
              }
            },
            onTap: (tapPosition, point) =>
                context.read<MapCubit>().clearSelection(),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.real_estate_app',
            ),
            MarkerLayer(
              markers: [
                // Estate markers
                ...state.validEstates.map((estate) {
                  final isSelected = state.selectedEstate?.id == estate.id;
                  final latLng = LatLng(
                    estate.location.latitude,
                    estate.location.longitude,
                  );
                  return Marker(
                    point: latLng,
                    width: isSelected ? 120 : 108,
                    height: isSelected ? 56 : 50,
                    alignment: Alignment.topCenter,
                    child: EstateMapMarker(
                      estate: estate,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<MapCubit>().selectEstate(estate);
                        if (_isMapReady) {
                          _mapController.move(
                            latLng,
                            _mapController.camera.zoom < 14.0
                                ? 14.0
                                : _mapController.camera.zoom,
                          );
                        }
                      },
                    ),
                  );
                }),

                // User Location marker if available
                if (state.userLocation != null)
                  Marker(
                    point: state.userLocation!,
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

        // Controls Bar (Zoom, Fit, My Location)
        Positioned(
          right: 16,
          bottom: isPreviewOpen ? 180 : 24,
          child: MapControlsBar(
            isLocating: state.isLocatingUser,
            onZoomIn: () {
              if (_isMapReady) {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                );
              }
            },
            onZoomOut: () {
              if (_isMapReady) {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                );
              }
            },
            onFitAll: () => _fitAllEstates(validPoints),
            onMyLocation: _handleMyLocation,
          ),
        ),

        // Preview Card at bottom
        if (state.selectedEstate != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: EstateMapPreviewCard(
                estate: state.selectedEstate!,
                onTap: () {
                  context.push(
                    '${AppRoutes.propertyDetails}/${state.selectedEstate!.id}',
                    extra: state.selectedEstate,
                  );
                },
                onClose: () => context.read<MapCubit>().clearSelection(),
              ),
            ),
          ),
      ],
    );
  }
}
