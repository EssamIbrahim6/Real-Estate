import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';
import 'package:real_estate_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:real_estate_app/features/search/domain/entities/search_filter.dart';

void main() {
  group('SearchRepositoryImpl', () {
    test('default filters leave all optional criteria unset', () {
      const filter = SearchFilter();

      expect(filter.query, isNull);
      expect(filter.categoryId, isNull);
      expect(filter.city, isNull);
      expect(filter.minPrice, isNull);
      expect(filter.maxPrice, isNull);
      expect(filter.bedrooms, isNull);
      expect(filter.bathrooms, isNull);
      expect(filter.isFurnished, isNull);
      expect(filter.listingType, isNull);
      expect(filter.isAvailable, isTrue);
    });

    test('clearing filters preserves query and default availability', () {
      const filter = SearchFilter(
        query: 'cairo',
        categoryId: 'apartment-id',
        city: 'Cairo',
        minPrice: 1000,
        maxPrice: 20000,
        bedrooms: 3,
        bathrooms: 2,
        isFurnished: true,
        listingType: 'rent',
      );

      final cleared = filter.clearFilters();

      expect(cleared.query, 'cairo');
      expect(cleared.categoryId, isNull);
      expect(cleared.city, isNull);
      expect(cleared.minPrice, isNull);
      expect(cleared.maxPrice, isNull);
      expect(cleared.bedrooms, isNull);
      expect(cleared.bathrooms, isNull);
      expect(cleared.isFurnished, isNull);
      expect(cleared.listingType, isNull);
      expect(cleared.isAvailable, isTrue);
    });

    test('forwards filters and matches normalized searchable text', () async {
      final estateRepository = _FakeEstateRepository([_estate()]);
      final repository = SearchRepositoryImpl(estateRepository);

      final result = await repository.search(
        const SearchFilter(
          query: '  CAFÉ   Cairo ',
          categoryId: 'apartment-id',
          city: 'Cairo',
          minPrice: 1000,
          maxPrice: 5000,
          bedrooms: 2,
          bathrooms: 1,
          isFurnished: true,
          listingType: 'rent',
          isAvailable: true,
        ),
      );

      expect(result.failure, isNull);
      expect(result.data, hasLength(1));
      expect(estateRepository.categoryId, 'apartment-id');
      expect(estateRepository.city, 'Cairo');
      expect(estateRepository.minPrice, 1000);
      expect(estateRepository.maxPrice, 5000);
      expect(estateRepository.bedrooms, 2);
      expect(estateRepository.bathrooms, 1);
      expect(estateRepository.isFurnished, isTrue);
      expect(estateRepository.listingType, 'rent');
      expect(estateRepository.isAvailable, isTrue);
    });

    test('returns no matches when a query term is absent', () async {
      final repository = SearchRepositoryImpl(
        _FakeEstateRepository([_estate()]),
      );

      final result = await repository.search(
        const SearchFilter(query: 'apartment absent-term'),
      );

      expect(result.failure, isNull);
      expect(result.data, isEmpty);
    });

    test('matches Arabic query text without language selection', () async {
      final repository = SearchRepositoryImpl(
        _FakeEstateRepository([_estate()]),
      );

      final result = await repository.search(const SearchFilter(query: 'شقة'));

      expect(result.failure, isNull);
      expect(result.data, hasLength(1));
    });
  });
}

EstateEntity _estate() => const EstateEntity(
  id: 'estate-id',
  title: 'Café apartment',
  description: 'Quiet شقة for rent',
  price: 2500,
  listingType: 'rent',
  categoryId: 'apartment-id',
  agentId: 'agent-id',
  location: EstateLocationEntity(
    address: '12 Main Street',
    city: 'Cairo',
    latitude: 30.0,
    longitude: 31.0,
  ),
  coverImage: '',
  images: [],
  bedrooms: 2,
  bathrooms: 1,
  area: 100,
  isFurnished: true,
  amenities: [],
  rating: 0,
  reviewCount: 0,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);

class _FakeEstateRepository implements EstateRepository {
  final List<EstateEntity> estates;

  String? categoryId;
  String? city;
  double? minPrice;
  double? maxPrice;
  int? bedrooms;
  int? bathrooms;
  bool? isFurnished;
  String? listingType;
  bool? isAvailable;

  _FakeEstateRepository(this.estates);

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
    this.categoryId = categoryId;
    this.city = city;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.bedrooms = bedrooms;
    this.bathrooms = bathrooms;
    this.isFurnished = isFurnished;
    this.listingType = listingType;
    this.isAvailable = isAvailable;
    return (failure: null, data: estates);
  }

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: estates);

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async =>
      (failure: null, data: estates.first);
}
