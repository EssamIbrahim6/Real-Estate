import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/agent/domain/entities/agent_entity.dart';
import 'package:real_estate_app/features/agent/domain/repositories/agent_repository.dart';
import 'package:real_estate_app/features/agent/presentation/cubit/agent_details_cubit.dart';
import 'package:real_estate_app/features/agent/presentation/cubit/agent_details_state.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';

void main() {
  group('AgentDetailsCubit', () {
    test('loads agent and their published estates by agentId', () async {
      final cubit = AgentDetailsCubit(
        agentRepository: _FakeAgentRepository(
          agent: const AgentEntity(
            id: 'agent-1',
            userId: 'user-1',
            agencyName: 'City Crest',
            name: 'Jane Doe',
            phone: '123',
            email: 'jane@example.com',
            photoUrl: 'https://example.com/jane.png',
            bio: 'Trusted agent',
            yearsOfExperience: 8,
            rating: 4.8,
            reviewCount: 15,
            estatesCount: 2,
            isVerified: true,
          ),
        ),
        estateRepository: _FakeEstateRepository(
          estates: [
            _estate('estate-1', 'agent-1'),
            _estate('estate-2', 'agent-1'),
          ],
        ),
      );

      await cubit.loadAgentDetails('agent-1');

      expect(cubit.state.status, AgentDetailsStatus.success);
      expect(cubit.state.agent?.displayName, 'Jane Doe');
      expect(cubit.state.estates, hasLength(2));
      expect(cubit.state.estates.first.agentId, 'agent-1');
    });

    test('handles a missing agent gracefully', () async {
      final cubit = AgentDetailsCubit(
        agentRepository: _FakeAgentRepository(),
        estateRepository: _FakeEstateRepository(),
      );

      await cubit.loadAgentDetails('missing-agent');

      expect(cubit.state.status, AgentDetailsStatus.error);
      expect(cubit.state.error, 'Agent details not found.');
    });
  });
}

EstateEntity _estate(String id, String agentId) => EstateEntity(
  id: id,
  title: 'Sample villa',
  description: 'A nice place',
  price: 1000000,
  listingType: 'sale',
  categoryId: 'category',
  agentId: agentId,
  location: const EstateLocationEntity(
    address: 'Address',
    city: 'Cairo',
    latitude: 30,
    longitude: 31,
  ),
  coverImage: '',
  images: const [],
  bedrooms: 3,
  bathrooms: 2,
  area: 180,
  isFurnished: false,
  amenities: const [],
  rating: 4.5,
  reviewCount: 5,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);

class _FakeAgentRepository implements AgentRepository {
  _FakeAgentRepository({this.agent, this.failure});

  final AgentEntity? agent;
  final Failure? failure;

  @override
  ResultFuture<AgentEntity> getAgentById(String id) async {
    if (failure != null) return (failure: failure, data: null);
    return (failure: null, data: agent);
  }

  @override
  ResultFuture<List<AgentEntity>> getTopAgents({int limit = 10}) async =>
      (failure: null, data: const <AgentEntity>[]);
}

class _FakeEstateRepository implements EstateRepository {
  _FakeEstateRepository({this.estates = const <EstateEntity>[]});

  final List<EstateEntity> estates;

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: estates);

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
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async {
    final filtered = estates.where((estate) => estate.agentId == agentId).toList();
    return (failure: null, data: filtered);
  }

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async =>
      (failure: null, data: estates.firstWhere((e) => e.id == id, orElse: () => estates.first));
}
