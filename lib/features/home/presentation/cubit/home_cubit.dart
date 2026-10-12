import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../agent/domain/repositories/agent_repository.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../../estate/domain/repositories/estate_repository.dart';
import '../../domain/entities/location_summary.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final EstateRepository _estateRepository;
  final AgentRepository _agentRepository;
  final CategoryRepository _categoryRepository;

  HomeCubit({
    required EstateRepository estateRepository,
    required AgentRepository agentRepository,
    required CategoryRepository categoryRepository,
  }) : _estateRepository = estateRepository,
       _agentRepository = agentRepository,
       _categoryRepository = categoryRepository,
       super(const HomeState());

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading));

    // 1. Fetch featured estates
    final featuredResult = await _estateRepository.getFeaturedEstates();
    final featuredEstates = featuredResult.data ?? const [];
    final featuredError = featuredResult.failure?.message;

    final categoriesResult = await _categoryRepository.getCategories();
    final categories = categoriesResult.data ?? const <CategoryEntity>[];

    // 2. Fetch all estates to derive top locations and nearby fallback
    final allEstatesResult = await _estateRepository.getEstates(limit: 50);
    final allEstates = allEstatesResult.data ?? const [];

    // 3. Derive top locations data-driven from real Firestore estates
    final topLocations = _deriveTopLocations(allEstates);

    // 4. Fetch top agents from Firestore
    final agentsResult = await _agentRepository.getTopAgents(limit: 10);
    final topAgents = agentsResult.data ?? const [];
    final agentsError = agentsResult.failure?.message;

    // 5. Check and resolve user location for nearby exploration
    final locationData = await _resolveUserLocationAndDistances(allEstates);

    emit(
      state.copyWith(
        status: HomeStatus.success,
        featuredEstates: featuredEstates,
        categories: categories,
        topLocations: topLocations,
        topAgents: topAgents,
        nearbyEstates: locationData.nearbyEstates,
        estateDistancesKm: locationData.distances,
        isLocationPermissionGranted: locationData.hasPermission,
        currentLocationName: locationData.cityName,
        featuredError: featuredError,
        categoriesError: categoriesResult.failure?.message,
        agentsError: agentsError,
        nearbyError: allEstatesResult.failure?.message,
      ),
    );
  }

  Future<void> requestLocationPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final allEstatesResult = await _estateRepository.getEstates(limit: 50);
        final allEstates = allEstatesResult.data ?? const [];
        final locationData = await _resolveUserLocationAndDistances(allEstates);

        emit(
          state.copyWith(
            nearbyEstates: locationData.nearbyEstates,
            estateDistancesKm: locationData.distances,
            isLocationPermissionGranted: locationData.hasPermission,
            currentLocationName: locationData.cityName,
          ),
        );
      }
    } catch (_) {}
  }

  List<LocationSummary> _deriveTopLocations(List<EstateEntity> estates) {
    final Map<String, List<EstateEntity>> byCity = {};
    for (final estate in estates) {
      final city = estate.location.city.trim();
      if (city.isNotEmpty) {
        byCity.putIfAbsent(city, () => []).add(estate);
      }
    }

    final locations = byCity.entries.map((entry) {
      final cover = entry.value
          .firstWhere(
            (e) => e.coverImage.isNotEmpty,
            orElse: () => entry.value.first,
          )
          .coverImage;

      return LocationSummary(
        city: entry.key,
        estateCount: entry.value.length,
        representativeImageUrl: cover.isNotEmpty ? cover : null,
      );
    }).toList();

    locations.sort((a, b) => b.estateCount.compareTo(a.estateCount));
    return locations;
  }

  Future<
    ({
      List<EstateEntity> nearbyEstates,
      Map<String, double> distances,
      bool hasPermission,
      String? cityName,
    })
  >
  _resolveUserLocationAndDistances(List<EstateEntity> estates) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (
          nearbyEstates: <EstateEntity>[],
          distances: <String, double>{},
          hasPermission: false,
          cityName: null,
        );
      }

      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return (
          nearbyEstates: <EstateEntity>[],
          distances: <String, double>{},
          hasPermission: false,
          cityName: null,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      String? city;
      try {
        //  final placemarks = await geocoding.placemarkFromCoordinates(
        //     lat,
        //     lng,
        //   );

        final geocoding = Geocoding();
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          city =
              placemarks.first.locality ?? placemarks.first.administrativeArea;
        }
      } catch (_) {}

      final Map<String, double> distanceMap = {};
      final List<EstateEntity> validEstates = [];

      for (final estate in estates) {
        if (estate.location.latitude != 0.0 &&
            estate.location.longitude != 0.0) {
          final meters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            estate.location.latitude,
            estate.location.longitude,
          );
          final km = meters / 1000.0;
          distanceMap[estate.id] = km;
          validEstates.add(estate);
        }
      }

      validEstates.sort(
        (a, b) =>
            (distanceMap[a.id] ?? 99999).compareTo(distanceMap[b.id] ?? 99999),
      );

      return (
        nearbyEstates: validEstates.take(10).toList(),
        distances: distanceMap,
        hasPermission: true,
        cityName: city,
      );
    } catch (_) {
      return (
        nearbyEstates: <EstateEntity>[],
        distances: <String, double>{},
        hasPermission: false,
        cityName: null,
      );
    }
  }
}
