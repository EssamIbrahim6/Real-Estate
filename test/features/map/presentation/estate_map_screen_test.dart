import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';
import 'package:real_estate_app/features/map/domain/models/map_screen_args.dart';
import 'package:real_estate_app/features/map/presentation/cubit/map_cubit.dart';
import 'package:real_estate_app/features/map/presentation/pages/estate_map_screen.dart';
import 'package:real_estate_app/features/map/presentation/widgets/estate_map_marker.dart';
import 'package:real_estate_app/features/map/presentation/widgets/estate_map_preview_card.dart';
import 'package:real_estate_app/features/map/presentation/widgets/map_controls_bar.dart';

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

  Widget buildTestWidget({MapScreenArgs? args}) {
    return BlocProvider<MapCubit>.value(
      value: cubit,
      child: MaterialApp(home: EstateMapScreen(args: args)),
    );
  }

  testWidgets('renders map screen, markers, and map controls', (tester) async {
    final estate1 = _createEstate(
      id: '1',
      title: 'Zamalek Luxury Apartment',
      price: 4500000,
      lat: 30.0610,
      lng: 31.2190,
    );

    await tester.pumpWidget(
      buildTestWidget(
        args: MapScreenArgs(estates: [estate1], title: 'Properties Map'),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and controls are present
    expect(find.text('Properties Map'), findsOneWidget);
    expect(find.byType(MapControlsBar), findsOneWidget);
    expect(find.byType(EstateMapMarker), findsOneWidget);
    expect(find.text('EGP 4.5 M'), findsOneWidget);
  });

  testWidgets(
    'tapping marker displays preview card and close button dismisses it',
    (tester) async {
      final estate = _createEstate(
        id: '1',
        title: 'Zamalek Luxury Apartment',
        price: 4500000,
        lat: 30.0610,
        lng: 31.2190,
      );

      await tester.pumpWidget(
        buildTestWidget(args: MapScreenArgs(estates: [estate])),
      );
      await tester.pumpAndSettle();

      // Initially preview card is not open
      expect(find.byType(EstateMapPreviewCard), findsNothing);

      // Tap marker
      await tester.tap(find.byType(EstateMapMarker));
      await tester.pumpAndSettle();

      // Preview card is now visible
      expect(find.byType(EstateMapPreviewCard), findsOneWidget);
      expect(find.text('Zamalek Luxury Apartment'), findsOneWidget);

      // Tap close button on preview card
      final closeButton = find.bySemanticsLabel('Close preview');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Preview card is dismissed
      expect(find.byType(EstateMapPreviewCard), findsNothing);
    },
  );

  testWidgets('renders empty view when all estates have invalid coordinates', (
    tester,
  ) async {
    final invalidEstate = _createEstate(id: 'invalid', lat: 0.0, lng: 0.0);

    await tester.pumpWidget(
      buildTestWidget(args: MapScreenArgs(estates: [invalidEstate])),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No properties with valid coordinates found.'),
      findsOneWidget,
    );
    expect(find.byType(EstateMapMarker), findsNothing);
    expect(find.text('Load All Properties'), findsOneWidget);
  });
}

class _FakeEstateRepository implements EstateRepository {
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
  }) async => (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async =>
      (failure: null, data: null);
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
    coverImage: '',
    images: const [],
    bedrooms: 3,
    bathrooms: 2,
    area: 180,
    isFurnished: true,
    amenities: const ['Balcony'],
    rating: 4.8,
    reviewCount: 12,
    isFeatured: true,
    isAvailable: true,
    status: 'active',
  );
}
