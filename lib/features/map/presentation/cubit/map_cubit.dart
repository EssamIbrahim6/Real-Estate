import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../estate/domain/entities/estate_entity.dart';
import '../../../estate/domain/repositories/estate_repository.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final EstateRepository estateRepository;

  MapCubit({required this.estateRepository}) : super(const MapState());

  /// Checks whether latitude and longitude are valid geographical coordinates.
  static bool isValidCoordinate(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return false;
    return lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0;
  }

  /// Filters a list of estates to only those with valid geographical coordinates.
  List<EstateEntity> _filterValidEstates(List<EstateEntity> estates) {
    return estates
        .where(
          (e) => isValidCoordinate(e.location.latitude, e.location.longitude),
        )
        .toList();
  }

  /// Initializes map data from optional provided estates or repository fetch.
  Future<void> init({
    List<EstateEntity>? initialEstates,
    EstateEntity? targetEstate,
    String? title,
  }) async {
    final customTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : (targetEstate != null ? targetEstate.title : 'Explore on Map');

    emit(
      state.copyWith(
        status: MapStatus.loading,
        title: customTitle,
        targetEstate: () => targetEstate,
        selectedEstate: () => targetEstate,
        errorMessage: () => null,
      ),
    );

    if (initialEstates != null && initialEstates.isNotEmpty) {
      var valid = _filterValidEstates(initialEstates);

      if (targetEstate != null &&
          isValidCoordinate(
            targetEstate.location.latitude,
            targetEstate.location.longitude,
          )) {
        if (!valid.any((e) => e.id == targetEstate.id)) {
          valid = [targetEstate, ...valid];
        }
      }

      if (valid.isEmpty) {
        emit(
          state.copyWith(
            status: MapStatus.empty,
            allEstates: initialEstates,
            validEstates: [],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MapStatus.success,
            allEstates: initialEstates,
            validEstates: valid,
          ),
        );
      }
      return;
    }

    await fetchEstates();
  }

  /// Fetches estates from the repository.
  Future<void> fetchEstates() async {
    emit(state.copyWith(status: MapStatus.loading, errorMessage: () => null));

    final result = await estateRepository.getEstates(limit: 100);

    if (result.failure != null) {
      emit(
        state.copyWith(
          status: MapStatus.error,
          errorMessage: () =>
              result.failure?.message ??
              'Failed to load properties on the map.',
        ),
      );
      return;
    }

    final fetched = result.data ?? [];
    var valid = _filterValidEstates(fetched);

    if (state.targetEstate != null &&
        isValidCoordinate(
          state.targetEstate!.location.latitude,
          state.targetEstate!.location.longitude,
        )) {
      if (!valid.any((e) => e.id == state.targetEstate!.id)) {
        valid = [state.targetEstate!, ...valid];
      }
    }

    if (valid.isEmpty) {
      emit(
        state.copyWith(
          status: MapStatus.empty,
          allEstates: fetched,
          validEstates: [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: MapStatus.success,
          allEstates: fetched,
          validEstates: valid,
        ),
      );
    }
  }

  /// Selects an estate to preview on the map.
  void selectEstate(EstateEntity? estate) {
    emit(state.copyWith(selectedEstate: () => estate));
  }

  /// Dismisses the selected estate preview.
  void clearSelection() {
    emit(state.copyWith(selectedEstate: () => null));
  }

  /// Updates user GPS location.
  void setUserLocation(LatLng? location) {
    emit(state.copyWith(userLocation: () => location, isLocatingUser: false));
  }

  /// Sets whether GPS position lookup is currently active.
  void setLocatingUser(bool isLocating) {
    emit(state.copyWith(isLocatingUser: isLocating));
  }
}
