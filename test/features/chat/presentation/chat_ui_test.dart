import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/features/chat/domain/entities/conversation_entity.dart';
import 'package:real_estate_app/features/chat/domain/entities/message_entity.dart';
import 'package:real_estate_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:real_estate_app/features/chat/presentation/pages/conversation_screen.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';

void main() {
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
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

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
      const MessageEntity(
        id: 'outgoing',
        senderId: 'customer-uid',
        text: 'Hello',
      ),
      const MessageEntity(
        id: 'incoming',
        senderId: 'agent-uid',
        text: 'Welcome',
      ),
    ]);
    await tester.pump();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
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

  @override
  ResultFuture<ConversationEntity> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async => (failure: null, data: _conversation());

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
  }) async {
    sendCount++;
    lastSentText = text;
    return (failure: null, isSuccess: true);
  }

  @override
  Stream<List<ConversationEntity>> watchConversations(String currentUserUid) =>
      conversations.stream;

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) =>
      messages.stream;

  Future<void> close() async {
    await conversations.close();
    await messages.close();
  }
}
