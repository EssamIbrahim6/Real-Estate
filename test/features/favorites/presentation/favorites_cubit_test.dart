import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';
import 'package:real_estate_app/features/estate_details/domain/entities/review_entity.dart';
import 'package:real_estate_app/features/estate_details/domain/repositories/estate_details_repository.dart';
import 'package:real_estate_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:real_estate_app/features/favorites/presentation/cubit/favorites_state.dart';

void main() {
  test('loads saved estates from the live favorite-ID stream', () async {
    final favorites = StreamController<List<String>>();
    final estateRepository = _FakeEstateRepository({
      'estate-1': _estate('estate-1'),
      'estate-2': _estate('estate-2'),
    });
    final cubit = _createCubit(
      favorites: favorites.stream,
      estateRepository: estateRepository,
    );
    await cubit.loadFavorites();

    expect(cubit.state.status, FavoritesStatus.loading);
    favorites.add(['estate-1', 'estate-2']);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, FavoritesStatus.success);
    expect(cubit.state.estates.map((estate) => estate.id), [
      'estate-1',
      'estate-2',
    ]);
    await cubit.close();
    await favorites.close();
  });

  test(
    'shows empty state only after Firestore confirms no favorite IDs',
    () async {
      final cubit = _createCubit(favorites: Stream.value(const <String>[]));
      await cubit.loadFavorites();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, FavoritesStatus.success);
      expect(cubit.state.estates, isEmpty);
      expect(cubit.state.unavailableCount, 0);
      await cubit.close();
    },
  );

  test(
    'marks deleted or unavailable estate documents without crashing',
    () async {
      final favorites = StreamController<List<String>>();
      final cubit = _createCubit(
        favorites: favorites.stream,
        estateRepository: _FakeEstateRepository({
          'estate-1': _estate('estate-1'),
          'unavailable-estate': _estate(
            'unavailable-estate',
            isAvailable: false,
          ),
        }),
      );
      await cubit.loadFavorites();
      favorites.add(['estate-1', 'unavailable-estate', 'deleted-estate']);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, FavoritesStatus.success);
      expect(cubit.state.estates.map((estate) => estate.id), ['estate-1']);
      expect(cubit.state.unavailableCount, 2);
      await cubit.close();
      await favorites.close();
    },
  );

  test('surfaces favorite-stream failures as an error state', () async {
    final favorites = StreamController<List<String>>();
    final cubit = _createCubit(favorites: favorites.stream);
    await cubit.loadFavorites();
    favorites.addError(StateError('Firestore unavailable'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, FavoritesStatus.error);
    expect(cubit.state.error, contains('could not be loaded'));
    await cubit.close();
    await favorites.close();
  });

  test(
    'requires sign-in without starting a Firestore favorites stream',
    () async {
      final repository = _FakeEstateDetailsRepository();
      final cubit = _createCubit(
        auth: _FakeFirebaseAuth(null),
        repository: repository,
      );
      await cubit.loadFavorites();

      expect(cubit.state.status, FavoritesStatus.error);
      expect(cubit.state.error, contains('Sign in'));
      expect(repository.watchUserId, isNull);
      await cubit.close();
    },
  );
}

FavoritesCubit _createCubit({
  FirebaseAuth? auth,
  Stream<List<String>>? favorites,
  _FakeEstateDetailsRepository? repository,
  _FakeEstateRepository? estateRepository,
}) => FavoritesCubit(
  firebaseAuth: auth ?? _FakeFirebaseAuth(_FakeUser('user-123')),
  estateDetailsRepository:
      repository ?? _FakeEstateDetailsRepository(favorites: favorites),
  estateRepository: estateRepository ?? _FakeEstateRepository(const {}),
);

EstateEntity _estate(String id, {bool isAvailable = true}) => EstateEntity(
  id: id,
  title: 'Property $id',
  description: '',
  price: 150000,
  listingType: 'sale',
  categoryId: 'category',
  agentId: 'agent-id',
  location: const EstateLocationEntity(
    address: 'Address',
    city: 'Cairo',
    latitude: 30,
    longitude: 31,
  ),
  coverImage: '',
  images: const [],
  bedrooms: 2,
  bathrooms: 1,
  area: 100,
  isFurnished: false,
  amenities: const [],
  rating: 0,
  reviewCount: 0,
  isFeatured: false,
  isAvailable: isAvailable,
  status: 'active',
);

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth(this.currentUser);

  @override
  final User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEstateDetailsRepository implements EstateDetailsRepository {
  _FakeEstateDetailsRepository({this.favorites});

  final Stream<List<String>>? favorites;
  String? watchUserId;

  @override
  Stream<List<String>> watchFavoriteEstateIds(String userId) {
    watchUserId = userId;
    return favorites ?? Stream.value(const <String>[]);
  }

  @override
  ResultVoid addFavorite(String userId, String estateId) async =>
      (failure: null, isSuccess: true);

  @override
  ResultVoid removeFavorite(String userId, String estateId) async =>
      (failure: null, isSuccess: true);

  @override
  ResultFuture<List<ReviewEntity>> getReviews(
    String estateId, {
    int limit = 20,
  }) async => (failure: null, data: const <ReviewEntity>[]);

  @override
  ResultFuture<ReviewEntity?> getUserReview(
    String estateId,
    String userId,
  ) async => (failure: null, data: null);

  @override
  ResultVoid submitReview({
    required String estateId,
    required String userId,
    required String userName,
    String? userProfileImage,
    required int rating,
    required String comment,
    String? existingReviewId,
  }) async => (failure: null, isSuccess: true);
}

class _FakeEstateRepository implements EstateRepository {
  _FakeEstateRepository(this.estates);

  final Map<String, EstateEntity> estates;

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async =>
      (failure: null, data: estates[id]);

  @override
  ResultFuture<List<EstateEntity>> getEstates({
    String? categoryId,
    String? city,
    int? limit,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    bool? isFurnished,
    String? listingType,
    bool? isAvailable,
  }) async => (failure: null, data: estates.values.toList());

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: estates.values.toList());

  @override
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async =>
      (
        failure: null,
        data: estates.values
            .where((estate) => estate.agentId == agentId)
            .toList(),
      );

  @override
  ResultFuture<String> createEstate(EstateEntity estate) async =>
      (failure: null, data: estate.id);
}
