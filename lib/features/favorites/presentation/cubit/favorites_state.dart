import 'package:equatable/equatable.dart';

import '../../../estate/domain/entities/estate_entity.dart';

enum FavoritesStatus { initial, loading, success, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<EstateEntity> estates;
  final int unavailableCount;
  final String? error;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.estates = const [],
    this.unavailableCount = 0,
    this.error,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<EstateEntity>? estates,
    int? unavailableCount,
    String? error,
  }) => FavoritesState(
    status: status ?? this.status,
    estates: estates ?? this.estates,
    unavailableCount: unavailableCount ?? this.unavailableCount,
    error: error,
  );

  @override
  List<Object?> get props => [status, estates, unavailableCount, error];
}
