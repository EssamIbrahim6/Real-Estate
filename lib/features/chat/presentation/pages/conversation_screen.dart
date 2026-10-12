import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../../domain/entities/message_entity.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.title,
    this.currentUserUid,
  });

  final String conversationId;
  final String title;
  final String? currentUserUid;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final String? _currentUserUid;
  int _previousMessageCount = 0;
  bool _isNearBottom = true;
  Object? _lastSendingFailure;
  Object? _lastActionFailure;

  @override
  void initState() {
    super.initState();
    _currentUserUid =
        widget.currentUserUid ?? FirebaseAuth.instance.currentUser?.uid;
    _scrollController.addListener(_updateNearBottom);
    final cubit = context.read<ChatCubit>();
    cubit.watchMessages(widget.conversationId);
    if (_currentUserUid != null) {
      cubit.markConversationAsRead(
        conversationId: widget.conversationId,
        participantUid: _currentUserUid,
      );
    }
  }

  void _updateNearBottom() {
    if (!_scrollController.hasClients) return;
    _isNearBottom =
        _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <
        120;
  }

  void _onChatStateChanged(BuildContext context, ChatState state) {
    final newCount = state.messages.length;
    final shouldScroll = newCount > _previousMessageCount && _isNearBottom;
    _previousMessageCount = newCount;
    if (shouldScroll) _scrollToLatest();

    final sendingFailureChanged = _lastSendingFailure != state.sendingFailure;
    final actionFailureChanged = _lastActionFailure != state.actionFailure;
    final failure = sendingFailureChanged
        ? state.sendingFailure
        : actionFailureChanged
        ? state.actionFailure
        : null;
    _lastSendingFailure = state.sendingFailure;
    _lastActionFailure = state.actionFailure;
    if (failure != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_safeError(failure.message))));
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final senderId = _currentUserUid;
    if (text.isEmpty || senderId == null) return;

    final cubit = context.read<ChatCubit>();
    if (cubit.state.isSending) return;
    await cubit.sendMessage(
      conversationId: widget.conversationId,
      senderId: senderId,
      text: text,
    );
    if (!mounted) return;
    final latestState = context.read<ChatCubit>().state;
    if (!latestState.isSending && latestState.sendingFailure == null) {
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateNearBottom)
      ..dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.sendingFailure != current.sendingFailure ||
          previous.actionFailure != current.actionFailure ||
          previous.messages.length != current.messages.length,
      listener: _onChatStateChanged,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  switch (state.messagesStatus) {
                    case ChatLoadStatus.initial:
                    case ChatLoadStatus.loading:
                      return const AppLoadingIndicator();
                    case ChatLoadStatus.failure:
                      return AppErrorView(
                        message: _safeError(state.messagesFailure?.message),
                        onRetry: () => context.read<ChatCubit>().watchMessages(
                          widget.conversationId,
                        ),
                      );
                    case ChatLoadStatus.empty:
                      return const Center(
                        child: Text('No messages yet. Start the conversation.'),
                      );
                    case ChatLoadStatus.success:
                      if (state.messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'No messages yet. Start the conversation.',
                          ),
                        );
                      }
                      return ListView.builder(
                        key: const PageStorageKey<String>('chat-messages'),
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) => _MessageBubble(
                          message: state.messages[index],
                          isMine:
                              state.messages[index].senderId == _currentUserUid,
                        ),
                      );
                  }
                },
              ),
            ),
            _MessageComposer(
              controller: _messageController,
              enabled: _currentUserUid != null,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final MessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isMine
        ? AppColors.primary
        : colorScheme.surfaceContainerHighest;
    final textColor = isMine ? Colors.white : colorScheme.onSurface;

    return Semantics(
      label: isMine ? 'sent message' : 'received message',
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Container(
            key: ValueKey<String>('message-${message.id}'),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    message.text,
                    softWrap: true,
                    style: TextStyle(color: textColor, height: 1.35),
                  ),
                ),
                if (message.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    TimeOfDay.fromDateTime(message.createdAt!.toLocal())
                        .format(context),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: textColor.withAlpha(190)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey<String>('message-composer'),
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: enabled
                        ? 'Write a message...'
                        : 'Sign in to send a message',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<ChatCubit, ChatState>(
                buildWhen: (previous, current) =>
                    previous.isSending != current.isSending,
                builder: (context, state) => IconButton.filled(
                  key: const ValueKey<String>('send-message'),
                  onPressed: enabled && !state.isSending
                      ? () => onSend()
                      : null,
                  icon: state.isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  tooltip: 'Send message',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _safeError(String? message) {
  if (message == null ||
      message.toLowerCase().contains('firebase') ||
      message.toLowerCase().contains('cloud_firestore')) {
    return 'Something went wrong. Please try again.';
  }
  return message;
}
