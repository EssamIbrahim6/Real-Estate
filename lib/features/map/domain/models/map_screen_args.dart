import 'package:equatable/equatable.dart';

import '../../../estate/domain/entities/estate_entity.dart';

/// Navigation arguments passed when opening the Map screen.
class MapScreenArgs extends Equatable {
  /// Pre-filtered or pre-loaded list of estates to display.
  /// If null or empty, the map screen will load estates from the repository.
  final List<EstateEntity>? estates;

  /// Optional estate to automatically focus on and select upon opening the map.
  final EstateEntity? targetEstate;

  /// Custom title displayed in the map's AppBar.
  final String? title;

  const MapScreenArgs({this.estates, this.targetEstate, this.title});

  @override
  List<Object?> get props => [estates, targetEstate, title];
}
