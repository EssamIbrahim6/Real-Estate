import 'package:equatable/equatable.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../agent/domain/entities/agent_entity.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../domain/entities/location_summary.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<EstateEntity> featuredEstates;
  final List<LocationSummary> topLocations;
  final List<AgentEntity> topAgents;
  final List<EstateEntity> nearbyEstates;
  final List<CategoryEntity> categories;
  final Map<String, double> estateDistancesKm;
  final bool isLocationPermissionGranted;
  final String? currentLocationName;
  final String? featuredError;
  final String? categoriesError;
  final String? agentsError;
  final String? nearbyError;
  final String? generalError;

  const HomeState({
    this.status = HomeStatus.initial,
    this.featuredEstates = const [],
    this.topLocations = const [],
    this.topAgents = const [],
    this.nearbyEstates = const [],
    this.categories = const [],
    this.estateDistancesKm = const {},
    this.isLocationPermissionGranted = false,
    this.currentLocationName,
    this.featuredError,
    this.categoriesError,
    this.agentsError,
    this.nearbyError,
    this.generalError,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<EstateEntity>? featuredEstates,
    List<LocationSummary>? topLocations,
    List<AgentEntity>? topAgents,
    List<EstateEntity>? nearbyEstates,
    List<CategoryEntity>? categories,
    Map<String, double>? estateDistancesKm,
    bool? isLocationPermissionGranted,
    String? currentLocationName,
    String? featuredError,
    String? categoriesError,
    String? agentsError,
    String? nearbyError,
    String? generalError,
  }) {
    return HomeState(
      status: status ?? this.status,
      featuredEstates: featuredEstates ?? this.featuredEstates,
      topLocations: topLocations ?? this.topLocations,
      topAgents: topAgents ?? this.topAgents,
      nearbyEstates: nearbyEstates ?? this.nearbyEstates,
      categories: categories ?? this.categories,
      estateDistancesKm: estateDistancesKm ?? this.estateDistancesKm,
      isLocationPermissionGranted:
          isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      currentLocationName: currentLocationName ?? this.currentLocationName,
      featuredError: featuredError,
      categoriesError: categoriesError,
      agentsError: agentsError,
      nearbyError: nearbyError,
      generalError: generalError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    featuredEstates,
    topLocations,
    topAgents,
    nearbyEstates,
    categories,
    estateDistancesKm,
    isLocationPermissionGranted,
    currentLocationName,
    featuredError,
    categoriesError,
    agentsError,
    nearbyError,
    generalError,
  ];
}
