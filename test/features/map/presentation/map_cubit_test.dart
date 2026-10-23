import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';
import 'package:real_estate_app/features/map/presentation/cubit/map_cubit.dart';
import 'package:real_estate_app/features/map/presentation/cubit/map_state.dart';

void main() {
  late _FakeEstateRepository repository;
  late MapCubit cubit;

  setUp(() {
    repository = _FakeEstateRepository();
    cubit = MapCubit(estateRepository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('MapCubit coordinate validation', () {
    test('isValidCoordinate returns false for (0.0, 0.0) or out-of-range coordinates', () {
      expect(MapCubit.isValidCoordinate(0.0, 0.0), isFalse);
      expect(MapCubit.isValidCoordinate(91.0, 31.0), isFalse);
      expect(MapCubit.isValidCoordinate(-91.0, 31.0), isFalse);
      expect(MapCubit.isValidCoordinate(30.0, 181.0), isFalse);
      expect(MapCubit.isValidCoordinate(30.0, -181.0), isFalse);
      expect(MapCubit.isValidCoordinate(30.0444, 31.2357), isTrue);
    });
  });

  group('MapCubit init', () {
    test('filters invalid coordinates and sets status to success', () async {
      final validEstate = _createEstate(id: '1', lat: 30.0444, lng: 31.2357);
      final invalidEstate = _createEstate(id: '2', lat: 0.0, lng: 0.0);

      await cubit.init(
        initialEstates: [validEstate, invalidEstate],
        title: 'Custom Map',
      );

      expect(cubit.state.status, MapStatus.success);
      expect(cubit.state.title, 'Custom Map');
      expect(cubit.state.allEstates.length, 2);
      expect(cubit.state.validEstates.length, 1);
      expect(cubit.state.validEstates.first.id, '1');
    });

    test('selects targetEstate and includes it in validEstates', () async {
      final target = _createEstate(
        id: 'target',
        lat: 29.987,
        lng: 31.345,
        title: 'Zamalek Villa',
      );
      final other = _createEstate(id: 'other', lat: 30.1, lng: 31.2);

      await cubit.init(initialEstates: [other], targetEstate: target);

      expect(cubit.state.status, MapStatus.success);
      expect(cubit.state.selectedEstate, target);
      expect(cubit.state.targetEstate, target);
      expect(cubit.state.validEstates.any((e) => e.id == 'target'), isTrue);
    });

    test(
      'emits empty state when all provided estates have invalid coordinates',
      () async {
        final invalid1 = _createEstate(id: '1', lat: 0.0, lng: 0.0);
        final invalid2 = _createEstate(id: '2', lat: 100.0, lng: 200.0);

        await cubit.init(initialEstates: [invalid1, invalid2]);

        expect(cubit.state.status, MapStatus.empty);
        expect(cubit.state.validEstates, isEmpty);
      },
    );

    test(
      'fetches from repository when initialEstates is null or empty',
      () async {
        repository.estatesResult = (
          failure: null,
          data: [
            _createEstate(id: 'repo1', lat: 30.0, lng: 31.0),
            _createEstate(id: 'repo2', lat: 0.0, lng: 0.0),
          ],
        );

        await cubit.init();

        expect(cubit.state.status, MapStatus.success);
        expect(cubit.state.validEstates.length, 1);
        expect(cubit.state.validEstates.first.id, 'repo1');
      },
    );
  });

  group('MapCubit fetchEstates', () {
    test('emits error state on repository failure', () async {
      repository.estatesResult = (
        failure: const ServerFailure(message: 'Database error'),
        data: null,
      );

      await cubit.fetchEstates();

      expect(cubit.state.status, MapStatus.error);
      expect(cubit.state.errorMessage, 'Database error');
    });

    test(
      'emits empty state when repository returns empty or invalid list',
      () async {
        repository.estatesResult = (
          failure: null,
          data: [_createEstate(id: '1', lat: 0.0, lng: 0.0)],
        );

        await cubit.fetchEstates();

        expect(cubit.state.status, MapStatus.empty);
        expect(cubit.state.validEstates, isEmpty);
      },
    );
  });

  group('MapCubit selection & location management', () {
    test('selectEstate and clearSelection update selectedEstate', () {
      final estate = _createEstate(id: 'e1', lat: 30.0, lng: 31.0);

      cubit.selectEstate(estate);
      expect(cubit.state.selectedEstate, estate);

      cubit.clearSelection();
      expect(cubit.state.selectedEstate, isNull);
    });

    test('setUserLocation updates user location and resets isLocatingUser', () {
      cubit.setLocatingUser(true);
      expect(cubit.state.isLocatingUser, isTrue);

      const loc = LatLng(30.05, 31.25);
      cubit.setUserLocation(loc);

      expect(cubit.state.userLocation, loc);
      expect(cubit.state.isLocatingUser, isFalse);
    });
  });
}

class _FakeEstateRepository implements EstateRepository {
  ({Failure? failure, List<EstateEntity>? data}) estatesResult = (
    failure: null,
    data: const <EstateEntity>[],
  );

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
  }) async {
    return estatesResult;
  }

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async => estatesResult;

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async =>
      (failure: null, data: null);

  @override
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async =>
      (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<String> createEstate(EstateEntity estate) async =>
      (failure: null, data: estate.id);
}

EstateEntity _createEstate({
  required String id,
  required double lat,
  required double lng,
  String title = 'Test Estate',
  double price = 2500000,
}) {
  return EstateEntity(
    id: id,
    title: title,
    description: 'Description',
    price: price,
    listingType: 'sale',
    categoryId: 'cat_1',
    agentId: 'agent_1',
    location: EstateLocationEntity(
      address: '123 Nile Street',
      city: 'Cairo',
      latitude: lat,
      longitude: lng,
    ),
    coverImage: 'https://example.com/cover.jpg',
    images: const ['https://example.com/cover.jpg'],
    bedrooms: 3,
    bathrooms: 2,
    area: 180,
    isFurnished: true,
    amenities: const ['Balcony', 'Parking'],
    rating: 4.8,
    reviewCount: 12,
    isFeatured: true,
    isAvailable: true,
    status: 'active',
  );
}
