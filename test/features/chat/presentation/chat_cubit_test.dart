import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/chat/domain/entities/conversation_entity.dart';
import 'package:real_estate_app/features/chat/domain/entities/message_entity.dart';
import 'package:real_estate_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_state.dart';

void main() {
  test(
    'permission-denied stream errors are not reported as auth failures',
    () async {
      final repository = _FakeChatRepository();
      final cubit = ChatCubit(chatRepository: repository);
      await cubit.watchConversations('customer-uid');

      repository.conversationController.addError(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.conversationsFailure, isA<ServerFailure>());
      expect(cubit.state.conversationsFailure, isNot(isA<AuthFailure>()));
      expect(
        cubit.state.conversationsFailure?.message,
        'You do not have permission to access this chat.',
      );

      await cubit.close();
      await repository.conversationController.close();
      await repository.messageController.close();
    },
  );

  test('empty user IDs are rejected before subscribing', () async {
    final repository = _FakeChatRepository();
    final cubit = ChatCubit(chatRepository: repository);

    await cubit.watchConversations('  ');

    expect(cubit.state.conversationsFailure, isA<ValidationFailure>());
    expect(repository.conversationWatchCount, 0);
    await cubit.close();
    await repository.conversationController.close();
    await repository.messageController.close();
  });

  test(
    'deduplicates subscriptions, retries stream errors, and cancels on close',
    () async {
      final repository = _FakeChatRepository();
      final cubit = ChatCubit(chatRepository: repository);

      await cubit.watchConversations('customer-uid');
      await cubit.watchConversations('customer-uid');
      await cubit.watchMessages('conversation-id');
      await cubit.watchMessages('conversation-id');

      expect(repository.conversationWatchCount, 1);
      expect(repository.messageWatchCount, 1);
      expect(repository.conversationController.hasListener, isTrue);
      expect(repository.messageController.hasListener, isTrue);

      repository.conversationController.addError(StateError('stream failed'));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.conversationsStatus, ChatLoadStatus.failure);

      await cubit.watchConversations('customer-uid');
      expect(repository.conversationWatchCount, 2);

      await cubit.close();
      expect(repository.conversationController.hasListener, isFalse);
      expect(repository.messageController.hasListener, isFalse);

      await repository.conversationController.close();
      await repository.messageController.close();
    },
  );
}

class _FakeChatRepository implements ChatRepository {
  final conversationController =
      StreamController<List<ConversationEntity>>.broadcast();
  final messageController = StreamController<List<MessageEntity>>.broadcast();
  int conversationWatchCount = 0;
  int messageWatchCount = 0;

  @override
  ResultFuture<ConversationEntity> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async => (
    failure: null,
    data: ConversationEntity(
      id: 'conversation-id',
      participants: [customerUid, agentUserUid],
      customerId: customerUid,
      agentUserId: agentUserUid,
      agentId: agentId,
      estateId: estateId,
    ),
  );

  @override
  Stream<List<ConversationEntity>> watchConversations(String currentUserUid) {
    conversationWatchCount++;
    return conversationController.stream;
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    messageWatchCount++;
    return messageController.stream;
  }

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
