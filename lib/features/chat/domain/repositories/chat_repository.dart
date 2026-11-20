import '../../../../core/utils/typedefs.dart';
import '../entities/chat_launch_request.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  ResultFuture<ConversationEntity> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  });

  ResultFuture<ConversationEntity?> getConversation(String conversationId);

  Stream<List<ConversationEntity>> watchConversations(String currentUserUid);

  Stream<List<MessageEntity>> watchMessages(String conversationId);

  ResultVoid sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    ChatLaunchRequest? launchRequest,
  });

  ResultVoid archiveConversation({
    required String conversationId,
    required String participantUid,
  });

  ResultVoid deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String participantUid,
  });

  ResultVoid markConversationAsRead({
    required String conversationId,
    required String participantUid,
  });
}
