import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

enum ChatLoadStatus { initial, loading, success, empty, failure }

class ChatState extends Equatable {
  final ChatLoadStatus conversationsStatus;
  final List<ConversationEntity> conversations;
  final Failure? conversationsFailure;
  final ChatLoadStatus messagesStatus;
  final String? activeConversationId;
  final List<MessageEntity> messages;
  final Failure? messagesFailure;
  final bool isSending;
  final Failure? sendingFailure;
  final Failure? actionFailure;

  const ChatState({
    this.conversationsStatus = ChatLoadStatus.initial,
    this.conversations = const [],
    this.conversationsFailure,
    this.messagesStatus = ChatLoadStatus.initial,
    this.activeConversationId,
    this.messages = const [],
    this.messagesFailure,
    this.isSending = false,
    this.sendingFailure,
    this.actionFailure,
  });

  ChatState copyWith({
    ChatLoadStatus? conversationsStatus,
    List<ConversationEntity>? conversations,
    Failure? conversationsFailure,
    ChatLoadStatus? messagesStatus,
    String? activeConversationId,
    List<MessageEntity>? messages,
    Failure? messagesFailure,
    bool? isSending,
    Failure? sendingFailure,
    Failure? actionFailure,
    bool clearConversationsFailure = false,
    bool clearMessagesFailure = false,
    bool clearSendingFailure = false,
    bool clearActionFailure = false,
    bool clearActiveConversationId = false,
  }) {
    return ChatState(
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      conversationsFailure: clearConversationsFailure
          ? null
          : conversationsFailure ?? this.conversationsFailure,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      activeConversationId: clearActiveConversationId
          ? null
          : activeConversationId ?? this.activeConversationId,
      messages: messages ?? this.messages,
      messagesFailure: clearMessagesFailure
          ? null
          : messagesFailure ?? this.messagesFailure,
      isSending: isSending ?? this.isSending,
      sendingFailure: clearSendingFailure
          ? null
          : sendingFailure ?? this.sendingFailure,
      actionFailure: clearActionFailure
          ? null
          : actionFailure ?? this.actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    conversationsStatus,
    conversations,
    conversationsFailure,
    messagesStatus,
    activeConversationId,
    messages,
    messagesFailure,
    isSending,
    sendingFailure,
    actionFailure,
  ];
}
