import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../account_setup/domain/repositories/account_setup_repository.dart';
import '../../../agent/domain/repositories/agent_repository.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../../estate/domain/repositories/estate_repository.dart';
import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/chat_launch_request.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  late final ChatRepository _chatRepository;
  late final EstateRepository? _estateRepository;
  late final AgentRepository? _agentRepository;
  late final AccountSetupRepository? _profileRepository;
  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  String? _watchedUserId;
  String? _watchedConversationId;
  int _conversationGeneration = 0;
  int _messageGeneration = 0;
  final Set<String> _loadingPreviewIds = {};
  final Set<String> _pendingArchives = {};
  final Set<String> _pendingMessageDeletes = {};
  String? _previewUserId;

  ChatCubit({
    required ChatRepository chatRepository,
    EstateRepository? estateRepository,
    AgentRepository? agentRepository,
    AccountSetupRepository? profileRepository,
  }) : super(const ChatState()) {
    _chatRepository = chatRepository;
    _estateRepository = estateRepository;
    _agentRepository = agentRepository;
    _profileRepository = profileRepository;
  }

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
    final userChanged = _previewUserId != userId;
    _previewUserId = userId;
    _conversationsSubscription = null;
    _watchedUserId = null;
    await oldSubscription?.cancel();
    if (isClosed || generation != _conversationGeneration) return;

    emit(
      state.copyWith(
        conversationsStatus: ChatLoadStatus.loading,
        clearConversationsFailure: true,
        estatePreviews: userChanged ? const {} : state.estatePreviews,
        participantPreviews: userChanged ? const {} : state.participantPreviews,
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
              unawaited(
                _loadConversationPreviews(conversations, userId, generation),
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

  Future<ConversationEntity?> loadConversation(String conversationId) async {
    emit(state.copyWith(clearActionFailure: true));
    final result = await _chatRepository.getConversation(conversationId);
    if (isClosed) return null;
    if (result.failure != null) {
      emit(
        state.copyWith(
          actionFailure:
              result.failure ??
              const ServerFailure(message: 'Conversation could not be loaded.'),
        ),
      );
      return null;
    }
    if (result.data == null) {
      emit(state.copyWith(clearActionFailure: true));
      return null;
    }
    return result.data;
  }

  Future<EstateEntity?> loadConversationEstate(
    String conversationId, {
    String? fallbackEstateId,
  }) async {
    final conversation = await loadConversation(conversationId);
    final persistedEstateId = conversation?.estateId?.trim();
    final routeEstateId = fallbackEstateId?.trim();
    final estateId = persistedEstateId?.isNotEmpty == true
        ? persistedEstateId
        : routeEstateId;
    if (estateId == null || estateId.isEmpty) {
      return null;
    }
    return _loadEstatePreview(conversationId, estateId);
  }

  Future<void> _loadConversationPreviews(
    List<ConversationEntity> conversations,
    String currentUserUid,
    int generation,
  ) async {
    if (!_isCurrentPreviewRequest(generation, currentUserUid)) return;
    await Future.wait(
      conversations.map((conversation) async {
        if (!_isCurrentPreviewRequest(generation, currentUserUid)) return;
        final loadKey = '$currentUserUid:${conversation.id}';
        if (!_loadingPreviewIds.add(loadKey)) return;
        try {
          final estateId = conversation.estateId?.trim();
          final tasks = <Future<void>>[];
          if (estateId?.isNotEmpty == true &&
              !state.estatePreviews.containsKey(conversation.id)) {
            tasks.add(
              _loadEstatePreview(
                conversation.id,
                estateId!,
                expectedGeneration: generation,
                expectedUserId: currentUserUid,
              ).then((_) {}),
            );
          }
          if (!state.participantPreviews.containsKey(conversation.id)) {
            tasks.add(
              _loadParticipantPreview(
                conversation,
                currentUserUid,
                expectedGeneration: generation,
              ),
            );
          }
          await Future.wait(tasks);
        } finally {
          _loadingPreviewIds.remove(loadKey);
        }
      }),
    );
  }

  Future<EstateEntity?> _loadEstatePreview(
    String conversationId,
    String estateId, {
    int? expectedGeneration,
    String? expectedUserId,
  }) async {
    final repository = _estateRepository;
    if (repository == null) return null;
    final result = await repository.getEstateById(estateId);
    if (isClosed) return null;
    if (expectedGeneration != null &&
        expectedUserId != null &&
        !_isCurrentPreviewRequest(expectedGeneration, expectedUserId)) {
      return null;
    }
    if (result.failure != null || result.data == null) {
      _logPreviewFailure(
        'estate preview',
        result.failure?.message ?? 'Estate $estateId was not found.',
      );
      return null;
    }
    final estate = result.data!;
    emit(
      state.copyWith(
        estatePreviews: {...state.estatePreviews, conversationId: estate},
      ),
    );
    return estate;
  }

  Future<void> _loadParticipantPreview(
    ConversationEntity conversation,
    String currentUserUid, {
    required int expectedGeneration,
  }) async {
    try {
      final ChatParticipant? participant;
      if (conversation.customerId == currentUserUid) {
        final repository = _agentRepository;
        if (repository == null) return;
        final result = await repository.getAgentById(conversation.agentId);
        if (result.failure != null || result.data == null) {
          _logPreviewFailure(
            'agent preview',
            result.failure?.message ??
                'Agent ${conversation.agentId} was not found.',
          );
          return;
        }
        participant = ChatParticipant(
          name: result.data!.displayName,
          photoUrl: result.data!.primaryPhotoUrl,
        );
      } else {
        final repository = _profileRepository;
        if (repository == null) return;
        final result = await repository.getProfile(conversation.customerId);
        if (result.failure != null || result.data == null) {
          _logPreviewFailure(
            'customer preview',
            result.failure?.message ??
                'Customer ${conversation.customerId} was not found.',
          );
          return;
        }
        final profile = result.data!;
        participant = ChatParticipant(
          name: profile.name.trim().isNotEmpty ? profile.name.trim() : '',
          photoUrl: profile.profileImageUrl,
        );
      }
      if (!_isCurrentPreviewRequest(expectedGeneration, currentUserUid)) return;
      emit(
        state.copyWith(
          participantPreviews: {
            ...state.participantPreviews,
            conversation.id: participant,
          },
        ),
      );
    } catch (error, stackTrace) {
      _logPreviewFailure('participant preview', error, stackTrace);
    }
  }

  bool _isCurrentPreviewRequest(int generation, String userId) =>
      !isClosed &&
      generation == _conversationGeneration &&
      _watchedUserId == userId &&
      _previewUserId == userId;

  void _logPreviewFailure(
    String source,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;
    debugPrint('Chat $source failed: $error');
    if (stackTrace != null) debugPrint('Stack trace:\n$stackTrace');
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    ChatLaunchRequest? launchRequest,
  }) async {
    if (state.isSending) return;
    emit(state.copyWith(isSending: true, clearSendingFailure: true));
    final result = await _chatRepository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      launchRequest: launchRequest,
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

  Future<bool> archiveConversation({
    required String conversationId,
    required String participantUid,
  }) async {
    final requestKey = '$participantUid:$conversationId';
    if (!_pendingArchives.add(requestKey)) return false;
    emit(state.copyWith(clearActionFailure: true));
    try {
      final result = await _chatRepository.archiveConversation(
        conversationId: conversationId,
        participantUid: participantUid,
      );
      if (isClosed) return false;
      if (result.failure != null || !result.isSuccess) {
        emit(
          state.copyWith(
            actionFailure:
                result.failure ??
                const ServerFailure(
                  message: 'Conversation could not be archived.',
                ),
          ),
        );
        return false;
      }
      return true;
    } finally {
      _pendingArchives.remove(requestKey);
    }
  }

  Future<bool> deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String participantUid,
  }) async {
    final requestKey = '$conversationId:$messageId:$participantUid';
    if (!_pendingMessageDeletes.add(requestKey)) return false;
    emit(state.copyWith(clearActionFailure: true));
    try {
      final result = await _chatRepository.deleteMessageForMe(
        conversationId: conversationId,
        messageId: messageId,
        participantUid: participantUid,
      );
      if (isClosed) return false;
      if (result.failure != null || !result.isSuccess) {
        emit(
          state.copyWith(
            actionFailure:
                result.failure ??
                const ServerFailure(message: 'Message could not be hidden.'),
          ),
        );
        return false;
      }
      return true;
    } finally {
      _pendingMessageDeletes.remove(requestKey);
    }
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
    if (error is FirebaseException && error.code == 'permission-denied') {
      return const ServerFailure(
        message: 'You do not have permission to access this chat.',
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
