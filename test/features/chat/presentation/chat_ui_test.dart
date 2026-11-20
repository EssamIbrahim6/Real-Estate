import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/features/chat/domain/entities/conversation_entity.dart';
import 'package:real_estate_app/features/chat/domain/entities/chat_launch_request.dart';
import 'package:real_estate_app/features/chat/domain/entities/message_entity.dart';
import 'package:real_estate_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:real_estate_app/features/chat/presentation/pages/conversation_screen.dart';
import 'package:real_estate_app/features/chat/presentation/widgets/chat_conversation_list.dart';
import 'package:real_estate_app/features/chat/presentation/widgets/conversation_message_bubble.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/core/widgets/app_skeleton.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';

void main() {
  testWidgets('message bubbles mirror their alignment in RTL', (tester) async {
    final outgoing = MessageEntity(id: 'outgoing', senderId: 'me', text: 'Hi');
    final incoming = MessageEntity(
      id: 'incoming',
      senderId: 'other',
      text: 'Hello',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ListView(
              children: [
                ConversationMessageBubble(message: outgoing, isMine: true),
                ConversationMessageBubble(message: incoming, isMine: false),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('message-outgoing'))).dx,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey('message-incoming'))).dx,
      ),
    );
  });

  testWidgets('Chat list shows loading, empty, success, and error states', (
    tester,
  ) async {
    final repository = _FakeChatRepository();
    final cubit = ChatCubit(chatRepository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const ChatScreen(currentUserUid: 'customer-uid'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ChatListSkeleton), findsOneWidget);

    repository.conversations.add(const []);
    await tester.pump();
    expect(find.text('No conversations yet'), findsOneWidget);

    repository.conversations.add([_conversation()]);
    await tester.pump();
    expect(find.text('Agent'), findsOneWidget);
    expect(find.text('Property inquiry'), findsOneWidget);

    repository.conversations.addError(StateError('Unable to load'));
    await tester.pump();
    expect(
      find.text('Could not load conversations. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Bad state: Unable to load'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    repository.conversations.add([_conversation()]);
    await tester.pump();
    expect(find.text('Agent'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await cubit.close();
      await repository.close();
    });
  });

  testWidgets('conversation aligns messages and sends trimmed text', (
    tester,
  ) async {
    final repository = _FakeChatRepository();
    final cubit = ChatCubit(chatRepository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const ConversationScreen(
            conversationId: 'conversation-id',
            title: 'Agent',
            currentUserUid: 'customer-uid',
          ),
        ),
      ),
    );
    repository.messages.add([
      MessageEntity(
        id: 'outgoing',
        senderId: 'customer-uid',
        text: 'Hello',
        createdAt: DateTime(2026, 11, 16, 15),
      ),
      MessageEntity(
        id: 'incoming',
        senderId: 'agent-uid',
        text: 'Welcome',
        createdAt: DateTime(2026, 11, 17, 9),
      ),
    ]);
    await tester.pump();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-date-2026-11-16')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-date-2026-11-17')), findsOneWidget);
    expect(repository.readParticipantUid, 'customer-uid');
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('message-outgoing'))).dx,
      greaterThan(
        tester.getTopLeft(find.byKey(const ValueKey('message-incoming'))).dx,
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('message-composer')),
      '   ',
    );
    await tester.tap(find.byKey(const ValueKey('send-message')));
    await tester.pump();
    expect(repository.sendCount, 0);

    await tester.enterText(
      find.byKey(const ValueKey('message-composer')),
      '  Hi there  ',
    );
    await tester.tap(find.byKey(const ValueKey('send-message')));
    await tester.pump();
    await tester.pump();
    expect(repository.sendCount, 1);
    expect(repository.lastSentText, 'Hi there');
    expect(find.text('Hi there'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await cubit.close();
      await repository.close();
    });
  });

  testWidgets('conversation loads its persisted estate on first open', (
    tester,
  ) async {
    final repository = _FakeChatRepository()
      ..conversationEstateId = 'persisted-estate-id';
    final estates = _FakeEstateRepository(_estate());
    final cubit = ChatCubit(
      chatRepository: repository,
      estateRepository: estates,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: ConversationScreen(
            conversationId: 'conversation-id',
            title: 'Agent',
            currentUserUid: 'customer-uid',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(estates.requestedId, 'persisted-estate-id');
    expect(find.text('Linked estate'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await cubit.close();
      await repository.close();
    });
  });

  testWidgets('Connect Agent stays local until the first message is sent', (
    tester,
  ) async {
    final repository = _FakeChatRepository()..conversationExists = false;
    final cubit = ChatCubit(chatRepository: repository);
    const request = ChatLaunchRequest(
      customerUid: 'customer-uid',
      agentUserUid: 'agent-uid',
      agentId: 'agent-document-id',
      estateId: 'estate-id',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: ConversationScreen(
            conversationId: request.conversationId,
            title: 'Agent',
            currentUserUid: 'customer-uid',
            launchRequest: request,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.messageWatchCount, 0);
    expect(repository.getConversationCount, greaterThan(0));
    expect(repository.createCount, 0);

    await tester.enterText(
      find.byKey(const ValueKey('message-composer')),
      'Hello agent',
    );
    await tester.tap(find.byKey(const ValueKey('send-message')));
    await tester.pump();
    await tester.pump();

    expect(repository.sendCount, 1);
    expect(repository.lastLaunchRequest, request);
    expect(repository.messageWatchCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await cubit.close();
      await repository.close();
    });
  });

  testWidgets('message long-press deletes for the current user only', (
    tester,
  ) async {
    final repository = _FakeChatRepository();
    final cubit = ChatCubit(chatRepository: repository);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const ConversationScreen(
            conversationId: 'conversation-id',
            title: 'Agent',
            currentUserUid: 'customer-uid',
          ),
        ),
      ),
    );
    repository.messages.add([
      const MessageEntity(
        id: 'message-id',
        senderId: 'agent-uid',
        text: 'Hello',
      ),
    ]);
    await tester.pump();

    await tester.longPress(
      find.byKey(const ValueKey('message-action-message-id')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('confirm-delete-message-for-me')),
    );
    await tester.pumpAndSettle();

    expect(repository.deletedMessageId, 'message-id');
    expect(repository.deletedForUid, 'customer-uid');
    await tester.pump(const Duration(seconds: 3));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await cubit.close();
      await repository.close();
    });
  });

  for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
    testWidgets('conversation archive swipe works in $direction', (
      tester,
    ) async {
      var archiveCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: ChatConversationList(
                conversations: [_conversation()],
                currentUserUid: 'customer-uid',
                onConversationTap: (_) {},
                onArchiveConversation: (_) async {
                  archiveCount++;
                  return true;
                },
                inquiryLabel: 'Property inquiry',
                estatePreviews: const {},
                participantPreviews: const {},
              ),
            ),
          ),
        ),
      );

      await tester.drag(
        find.byKey(const ValueKey('dismissible-conversation-id')),
        Offset(direction == TextDirection.ltr ? -500 : 500, 0),
      );
      await tester.pumpAndSettle();

      expect(archiveCount, 1);
    });
  }

  testWidgets('Chat list opens a conversation and back returns to the list', (
    tester,
  ) async {
    final repository = _FakeChatRepository();
    final cubit = ChatCubit(chatRepository: repository);
    final router = GoRouter(
      initialLocation: '/chat',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocProvider.value(value: cubit, child: child),
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) =>
                  const ChatScreen(currentUserUid: 'customer-uid'),
              routes: [
                GoRoute(
                  path: 'conversation/:conversationId',
                  name: 'chat-conversation',
                  builder: (context, state) => ConversationScreen(
                    conversationId:
                        state.pathParameters['conversationId'] ?? '',
                    title: state.uri.queryParameters['title'] ?? 'Agent',
                    currentUserUid: 'customer-uid',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    repository.conversations.add([_conversation()]);
    await tester.pump();
    await tester.tap(find.text('Agent'));
    await tester.pump(const Duration(milliseconds: 500));
    repository.messages.add(const []);
    await tester.pump();
    expect(
      find.text('No messages yet. Start the conversation.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Agent'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await tester.runAsync(() async {
      await cubit.close();
      await repository.close();
    });
  });
}

ConversationEntity _conversation() => const ConversationEntity(
  id: 'conversation-id',
  participants: ['customer-uid', 'agent-uid'],
  customerId: 'customer-uid',
  agentUserId: 'agent-uid',
  agentId: 'agent-document-id',
  estateId: 'estate-id',
  lastMessage: null,
);

class _FakeChatRepository implements ChatRepository {
  final conversations = StreamController<List<ConversationEntity>>.broadcast();
  final messages = StreamController<List<MessageEntity>>.broadcast();
  int sendCount = 0;
  String? lastSentText;
  String? readParticipantUid;
  String? conversationEstateId;
  bool conversationExists = true;
  int getConversationCount = 0;
  int messageWatchCount = 0;
  int createCount = 0;
  ChatLaunchRequest? lastLaunchRequest;
  String? deletedMessageId;
  String? deletedForUid;

  @override
  ResultFuture<ConversationEntity> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async {
    createCount++;
    return (failure: null, data: _conversation());
  }

  @override
  ResultFuture<ConversationEntity?> getConversation(
    String conversationId,
  ) async {
    getConversationCount++;
    return (
      failure: null,
      data: conversationExists
          ? ConversationEntity(
              id: 'conversation-id',
              participants: ['customer-uid', 'agent-uid'],
              customerId: 'customer-uid',
              agentUserId: 'agent-uid',
              agentId: 'agent-document-id',
              estateId: conversationEstateId,
            )
          : null,
    );
  }

  @override
  ResultVoid markConversationAsRead({
    required String conversationId,
    required String participantUid,
  }) async {
    readParticipantUid = participantUid;
    return (failure: null, isSuccess: true);
  }

  @override
  ResultVoid sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    ChatLaunchRequest? launchRequest,
  }) async {
    sendCount++;
    lastSentText = text;
    lastLaunchRequest = launchRequest;
    return (failure: null, isSuccess: true);
  }

  @override
  ResultVoid archiveConversation({
    required String conversationId,
    required String participantUid,
  }) async => (failure: null, isSuccess: true);

  @override
  ResultVoid deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String participantUid,
  }) async {
    deletedMessageId = messageId;
    deletedForUid = participantUid;
    return (failure: null, isSuccess: true);
  }

  @override
  Stream<List<ConversationEntity>> watchConversations(String currentUserUid) =>
      conversations.stream;

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) =>
      _trackMessageWatch();

  Stream<List<MessageEntity>> _trackMessageWatch() {
    messageWatchCount++;
    return messages.stream;
  }

  Future<void> close() async {
    await conversations.close();
    await messages.close();
  }
}

