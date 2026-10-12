import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/navigation/main_navigation_shell.dart';
import 'package:real_estate_app/core/router/route_names.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/agent/domain/entities/agent_entity.dart';
import 'package:real_estate_app/features/agent/domain/repositories/agent_repository.dart';
import 'package:real_estate_app/features/chat/domain/entities/conversation_entity.dart';
import 'package:real_estate_app/features/chat/domain/entities/message_entity.dart';
import 'package:real_estate_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:real_estate_app/features/chat/presentation/pages/conversation_screen.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';
import 'package:real_estate_app/features/estate_details/domain/entities/review_entity.dart';
import 'package:real_estate_app/features/estate_details/domain/repositories/estate_details_repository.dart';
import 'package:real_estate_app/features/estate_details/presentation/cubit/estate_details_cubit.dart';
import 'package:real_estate_app/features/estate_details/presentation/cubit/estate_details_state.dart';
import 'package:real_estate_app/features/estate_details/presentation/pages/estate_details_screen.dart';

void main() {
  group('EstateDetailsCubit.startConversationWithAgent', () {
    test('resolves estate agent document to its Auth UID', () async {
      final agentRepository = _FakeAgentRepository(agent: _agent());
      final chatRepository = _FakeChatRepository();
      final cubit = _createCubit(
        auth: _FakeFirebaseAuth(_FakeUser('customer-auth-uid')),
        agentRepository: agentRepository,
        chatRepository: chatRepository,
      );
      await cubit.loadEstateDetails(
        'estate-document-id',
        initialEstate: _estate(),
      );

      final conversationId = await cubit.startConversationWithAgent();

      expect(conversationId, 'resolved-conversation-id');
      expect(agentRepository.requestedAgentId, 'agent-document-id');
      expect(chatRepository.customerUid, 'customer-auth-uid');
      expect(chatRepository.agentUserUid, 'agent-auth-uid');
      expect(chatRepository.agentId, 'agent-document-id');
      expect(chatRepository.estateId, 'estate-document-id');
      expect(cubit.state.contactAgentStatus, ContactAgentStatus.success);
      await cubit.close();
    });

    test('fails when the estate has no agent document', () async {
      final chatRepository = _FakeChatRepository();
      final cubit = _createCubit(
        auth: _FakeFirebaseAuth(_FakeUser('customer-auth-uid')),
        agentRepository: _FakeAgentRepository(),
        chatRepository: chatRepository,
      );
      await _loadEstate(cubit, estate: _estate());

      expect(await cubit.startConversationWithAgent(), isNull);
      expect(
        cubit.state.contactAgentError,
        contains('could not find the agent'),
      );
      expect(chatRepository.callCount, 0);
      await cubit.close();
    });

    test(
      'reports agent repository failures without exposing backend details',
      () async {
        final chatRepository = _FakeChatRepository();
        final cubit = _createCubit(
          auth: _FakeFirebaseAuth(_FakeUser('customer-auth-uid')),
          agentRepository: _FakeAgentRepository(
            failure: const ServerFailure(message: 'permission-denied'),
          ),
          chatRepository: chatRepository,
        );
        await _loadEstate(cubit, estate: _estate());

        expect(await cubit.startConversationWithAgent(), isNull);
        expect(
          cubit.state.contactAgentError,
          'We could not find the agent for this property.',
        );
        expect(
          cubit.state.contactAgentError,
          isNot(contains('permission-denied')),
        );
        expect(chatRepository.callCount, 0);
        await cubit.close();
      },
    );

    test('fails when the Agent userId is empty', () async {
      final chatRepository = _FakeChatRepository();
      final cubit = _createCubit(
        auth: _FakeFirebaseAuth(_FakeUser('customer-auth-uid')),
        agentRepository: _FakeAgentRepository(agent: _agent(userId: '  ')),
        chatRepository: chatRepository,
      );
      await _loadEstate(cubit, estate: _estate());

      expect(await cubit.startConversationWithAgent(), isNull);
      expect(cubit.state.contactAgentError, contains('not set up'));
      expect(chatRepository.callCount, 0);
      await cubit.close();
    });

    test('requires an authenticated customer', () async {
      final chatRepository = _FakeChatRepository();
      final cubit = _createCubit(
        auth: _FakeFirebaseAuth(null),
        agentRepository: _FakeAgentRepository(agent: _agent()),
        chatRepository: chatRepository,
      );
      await _loadEstate(cubit, estate: _estate());

      expect(await cubit.startConversationWithAgent(), isNull);
      expect(cubit.state.contactAgentError, contains('Sign in'));
      expect(chatRepository.callCount, 0);
      await cubit.close();
    });

    test('prevents contacting the current user as the agent', () async {
      final chatRepository = _FakeChatRepository();
      final cubit = _createCubit(
        auth: _FakeFirebaseAuth(_FakeUser('agent-auth-uid')),
        agentRepository: _FakeAgentRepository(agent: _agent()),
        chatRepository: chatRepository,
      );
      await _loadEstate(cubit, estate: _estate());

      expect(await cubit.startConversationWithAgent(), isNull);
      expect(cubit.state.contactAgentError, contains('own agent'));
      expect(chatRepository.callCount, 0);
      await cubit.close();
    });

    test(
      'reports conversation creation failure without exposing details',
      () async {
        final chatRepository = _FakeChatRepository(
          conversationFailure: const ServerFailure(
            message: 'permission-denied raw backend detail',
          ),
        );
        final cubit = _createCubit(
          auth: _FakeFirebaseAuth(_FakeUser('customer-auth-uid')),
          agentRepository: _FakeAgentRepository(agent: _agent()),
          chatRepository: chatRepository,
        );
        await _loadEstate(cubit, estate: _estate());

        expect(await cubit.startConversationWithAgent(), isNull);
        expect(
          cubit.state.contactAgentError,
          'We could not open this conversation. Please try again.',
        );
        expect(
          cubit.state.contactAgentError,
          isNot(contains('permission-denied')),
        );
        await cubit.close();
      },
    );

    test('fails before lookup when estate agentId is missing', () async {
      final agentRepository = _FakeAgentRepository(agent: _agent());
      final chatRepository = _FakeChatRepository();
      final cubit = _createCubit(
        auth: _FakeFirebaseAuth(_FakeUser('customer-auth-uid')),
        agentRepository: agentRepository,
        chatRepository: chatRepository,
      );
      await _loadEstate(cubit, estate: _estate(agentId: ' '));

      expect(await cubit.startConversationWithAgent(), isNull);
      expect(agentRepository.requestedAgentId, isNull);
      expect(chatRepository.callCount, 0);
      await cubit.close();
    });
  });

  testWidgets('chat and Contact Agent navigation reuse one root navigator', (
    tester,
  ) async {
    final chatRepository = _FakeChatRepository();
    final chatCubit = ChatCubit(chatRepository: chatRepository);
    final cubit = _createCubit(
      auth: _FakeFirebaseAuth(_FakeUser('customer-auth-uid')),
      agentRepository: _FakeAgentRepository(agent: _agent()),
      chatRepository: chatRepository,
    );
    await _loadEstate(cubit, estate: _estate());
    final rootKey = GlobalKey<NavigatorState>(debugLabel: 'testRootNav');
    final router = GoRouter(
      navigatorKey: rootKey,
      initialLocation: '/chat',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainNavigationShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Home branch')),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Search branch')),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  path: '/chat',
                  name: 'chat',
                  builder: (context, state) => Stack(
                    children: [
                      BlocProvider.value(
                        value: chatCubit,
                        child: const ChatScreen(
                          currentUserUid: 'customer-auth-uid',
                        ),
                      ),
                      Positioned(
                        top: 90,
                        right: 12,
                        child: TextButton(
                          onPressed: () => context.go('/property'),
                          child: const Text('Open property test route'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Profile branch')),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/property',
          builder: (context, state) => BlocProvider.value(
            value: cubit,
            child: const EstateDetailsScreen(estateId: 'estate-document-id'),
          ),
        ),
        GoRoute(
          path: '/chat/conversation/:conversationId',
          name: AppRoutes.chatConversationName,
          parentNavigatorKey: rootKey,
          builder: (context, state) => BlocProvider(
            create: (_) => ChatCubit(chatRepository: chatRepository),
            child: ConversationScreen(
              conversationId: state.pathParameters['conversationId'] ?? '',
              title: 'Agent',
              currentUserUid: 'customer-auth-uid',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(rootKey), findsOneWidget);

    Future<void> openConversation() async {
      await tester.tap(find.text('Agent'));
      await tester.pumpAndSettle();
      expect(
        find.text('No messages yet. Start the conversation.'),
        findsOneWidget,
      );
      expect(find.byKey(rootKey), findsOneWidget);
    }

    Future<void> returnFromConversation() async {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Chat'), findsOneWidget);
      expect(find.byKey(rootKey), findsOneWidget);
    }

    await openConversation();
    await returnFromConversation();
    await openConversation();
    await returnFromConversation();

    await tester.tap(find.text('Open property test route'));
    await tester.pumpAndSettle();
    expect(find.text('Contact Agent'), findsOneWidget);
    expect(find.byKey(rootKey), findsOneWidget);

    await tester.tap(find.text('Contact Agent'));
    await tester.pumpAndSettle();
    expect(
      find.text('No messages yet. Start the conversation.'),
      findsOneWidget,
    );
    expect(chatRepository.agentUserUid, 'agent-auth-uid');
    expect(find.byKey(rootKey), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Contact Agent'), findsOneWidget);
    expect(find.byKey(rootKey), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await tester.runAsync(() async {
      await chatCubit.close();
      await cubit.close();
    });
  });
}

EstateDetailsCubit _createCubit({
  required FirebaseAuth auth,
  required _FakeAgentRepository agentRepository,
  required _FakeChatRepository chatRepository,
}) => EstateDetailsCubit(
  estateRepository: _FakeEstateRepository(),
  agentRepository: agentRepository,
  estateDetailsRepository: _FakeEstateDetailsRepository(),
  firebaseAuth: auth,
  chatRepository: chatRepository,
);

Future<void> _loadEstate(
  EstateDetailsCubit cubit, {
  required EstateEntity estate,
}) async {
  await cubit.loadEstateDetails(estate.id, initialEstate: estate);
}

EstateEntity _estate({String agentId = 'agent-document-id'}) => EstateEntity(
  id: 'estate-document-id',
  title: 'Home',
  description: '',
  price: 100,
  listingType: 'sale',
  categoryId: 'category',
  agentId: agentId,
  location: const EstateLocationEntity(
    address: 'Address',
    city: 'City',
    latitude: 0,
    longitude: 0,
  ),
  coverImage: '',
  images: const [],
  bedrooms: 1,
  bathrooms: 1,
  area: 50,
  isFurnished: false,
  amenities: const [],
  rating: 0,
  reviewCount: 0,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);

ConversationEntity _conversation() => const ConversationEntity(
  id: 'resolved-conversation-id',
  participants: ['customer-auth-uid', 'agent-auth-uid'],
  customerId: 'customer-auth-uid',
  agentUserId: 'agent-auth-uid',
  agentId: 'agent-document-id',
  estateId: 'estate-document-id',
);

AgentEntity _agent({String userId = 'agent-auth-uid'}) => AgentEntity(
  id: 'agent-document-id',
  userId: userId,
  agencyName: 'Agency',
  bio: '',
  yearsOfExperience: 1,
  rating: 0,
  reviewCount: 0,
  isVerified: false,
);

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth(this.currentUser);

  @override
  final User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAgentRepository implements AgentRepository {
  _FakeAgentRepository({this.agent, this.failure});

  final AgentEntity? agent;
  final Failure? failure;
  String? requestedAgentId;

  @override
  ResultFuture<AgentEntity> getAgentById(String id) async {
    requestedAgentId = id;
    return (failure: failure, data: agent);
  }

  @override
  ResultFuture<List<AgentEntity>> getTopAgents({int limit = 10}) async =>
      (failure: null, data: const <AgentEntity>[]);
}

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.conversationFailure});

  final Failure? conversationFailure;
  int callCount = 0;
  String? customerUid;
  String? agentUserUid;
  String? agentId;
  String? estateId;

  @override
  ResultFuture<ConversationEntity> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async {
    callCount++;
    this.customerUid = customerUid;
    this.agentUserUid = agentUserUid;
    this.agentId = agentId;
    this.estateId = estateId;
    return (
      failure: conversationFailure,
      data: conversationFailure == null
          ? const ConversationEntity(
              id: 'resolved-conversation-id',
              participants: ['customer-auth-uid', 'agent-auth-uid'],
              customerId: 'customer-auth-uid',
              agentUserId: 'agent-auth-uid',
              agentId: 'agent-document-id',
              estateId: 'estate-document-id',
            )
          : null,
    );
  }

  @override
  Stream<List<ConversationEntity>> watchConversations(String currentUserUid) =>
      Stream.value([_conversation()]);

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) =>
      Stream.value(const []);

  @override
  ResultVoid sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async => (failure: null, isSuccess: true);

  @override
  ResultVoid markConversationAsRead({
    required String conversationId,
    required String participantUid,
  }) async => (failure: null, isSuccess: true);
}

class _FakeEstateRepository implements EstateRepository {
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
  }) async => (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: const <EstateEntity>[]);
}

class _FakeEstateDetailsRepository implements EstateDetailsRepository {
  @override
  ResultFuture<List<ReviewEntity>> getReviews(
    String estateId, {
    int limit = 20,
  }) async => (failure: null, data: const <ReviewEntity>[]);

  @override
  ResultFuture<ReviewEntity?> getUserReview(
    String estateId,
    String userId,
  ) async => (failure: null, data: null);

  @override
  ResultVoid submitReview({
    required String estateId,
    required String userId,
    required String userName,
    String? userProfileImage,
    required int rating,
    required String comment,
    String? existingReviewId,
  }) async => (failure: null, isSuccess: true);
}
