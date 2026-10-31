import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/notification_service.dart';
import '../../../account_setup/domain/repositories/account_setup_repository.dart';
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
  final NotificationService? _notificationService;
  final AccountSetupRepository? _accountSetupRepository;

  HomeCubit({
    required EstateRepository estateRepository,
    required AgentRepository agentRepository,
    required CategoryRepository categoryRepository,
    NotificationService? notificationService,
    AccountSetupRepository? accountSetupRepository,
  }) : _estateRepository = estateRepository,
       _agentRepository = agentRepository,
       _categoryRepository = categoryRepository,
       _notificationService = notificationService,
       _accountSetupRepository = accountSetupRepository,
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

    // 6. Check personalized property matches for logged-in user without expensive scans
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null &&
        _notificationService != null &&
        _accountSetupRepository != null) {
      try {
        final profileResult =
            await _accountSetupRepository.getProfile(currentUid);
        final profile = profileResult.data;
        if (profile != null && profile.preferredRealEstateTypes.isNotEmpty) {
          final prefNames =
              profile.preferredRealEstateTypes.map((t) => t.name).toList();
          await _notificationService.checkPersonalizedPropertyMatches(
            uid: currentUid,
            preferredCategories: prefNames,
            candidateEstates: allEstates,
          );
        }
      } catch (_) {
        // Fire-and-forget personalization check
      }
    }

    emit(
      state.copyWith(
        status: HomeStatus.success,
        featuredEstates: featuredEstates,
        categories: categories,
        topLocations: topLocations,
        topAgents: topAgents,
        nearbyEstates: locationData.nearbyEstates,
        isLocationPermissionGranted: locationData.isLocationEnabled,
        currentLocationName: locationData.currentLocationName,
        featuredError: featuredError,
        agentsError: agentsError,
      ),
    );
  }

  /// Requests location permission from the system and updates the home state
  /// accordingly. Does not reload the full home feed; callers can refresh
  /// nearby estates by invoking [loadHome] again if needed.
  Future<void> requestLocationPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      emit(state.copyWith(isLocationPermissionGranted: granted));
    } catch (_) {
      emit(state.copyWith(isLocationPermissionGranted: false));
    }
  }

  List<LocationSummary> _deriveTopLocations(List<EstateEntity> estates) {
    if (estates.isEmpty) return const [];

    final cityMap = <String, ({int count, String? image})>{};

    for (final estate in estates) {
      final city = estate.location.city.trim();
      if (city.isEmpty) continue;

      final existing = cityMap[city];
      final newCount = (existing?.count ?? 0) + 1;
      final image = existing?.image ?? estate.coverImage;

      cityMap[city] = (count: newCount, image: image);
    }

    final sortedCities = cityMap.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));

    return sortedCities
        .take(5)
        .map(
          (entry) => LocationSummary(
            city: entry.key,
            estateCount: entry.value.count,
            representativeImageUrl: entry.value.image,
          ),
        )
        .toList();
  }

  Future<
    ({
      List<EstateEntity> nearbyEstates,
      bool isLocationEnabled,
      String? currentLocationName,
    })
  >
  _resolveUserLocationAndDistances(List<EstateEntity> allEstates) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (
          nearbyEstates: allEstates.take(5).toList(),
          isLocationEnabled: false,
          currentLocationName: null,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (
            nearbyEstates: allEstates.take(5).toList(),
            isLocationEnabled: false,
            currentLocationName: null,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return (
          nearbyEstates: allEstates.take(5).toList(),
          isLocationEnabled: false,
          currentLocationName: null,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      String? cityName;
      try {
        final geocoding = Geocoding();
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          cityName =
              placemarks.first.locality ??
              placemarks.first.administrativeArea ??
              placemarks.first.country;
        }
      } catch (_) {
        cityName = null;
      }

      final scoredEstates = allEstates.map((estate) {
        final distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          estate.location.latitude,
          estate.location.longitude,
        );
        return (estate: estate, distance: distanceInMeters);
      }).toList();

      scoredEstates.sort((a, b) => a.distance.compareTo(b.distance));

      final sortedNearby = scoredEstates
          .map((item) => item.estate)
          .take(5)
          .toList();

      return (
        nearbyEstates: sortedNearby,
        isLocationEnabled: true,
        currentLocationName: cityName,
      );
    } catch (_) {
      return (
        nearbyEstates: allEstates.take(5).toList(),
        isLocationEnabled: false,
        currentLocationName: null,
      );
    }
  }
}
