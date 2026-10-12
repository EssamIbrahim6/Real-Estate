import 'package:equatable/equatable.dart';

import '../../../../features/estate/domain/entities/estate_entity.dart';

enum ListingStatus { initial, loading, success, error }

class ListingState extends Equatable {
  final ListingStatus status;
  final String title;
  final List<EstateEntity> estates;
  final Map<String, double> distancesKm;
  final String? error;

  const ListingState({
    this.status = ListingStatus.initial,
    this.title = 'Properties',
    this.estates = const [],
    this.distancesKm = const {},
    this.error,
  });

  ListingState copyWith({
    ListingStatus? status,
    String? title,
    List<EstateEntity>? estates,
    Map<String, double>? distancesKm,
    String? error,
  }) {
    return ListingState(
      status: status ?? this.status,
      title: title ?? this.title,
      estates: estates ?? this.estates,
      distancesKm: distancesKm ?? this.distancesKm,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, title, estates, distancesKm, error];
}
