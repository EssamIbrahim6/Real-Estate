import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  String? _watchedUserId;
  String? _watchedConversationId;
  int _conversationGeneration = 0;
  int _messageGeneration = 0;

  ChatCubit({required this._chatRepository}) : super(const ChatState());

  Future<void> watchConversations(String currentUserUid) async {
    final userId = currentUserUid.trim();
    if (userId.isEmpty) {
      emit(
        state.copyWith(
          conversationsStatus: ChatLoadStatus.failure,
          conversationsFailure: const ValidationFailure(
            message: 'A signed-in user is required to load conversations.',
          ),
        ),
      );
      return;
    }
    if (_watchedUserId == userId &&
        _conversationsSubscription != null &&
        state.conversationsStatus != ChatLoadStatus.failure) {
      return;
    }

    final generation = ++_conversationGeneration;
    final oldSubscription = _conversationsSubscription;
    _conversationsSubscription = null;
    _watchedUserId = null;
    await oldSubscription?.cancel();
    if (isClosed || generation != _conversationGeneration) return;

    emit(
      state.copyWith(
        conversationsStatus: ChatLoadStatus.loading,
        clearConversationsFailure: true,
      ),
    );
    _watchedUserId = userId;
    try {
      _conversationsSubscription = _chatRepository
          .watchConversations(userId)
          .listen(
            (conversations) {
              if (isClosed || generation != _conversationGeneration) return;
              emit(
                state.copyWith(
                  conversationsStatus: conversations.isEmpty
                      ? ChatLoadStatus.empty
                      : ChatLoadStatus.success,
                  conversations: conversations,
                  clearConversationsFailure: true,
                ),
              );
            },
            onError: (Object error, StackTrace stackTrace) {
              if (isClosed || generation != _conversationGeneration) return;
              _logStreamError('conversation list', error, stackTrace);
              emit(
                state.copyWith(
                  conversationsStatus: ChatLoadStatus.failure,
                  conversationsFailure: _asFailure(error),
                ),
              );
            },
          );
    } catch (error, stackTrace) {
      if (isClosed || generation != _conversationGeneration) return;
      _logStreamError('conversation list subscription', error, stackTrace);
      _watchedUserId = null;
      emit(
        state.copyWith(
          conversationsStatus: ChatLoadStatus.failure,
          conversationsFailure: _asFailure(error),
        ),
      );
    }
  }

  Future<void> watchMessages(String conversationId) async {
    final id = conversationId.trim();
    if (id.isEmpty) {
      emit(
        state.copyWith(
          messagesStatus: ChatLoadStatus.failure,
          messagesFailure: const ValidationFailure(
            message: 'A conversation ID is required to load messages.',
          ),
        ),
      );
      return;
    }
    if (_watchedConversationId == id &&
        _messagesSubscription != null &&
        state.messagesStatus != ChatLoadStatus.failure) {
      return;
    }

    final generation = ++_messageGeneration;
    final oldSubscription = _messagesSubscription;
    _messagesSubscription = null;
    _watchedConversationId = null;
    await oldSubscription?.cancel();
    if (isClosed || generation != _messageGeneration) return;

    emit(
      state.copyWith(
        messagesStatus: ChatLoadStatus.loading,
        activeConversationId: id,
        messages: const [],
        clearMessagesFailure: true,
        clearSendingFailure: true,
        clearActionFailure: true,
      ),
    );
    _watchedConversationId = id;
    try {
      _messagesSubscription = _chatRepository
          .watchMessages(id)
          .listen(
            (messages) {
              if (isClosed || generation != _messageGeneration) return;
              emit(
                state.copyWith(
                  messagesStatus: messages.isEmpty
                      ? ChatLoadStatus.empty
                      : ChatLoadStatus.success,
                  messages: messages,
                  clearMessagesFailure: true,
                ),
              );
            },
            onError: (Object error, StackTrace stackTrace) {
              if (isClosed || generation != _messageGeneration) return;
              _logStreamError('conversation messages', error, stackTrace);
              emit(
                state.copyWith(
                  messagesStatus: ChatLoadStatus.failure,
                  messagesFailure: _asFailure(error),
                ),
              );
            },
          );
    } catch (error, stackTrace) {
      if (isClosed || generation != _messageGeneration) return;
      _logStreamError('message subscription', error, stackTrace);
      _watchedConversationId = null;
      emit(
        state.copyWith(
          messagesStatus: ChatLoadStatus.failure,
          messagesFailure: _asFailure(error),
        ),
      );
    }
  }

  Future<void> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async {
    emit(state.copyWith(clearActionFailure: true));
    final result = await _chatRepository.getOrCreateConversation(
      customerUid: customerUid,
      agentUserUid: agentUserUid,
      agentId: agentId,
      estateId: estateId,
    );
    if (isClosed) return;
    if (result.failure != null || result.data == null) {
      emit(
        state.copyWith(
          actionFailure:
              result.failure ??
              const ServerFailure(message: 'Conversation could not be opened.'),
        ),
      );
      return;
    }
    await watchMessages(result.data!.id);
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    if (state.isSending) return;
    emit(state.copyWith(isSending: true, clearSendingFailure: true));
    final result = await _chatRepository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      text: text,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        isSending: false,
        sendingFailure: result.failure,
        clearSendingFailure: result.failure == null,
      ),
    );
  }

  Future<void> markConversationAsRead({
    required String conversationId,
    required String participantUid,
  }) async {
    emit(state.copyWith(clearActionFailure: true));
    final result = await _chatRepository.markConversationAsRead(
      conversationId: conversationId,
      participantUid: participantUid,
    );
    if (isClosed || result.failure == null) return;
    emit(state.copyWith(actionFailure: result.failure));
  }

  Failure _asFailure(Object error) {
    if (error is Failure) return error;
    // Surface Firestore permission errors as an auth failure so the UI can
    // show a meaningful message rather than a generic server error.
    if (error is FirebaseException && error.code == 'permission-denied') {
      return const AuthFailure(
        message:
            'You do not have permission to view these conversations. Please sign in again.',
      );
    }
    return ServerFailure(message: error.toString());
  }

  void _logStreamError(String source, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('Chat $source stream failed: $error');
    debugPrint('Stack trace:\n$stackTrace');
  }

  @override
  Future<void> close() async {
    ++_conversationGeneration;
    ++_messageGeneration;
    final subscriptions = [?_conversationsSubscription, ?_messagesSubscription];
    _conversationsSubscription = null;
    _messagesSubscription = null;
    await Future.wait(
      subscriptions.map((subscription) => subscription.cancel()),
    );
    await super.close();
  }
}
