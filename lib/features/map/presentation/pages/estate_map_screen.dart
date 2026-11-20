import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/map_screen_args.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/estate_map_app_bar.dart';
import '../widgets/estate_map_layer.dart';
import '../widgets/map_status_view.dart';

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
    final l10n = AppLocalizations.of(context);
    cubit.setLocatingUser(true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          AppFeedback.info(
            context,
            l10n?.mapServicesDisabled ??
                'Location services are disabled on this device.',
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
          AppFeedback.info(
            context,
            l10n?.mapPermissionRequired ??
                'Location permission is required to center on your position.',
          );
        }
        cubit.setLocatingUser(false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      cubit.setUserLocation(userLocation);
      if (_isMapReady) {
        _mapController.move(userLocation, 15.0);
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.error(
          context,
          l10n?.mapLocationFailure(error.toString()) ??
              'Could not determine location: $error',
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
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colors.surface,
          appBar: EstateMapAppBar(
            title: state.title,
            onBack: () => context.pop(),
            onRefresh: () => context.read<MapCubit>().fetchEstates(),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MapState state) {
    if (state.status == MapStatus.loading && state.validEstates.isEmpty) {
      return const MapStatusView.loading();
    }

    if (state.status == MapStatus.error && state.validEstates.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return MapStatusView.error(
        message:
            state.errorMessage ??
            l10n?.mapLoadError ??
            'Failed to load properties on the map.',
        onRetry: () => context.read<MapCubit>().init(
          initialEstates: widget.args?.estates,
          targetEstate: widget.args?.targetEstate,
          title: widget.args?.title,
        ),
      );
    }

    if (state.status == MapStatus.empty && state.validEstates.isEmpty) {
      return MapStatusView.empty(
        onLoadAll: () => context.read<MapCubit>().fetchEstates(),
      );
    }

    final validPoints = state.validEstates
        .map(
          (estate) =>
              LatLng(estate.location.latitude, estate.location.longitude),
        )
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

    final initialFit = state.targetEstate == null && validPoints.length > 1
        ? CameraFit.coordinates(
            coordinates: validPoints,
            padding: const EdgeInsets.all(60.0),
          )
        : null;

    return EstateMapLayer(
      mapController: _mapController,
      estates: state.validEstates,
      selectedEstate: state.selectedEstate,
      userLocation: state.userLocation,
      isLocating: state.isLocatingUser,
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
      onMapTap: () => context.read<MapCubit>().clearSelection(),
      onEstateTap: (estate) {
        context.read<MapCubit>().selectEstate(estate);
        final location = LatLng(
          estate.location.latitude,
          estate.location.longitude,
        );
        if (_isMapReady) {
          _mapController.move(
            location,
            _mapController.camera.zoom < 14.0
                ? 14.0
                : _mapController.camera.zoom,
          );
        }
      },
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
      onOpenEstate: (estate) {
        context.push(
          '${AppRoutes.propertyDetails}/${estate.id}',
          extra: estate,
        );
      },
      onClosePreview: () => context.read<MapCubit>().clearSelection(),
    );
  }
}
