import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/category/domain/entities/category_entity.dart';
import 'package:real_estate_app/features/category/domain/repositories/category_repository.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/search/domain/entities/search_filter.dart';
import 'package:real_estate_app/features/search/domain/repositories/search_repository.dart';
import 'package:real_estate_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:real_estate_app/features/search/presentation/pages/search_screen.dart';

void main() {
  testWidgets('search waits for submit and accepts English and Arabic text', (
    tester,
  ) async {
    final searchRepository = _FakeSearchRepository();
    final cubit = SearchCubit(
      searchRepository: searchRepository,
      categoryRepository: _FakeCategoryRepository(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(searchRepository.filters, hasLength(1));
    final searchField = find.byType(TextField);

    await tester.enterText(searchField, 'cairo');
    await tester.pump();
    expect(searchRepository.filters, hasLength(1));
    expect(find.text('Arabic or English?'), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(searchRepository.filters.last.query, 'cairo');

    await tester.enterText(searchField, 'القاهرة');
    await tester.pump();
    expect(searchRepository.filters, hasLength(2));

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(searchRepository.filters.last.query, 'القاهرة');
  });
}

class _FakeSearchRepository implements SearchRepository {
  final List<SearchFilter> filters = [];

  @override
  ResultFuture<List<EstateEntity>> search(SearchFilter filter) async {
    filters.add(filter);
    return (failure: null, data: const <EstateEntity>[]);
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