class _FakeEstateRepository implements EstateRepository {
  _FakeEstateRepository(this.estate);

  final EstateEntity estate;
  String? requestedId;

  @override
  ResultFuture<EstateEntity> getEstateById(String id) async {
    requestedId = id;
    return (failure: null, data: estate);
  }

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
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async =>
      (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<String> createEstate(EstateEntity estate) async =>
      (failure: null, data: estate.id);

  @override
  ResultFuture<List<EstateEntity>> getEstatesByOwnerId(String ownerId) async =>
      (failure: null, data: const <EstateEntity>[]);

  @override
  ResultVoid deleteEstate({
    required String estateId,
    required String currentUid,
  }) async => (failure: null, isSuccess: true);
}

EstateEntity _estate() => EstateEntity(
  id: 'persisted-estate-id',
  title: 'Linked estate',
  description: '',
  price: 2500000,
  listingType: 'sale',
  categoryId: 'apartment',
  agentId: 'agent-document-id',
  location: const EstateLocationEntity(
    address: 'Central district',
    city: 'Cairo',
    latitude: 30,
    longitude: 31,
  ),
  coverImage: '',
  images: const [],
  bedrooms: 2,
  bathrooms: 1,
  area: 90,
  isFurnished: false,
  amenities: const [],
  rating: 0,
  reviewCount: 0,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);
