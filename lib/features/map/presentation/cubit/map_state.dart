import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../../estate/domain/entities/estate_entity.dart';

enum MapStatus { initial, loading, success, empty, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<EstateEntity> allEstates;
  final List<EstateEntity> validEstates;
  final EstateEntity? selectedEstate;
  final EstateEntity? targetEstate;
  final String title;
  final String? errorMessage;
  final LatLng? userLocation;
  final bool isLocatingUser;

  const MapState({
    this.status = MapStatus.initial,
    this.allEstates = const [],
    this.validEstates = const [],
    this.selectedEstate,
    this.targetEstate,
    this.title = 'Explore on Map',
    this.errorMessage,
    this.userLocation,
    this.isLocatingUser = false,
  });

  MapState copyWith({
    MapStatus? status,
    List<EstateEntity>? allEstates,
    List<EstateEntity>? validEstates,
    EstateEntity? Function()? selectedEstate,
    EstateEntity? Function()? targetEstate,
    String? title,
    String? Function()? errorMessage,
    LatLng? Function()? userLocation,
    bool? isLocatingUser,
  }) {
    return MapState(
      status: status ?? this.status,
      allEstates: allEstates ?? this.allEstates,
      validEstates: validEstates ?? this.validEstates,
      selectedEstate: selectedEstate != null
          ? selectedEstate()
          : this.selectedEstate,
      targetEstate: targetEstate != null ? targetEstate() : this.targetEstate,
      title: title ?? this.title,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      userLocation: userLocation != null ? userLocation() : this.userLocation,
      isLocatingUser: isLocatingUser ?? this.isLocatingUser,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allEstates,
    validEstates,
    selectedEstate,
    targetEstate,
    title,
    errorMessage,
    userLocation,
    isLocatingUser,
  ];
}
