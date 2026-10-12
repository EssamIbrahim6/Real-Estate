import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl(this._remoteDataSource);

  @override
  ResultFuture<ConversationEntity> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async {
    try {
      final conversation = await _remoteDataSource.getOrCreateConversation(
        customerUid: customerUid,
        agentUserUid: agentUserUid,
        agentId: agentId,
        estateId: estateId,
      );
      return (failure: null, data: conversation);
    } on ArgumentError catch (error) {
      return (
        failure: ValidationFailure(message: error.message.toString()),
        data: null,
      );
    } on ServerException catch (error) {
      return (failure: ServerFailure(message: error.message), data: null);
    } catch (error) {
      return (failure: ServerFailure(message: error.toString()), data: null);
    }
  }

  @override
  Stream<List<ConversationEntity>> watchConversations(String currentUserUid) {
    return _remoteDataSource
        .watchConversations(currentUserUid)
        .map((conversations) => conversations.cast<ConversationEntity>());
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return _remoteDataSource
        .watchMessages(conversationId)
        .map((messages) => messages.cast<MessageEntity>());
  }

  @override
  ResultVoid sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      return (
        failure: const ValidationFailure(
          message: 'Message text cannot be empty.',
        ),
        isSuccess: false,
      );
    }
    try {
      await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        text: text,
      );
      return (failure: null, isSuccess: true);
    } on ServerException catch (error) {
      return (failure: ServerFailure(message: error.message), isSuccess: false);
    } catch (error) {
      return (
        failure: ServerFailure(message: error.toString()),
        isSuccess: false,
      );
    }
  }

  @override
  ResultVoid markConversationAsRead({
    required String conversationId,
    required String participantUid,
  }) async {
    try {
      await _remoteDataSource.markConversationAsRead(
        conversationId: conversationId,
        participantUid: participantUid,
      );
      return (failure: null, isSuccess: true);
    } on ServerException catch (error) {
      return (failure: ServerFailure(message: error.message), isSuccess: false);
    } catch (error) {
      return (
        failure: ServerFailure(message: error.toString()),
        isSuccess: false,
      );
    }
  }
}
