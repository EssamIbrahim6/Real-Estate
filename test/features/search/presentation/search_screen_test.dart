import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/theme/app_theme.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/category/domain/entities/category_entity.dart';
import 'package:real_estate_app/features/category/domain/repositories/category_repository.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/search/domain/entities/search_filter.dart';
import 'package:real_estate_app/features/search/domain/repositories/search_repository.dart';
import 'package:real_estate_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:real_estate_app/features/search/presentation/pages/search_screen.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('empty search stays initial and text search is debounced', (
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

    expect(searchRepository.filters, isEmpty);
    expect(find.text('Find your next home'), findsOneWidget);
    final searchField = find.byType(TextField);

    await tester.tap(searchField);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(searchRepository.filters, isEmpty);

    await tester.enterText(searchField, 'cairo');
    await tester.pump();
    expect(searchRepository.filters, isEmpty);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(searchRepository.filters, hasLength(1));
    expect(searchRepository.filters.last.query, 'cairo');
    expect(searchRepository.filters.last.city, isNull);

    await tester.enterText(searchField, 'القاهرة');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 349));
    expect(searchRepository.filters, hasLength(1));
    await tester.pump(const Duration(milliseconds: 1));
    expect(searchRepository.filters, hasLength(2));
    expect(searchRepository.filters.last.query, 'القاهرة');
    expect(find.text('No estates found'), findsOneWidget);
    expect(find.text('Find your next home'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(searchRepository.filters, hasLength(2));
    expect(find.text('Find your next home'), findsOneWidget);
  });

  testWidgets('AI search helper fits a compact Arabic dark layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = SearchCubit(
      searchRepository: _FakeSearchRepository(),
      categoryRepository: _FakeCategoryRepository(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('بحث مدعوم بالذكاء الاصطناعي'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
