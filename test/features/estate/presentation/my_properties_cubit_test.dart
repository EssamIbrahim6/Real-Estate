import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';
import 'package:real_estate_app/features/estate/presentation/cubit/my_properties_cubit.dart';
import 'package:real_estate_app/features/estate/presentation/cubit/my_properties_state.dart';

void main() {
  group('MyPropertiesCubit', () {
    test('initializes with default initial state', () {
      final cubit = MyPropertiesCubit(
        estateRepository: _FakeEstateRepository(),
      );
      expect(cubit.state.status, MyPropertiesStatus.initial);
      expect(cubit.state.properties, isEmpty);
      expect(cubit.state.isDeleting, isFalse);
      expect(cubit.state.error, isNull);
    });

    test('ignores empty or whitespace ownerId on loadProperties', () async {
      final repo = _FakeEstateRepository();
      final cubit = MyPropertiesCubit(estateRepository: repo);

      await cubit.loadProperties('');
      await cubit.loadProperties('   ');

      expect(cubit.state.status, MyPropertiesStatus.initial);
      expect(repo.requestedOwnerId, isNull);
    });

    test('loads properties for owner successfully', () async {
      final property = _testEstate('prop-1', 'owner-123');
      final repo = _FakeEstateRepository(estates: [property]);
      final cubit = MyPropertiesCubit(estateRepository: repo);

      await cubit.loadProperties('owner-123');

      expect(cubit.state.status, MyPropertiesStatus.success);
      expect(cubit.state.properties, hasLength(1));
      expect(cubit.state.properties.first.id, 'prop-1');
      expect(repo.requestedOwnerId, 'owner-123');
    });

    test('emits error state when loading properties fails', () async {
      final repo = _FakeEstateRepository(
        failure: const ServerFailure(message: 'Database error'),
      );
      final cubit = MyPropertiesCubit(estateRepository: repo);

      await cubit.loadProperties('owner-123');

      expect(cubit.state.status, MyPropertiesStatus.error);
      expect(cubit.state.error, 'Database error');
      expect(cubit.state.properties, isEmpty);
    });

    test('deleteProperty removes property from list on success', () async {
      final prop1 = _testEstate('prop-1', 'owner-123');
      final prop2 = _testEstate('prop-2', 'owner-123');
      final repo = _FakeEstateRepository(estates: [prop1, prop2]);
      final cubit = MyPropertiesCubit(estateRepository: repo);

      await cubit.loadProperties('owner-123');
      expect(cubit.state.properties, hasLength(2));

      final success = await cubit.deleteProperty(
        estateId: 'prop-1',
        ownerId: 'owner-123',
      );

      expect(success, isTrue);
      expect(cubit.state.isDeleting, isFalse);
      expect(cubit.state.deletingPropertyId, isNull);
      expect(cubit.state.properties, hasLength(1));
      expect(cubit.state.properties.first.id, 'prop-2');
      expect(cubit.state.actionFeedback, isNotNull);
      expect(repo.deletedEstateId, 'prop-1');
      expect(repo.deletedOwnerId, 'owner-123');
    });

    test('deleteProperty returns false and sets error on failure', () async {
      final prop1 = _testEstate('prop-1', 'owner-123');
      final repo = _FakeEstateRepository(
        estates: [prop1],
        deleteFailure: const ServerFailure(message: 'Permission denied'),
      );
      final cubit = MyPropertiesCubit(estateRepository: repo);

      await cubit.loadProperties('owner-123');

      final success = await cubit.deleteProperty(
        estateId: 'prop-1',
        ownerId: 'owner-123',
      );

      expect(success, isFalse);
      expect(cubit.state.isDeleting, isFalse);
      expect(cubit.state.deletingPropertyId, isNull);
      expect(cubit.state.error, 'Permission denied');
      expect(cubit.state.properties, hasLength(1));
    });

    test('deleteProperty ignores empty parameters', () async {
      final repo = _FakeEstateRepository();
      final cubit = MyPropertiesCubit(estateRepository: repo);

      final r1 = await cubit.deleteProperty(estateId: '', ownerId: 'owner-1');
      final r2 = await cubit.deleteProperty(estateId: 'id', ownerId: '');

      expect(r1, isFalse);
      expect(r2, isFalse);
      expect(repo.deletedEstateId, isNull);
    });
  });
}

EstateEntity _testEstate(String id, String ownerId) => EstateEntity(
  id: id,
  title: 'Test Estate $id',
  description: 'Description',
  price: 2500000,
  listingType: 'sale',
  categoryId: 'apartment',
  agentId: 'agent-1',
  ownerId: ownerId,
  location: const EstateLocationEntity(
    address: '123 Test St',
    city: 'Cairo',
    latitude: 30.0444,
    longitude: 31.2357,
  ),
  coverImage: 'https://example.com/cover.jpg',
  images: const ['https://example.com/1.jpg'],
  bedrooms: 2,
  bathrooms: 1,
  area: 120,
  isFurnished: true,
  amenities: const ['WiFi'],
  rating: 4.5,
  reviewCount: 3,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);

class _FakeEstateRepository implements EstateRepository {
  _FakeEstateRepository({
    this.estates = const [],
    this.failure,
    this.deleteFailure,
  });

  final List<EstateEntity> estates;
  final Failure? failure;
  final Failure? deleteFailure;

  String? requestedOwnerId;
  String? deletedEstateId;
  String? deletedOwnerId;

  @override
  ResultFuture<List<EstateEntity>> getEstatesByOwnerId(String ownerId) async {
    requestedOwnerId = ownerId;
    if (failure != null) return (failure: failure, data: null);
    final filtered = estates.where((e) => e.ownerId == ownerId).toList();
    return (failure: null, data: filtered);
  }

  @override
  ResultVoid deleteEstate({
    required String estateId,
    required String currentUid,
  }) async {
    deletedEstateId = estateId;
    deletedOwnerId = currentUid;
    if (deleteFailure != null) {
      return (failure: deleteFailure, isSuccess: false);
    }
    return (failure: null, isSuccess: true);
  }

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async =>
      (failure: null, data: estates.first);

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
  }) async => (failure: null, data: estates);

  @override
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async =>
      (failure: null, data: estates);

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: estates);

  @override
  ResultFuture<String> createEstate(EstateEntity estate) async =>
      (failure: null, data: estate.id);
}
