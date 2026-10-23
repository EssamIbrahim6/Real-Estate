import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/agent/domain/entities/agent_entity.dart';
import 'package:real_estate_app/features/agent/domain/repositories/agent_repository.dart';
import 'package:real_estate_app/features/agent/presentation/cubit/agent_details_cubit.dart';
import 'package:real_estate_app/features/agent/presentation/pages/agent_details_screen.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';

void main() {
  testWidgets('shows the agent profile and counts the fetched estate list', (
    tester,
  ) async {
    final cubit = _createCubit(
      estates: [_estate('estate-1'), _estate('estate-2')],
    );
    await cubit.loadAgentDetails('agent-document-id');
    await _pumpScreen(tester, cubit);

    expect(find.text('Nour Hassan'), findsOneWidget);
    expect(find.byKey(const Key('person-profile-image')), findsOneWidget);
    final image = tester.widget<Image>(
      find.byKey(const Key('person-profile-image')),
    );
    expect((image.image as NetworkImage).url, 'https://example.com/nour.jpg');
    expect(
      tester
          .widget<Text>(find.byKey(const Key('published-estates-count')))
          .data,
      '2',
    );
    expect(find.text('Property estate-1'), findsOneWidget);
    expect(find.text('Property estate-2'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('shows a loading count until the estates query completes', (
    tester,
  ) async {
    final estateLoad = Completer<void>();
    final cubit = _createCubit(waitForEstates: estateLoad);
    final loading = cubit.loadAgentDetails('agent-document-id');
    await _pumpScreen(tester, cubit);

    expect(
      tester
          .widget<Text>(find.byKey(const Key('published-estates-count')))
          .data,
      'Loading...',
    );

    estateLoad.complete();
    await loading;
    await tester.pump();
    expect(
      tester
          .widget<Text>(find.byKey(const Key('published-estates-count')))
          .data,
      '0',
    );
    expect(
      find.text('This agent has no published properties yet.'),
      findsOneWidget,
    );
    await cubit.close();
  });

  testWidgets('does not report zero when the estates query fails', (
    tester,
  ) async {
    final cubit = _createCubit(
      estateFailure: const ServerFailure(message: 'query failed'),
    );
    await cubit.loadAgentDetails('agent-document-id');
    await _pumpScreen(tester, cubit);

    expect(
      tester
          .widget<Text>(find.byKey(const Key('published-estates-count')))
          .data,
      'Unavailable',
    );
    expect(find.text('Properties could not be loaded.'), findsOneWidget);
    expect(
      find.text('This agent has no published properties yet.'),
      findsNothing,
    );
    await cubit.close();
  });
}

Future<void> _pumpScreen(WidgetTester tester, AgentDetailsCubit cubit) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      child: MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const AgentDetailsScreen(agentId: 'agent-document-id'),
        ),
      ),
    ),
  );
  await tester.pump();
}

AgentDetailsCubit _createCubit({
  List<EstateEntity> estates = const [],
  Failure? estateFailure,
  Completer<void>? waitForEstates,
}) => AgentDetailsCubit(
  agentRepository: _FakeAgentRepository(),
  estateRepository: _FakeEstateRepository(
    estates: estates,
    failure: estateFailure,
    waitForEstates: waitForEstates,
  ),
);

AgentEntity _agent() => const AgentEntity(
  id: 'agent-document-id',
  userId: 'auth-user-id',
  agencyName: 'Cairo Homes',
  name: 'Nour Hassan',
  phone: '',
  email: '',
  photoUrl: 'https://example.com/nour.jpg',
  bio: '',
  yearsOfExperience: 4,
  rating: 4.5,
  reviewCount: 8,
  estatesCount: 0,
  isVerified: true,
);

EstateEntity _estate(String id) => EstateEntity(
  id: id,
  title: 'Property $id',
  description: '',
  price: 100000,
  listingType: 'sale',
  categoryId: 'category',
  agentId: 'agent-document-id',
  location: const EstateLocationEntity(
    address: 'Cairo',
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
  isAvailable: true,
  status: 'active',
);

class _FakeAgentRepository implements AgentRepository {
  @override
  ResultFuture<AgentEntity> getAgentById(String id) async =>
      (failure: null, data: _agent());

  @override
  ResultFuture<List<AgentEntity>> getTopAgents({int limit = 10}) async =>
      (failure: null, data: const <AgentEntity>[]);
}

class _FakeEstateRepository implements EstateRepository {
  _FakeEstateRepository({
    required this.estates,
    this.failure,
    this.waitForEstates,
  });

  final List<EstateEntity> estates;
  final Failure? failure;
  final Completer<void>? waitForEstates;

  @override
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async {
    await waitForEstates?.future;
    if (failure != null) return (failure: failure, data: null);
    return (
      failure: null,
      data: estates.where((estate) => estate.agentId == agentId).toList(),
    );
  }

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async =>
      (failure: null, data: null);

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
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: estates);

  @override
  ResultFuture<String> createEstate(EstateEntity estate) async =>
      (failure: null, data: estate.id);
}
