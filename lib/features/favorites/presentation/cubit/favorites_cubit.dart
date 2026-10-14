import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../estate/domain/entities/estate_entity.dart';
import '../../../estate/domain/repositories/estate_repository.dart';
import '../../../estate_details/domain/repositories/estate_details_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FirebaseAuth _firebaseAuth;
  final EstateDetailsRepository _estateDetailsRepository;
  final EstateRepository _estateRepository;
  StreamSubscription<List<String>>? _favoritesSubscription;
  int _loadGeneration = 0;

  // ignore: prefer_initializing_formals
  FavoritesCubit({
    required FirebaseAuth firebaseAuth,
    required EstateDetailsRepository estateDetailsRepository,
    required EstateRepository estateRepository,
  }) : _firebaseAuth = firebaseAuth,
       _estateDetailsRepository = estateDetailsRepository,
       _estateRepository = estateRepository,
       super(const FavoritesState());

  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  Future<void> loadFavorites() async {
    final userId = _firebaseAuth.currentUser?.uid.trim();
    if (userId == null || userId.isEmpty) {
      await _favoritesSubscription?.cancel();
      _favoritesSubscription = null;
      _loadGeneration++;
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          estates: const [],
          unavailableCount: 0,
          error: 'Sign in to view your favorite properties.',
        ),
      );
      return;
    }

    await _favoritesSubscription?.cancel();
    _loadGeneration++;
    emit(
      state.copyWith(
        status: FavoritesStatus.loading,
        estates: const [],
        unavailableCount: 0,
        error: null,
      ),
    );

    try {
      _favoritesSubscription = _estateDetailsRepository
          .watchFavoriteEstateIds(userId)
          .listen(
            _loadFavoriteEstates,
            onError: (Object error) {
              emit(
                state.copyWith(
                  status: FavoritesStatus.error,
                  error: 'Favorites could not be loaded. Please try again.',
                ),
              );
            },
          );
    } catch (_) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          error: 'Favorites could not be loaded. Please try again.',
        ),
      );
    }
  }

  Future<void> _loadFavoriteEstates(List<String> estateIds) async {
    final generation = ++_loadGeneration;
    final uniqueIds = estateIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    emit(
      state.copyWith(
        status: FavoritesStatus.loading,
        estates: const [],
        unavailableCount: 0,
        error: null,
      ),
    );

    final estates = await Future.wait(
      uniqueIds.map((id) async {
        try {
          final result = await _estateRepository.getEstateById(id);
          return result.failure == null ? result.data : null;
        } catch (_) {
          return null;
        }
      }),
    );
    if (isClosed || generation != _loadGeneration) return;

    final availableEstates = estates.whereType<EstateEntity>().toList();
    final availableFavorites = availableEstates
        .where((estate) => estate.isAvailable)
        .toList(growable: false);

    emit(
      state.copyWith(
        status: FavoritesStatus.success,
        estates: availableFavorites,
        unavailableCount: uniqueIds.length - availableFavorites.length,
        error: null,
      ),
    );
  }

  @override
  Future<void> close() async {
    _loadGeneration++;
    await _favoritesSubscription?.cancel();
    return super.close();
  }
}
