import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/chat/domain/entities/conversation_entity.dart';
import 'package:real_estate_app/features/chat/domain/entities/message_entity.dart';
import 'package:real_estate_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_state.dart';

void main() {
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
