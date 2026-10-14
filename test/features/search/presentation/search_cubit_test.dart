import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/category/domain/entities/category_entity.dart';
import 'package:real_estate_app/features/category/domain/repositories/category_repository.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/search/domain/entities/search_filter.dart';
import 'package:real_estate_app/features/search/domain/repositories/search_repository.dart';
import 'package:real_estate_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:real_estate_app/features/search/presentation/cubit/search_state.dart';

void main() {
  test('ignores results from an older search that finishes last', () async {
    final repository = _ControlledSearchRepository();
    final cubit = SearchCubit(
      searchRepository: repository,
      categoryRepository: _FakeCategoryRepository(),
    );
    addTearDown(cubit.close);

    final oldSearch = cubit.search(const SearchFilter(query: 'older'));
    final newSearch = cubit.search(const SearchFilter(query: 'newer'));

    repository.results[1].complete((failure: null, data: [_estate('newer')]));
    await newSearch;
    repository.results[0].complete((failure: null, data: [_estate('older')]));
    await oldSearch;

    expect(cubit.state.status, SearchStatus.success);
    expect(cubit.state.filter.query, 'newer');
    expect(cubit.state.estates.single.id, 'newer');
  });
}

class _ControlledSearchRepository implements SearchRepository {
  final results = <Completer<({Failure? failure, List<EstateEntity>? data})>>[];

  @override
  ResultFuture<List<EstateEntity>> search(SearchFilter filter) {
    final result = Completer<({Failure? failure, List<EstateEntity>? data})>();
    results.add(result);
    return result.future;
  }
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  ResultFuture<List<CategoryEntity>> getCategories() async =>
      (failure: null, data: const <CategoryEntity>[]);

  @override
  ResultFuture<CategoryEntity> getCategoryById(String id) async =>
      (failure: null, data: null);
}

EstateEntity _estate(String id) => EstateEntity(
  id: id,
  title: id,
  description: '',
  price: 0,
  listingType: 'rent',
  categoryId: 'category',
  agentId: 'agent',
  location: const EstateLocationEntity(
    address: '',
    city: '',
    latitude: 0,
    longitude: 0,
  ),
  coverImage: '',
  images: const [],
  bedrooms: 0,
  bathrooms: 0,
  area: 0,
  isFurnished: false,
  amenities: const [],
  rating: 0,
  reviewCount: 0,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);
