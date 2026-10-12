import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/category/domain/entities/category_entity.dart';
import 'package:real_estate_app/features/search/domain/entities/search_filter.dart';
import 'package:real_estate_app/features/search/presentation/widgets/search_filter_sheet.dart';

void main() {
  testWidgets('applying untouched filters leaves optional filters unset', (
    tester,
  ) async {
    SearchFilter? result;
    await _pumpFilterHarness(tester, onResult: (filter) => result = filter);

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    final textFields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    );
    expect(textFields, hasLength(5));
    expect(textFields.every((field) => field.controller!.text.isEmpty), isTrue);

    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.categoryId, isNull);
    expect(result!.city, isNull);
    expect(result!.minPrice, isNull);
    expect(result!.maxPrice, isNull);
    expect(result!.bedrooms, isNull);
    expect(result!.bathrooms, isNull);
    expect(result!.isFurnished, isNull);
    expect(result!.listingType, isNull);
    expect(result!.isAvailable, isTrue);
  });

  testWidgets('Clear Filters preserves query and clears selected filters', (
    tester,
  ) async {
    const initialFilter = SearchFilter(
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
    SearchFilter? result;
    await _pumpFilterHarness(
      tester,
      initialFilter: initialFilter,
      onResult: (filter) => result = filter,
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();

    expect(result?.query, 'cairo');
    expect(result?.categoryId, isNull);
    expect(result?.city, isNull);
    expect(result?.minPrice, isNull);
    expect(result?.maxPrice, isNull);
    expect(result?.bedrooms, isNull);
    expect(result?.bathrooms, isNull);
    expect(result?.isFurnished, isNull);
    expect(result?.listingType, isNull);
    expect(result?.isAvailable, isTrue);
  });
}

Future<void> _pumpFilterHarness(
  WidgetTester tester, {
  SearchFilter initialFilter = const SearchFilter(),
  required void Function(SearchFilter?) onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final filter = await showModalBottomSheet<SearchFilter>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SearchFilterSheet(
                  initialFilter: initialFilter,
                  categories: const [
                    CategoryEntity(id: 'apartment-id', name: 'Apartment'),
                  ],
                ),
              );
              onResult(filter);
            },
            child: const Text('Open filters'),
          ),
        ),
      ),
    ),
  );
}
