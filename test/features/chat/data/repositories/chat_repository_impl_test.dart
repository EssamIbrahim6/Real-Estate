import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/exceptions.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:real_estate_app/features/chat/data/models/conversation_model.dart';
import 'package:real_estate_app/features/chat/data/models/message_model.dart';
import 'package:real_estate_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:real_estate_app/features/chat/domain/entities/chat_launch_request.dart';

void main() {
  test('conversation ID is deterministic and tuple collision-safe', () {
    String id(String customer, String agent) =>
        ChatRemoteDataSourceImpl.conversationIdFor(
          customerUid: customer,
          agentUserUid: agent,
        );

    expect(id('customer', 'agent'), id('customer', 'agent'));
    expect(id('a', 'bc'), isNot(id('ab', 'c')));
  });

  test('empty messages are rejected before reaching the data source', () async {
    final dataSource = _FakeChatRemoteDataSource();
    final repository = ChatRepositoryImpl(dataSource);

    final result = await repository.sendMessage(
      conversationId: 'conversation-id',
      senderId: 'sender-uid',
      text: '  \n ',
    );

    expect(result.isSuccess, isFalse);
    expect(result.failure, isA<ValidationFailure>());
    expect(dataSource.sendMessageCalled, isFalse);
  });

  test('maps one-shot data source errors to existing ServerFailure', () async {
    final repository = ChatRepositoryImpl(
      _FakeChatRemoteDataSource()..throwOnCreate = true,
    );

    final result = await repository.getOrCreateConversation(
      customerUid: 'customer-uid',
      agentUserUid: 'agent-user-uid',
      agentId: 'agent-id',
      estateId: 'estate-id',
    );

    expect(result.data, isNull);
    expect(result.failure, isA<ServerFailure>());
    expect(result.failure!.message, 'Firestore unavailable');
  });
}

class _FakeChatRemoteDataSource implements ChatRemoteDataSource {
  bool throwOnCreate = false;
  bool sendMessageCalled = false;

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async {
    if (throwOnCreate) {
      throw const ServerException(message: 'Firestore unavailable');
    }
    return ConversationModel(
      id: 'conversation-id',
      participants: [customerUid, agentUserUid],
      customerId: customerUid,
      agentUserId: agentUserUid,
      agentId: agentId,
      estateId: estateId,
    );
  }

  @override
  Future<ConversationModel?> getConversation(String conversationId) async =>
      ConversationModel(
        id: conversationId,
        participants: const ['customer', 'agent'],
        customerId: 'customer',
        agentUserId: 'agent',
        agentId: 'agent-id',
        estateId: 'estate-id',
      );

  @override
  Stream<List<ConversationModel>> watchConversations(String currentUserUid) =>
      const Stream.empty();

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) =>
      const Stream.empty();

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    ChatLaunchRequest? launchRequest,
  }) async {
    sendMessageCalled = true;
  }

  @override
  Future<void> archiveConversation({
    required String conversationId,
    required String participantUid,
  }) async {}

  @override
  Future<void> deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String participantUid,
  }) async {}

  @override
  Future<void> markConversationAsRead({
    required String conversationId,
    required String participantUid,
  }) async {}
}
