import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../features/estate/domain/entities/estate_entity.dart';
import '../../../../features/estate/domain/repositories/estate_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../../domain/entities/message_entity.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.title,
    this.estateId,
    this.currentUserUid,
  });

  final String conversationId;
  final String title;
  final String? estateId;
  final String? currentUserUid;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final String? _currentUserUid;
  EstateEntity? _estate;
  bool _estateLoading = false;
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
    _loadEstate();
  }

  void _updateNearBottom() {
    if (!_scrollController.hasClients) return;
    _isNearBottom =
        _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <
        120;
  }

  Future<void> _loadEstate() async {
    final estateId = widget.estateId?.trim();
    if (estateId == null || estateId.isEmpty) return;
    setState(() => _estateLoading = true);
    final result = await sl<EstateRepository>().getEstateById(estateId);
    if (!mounted) return;
    setState(() {
      _estate = result.data;
      _estateLoading = false;
    });
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
      AppFeedback.error(context, _safeError(failure.message));
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
    final l10n = AppLocalizations.of(context);
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.sendingFailure != current.sendingFailure ||
          previous.actionFailure != current.actionFailure ||
          previous.messages.length != current.messages.length,
      listener: _onChatStateChanged,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.1),
                child: Icon(
                  Icons.support_agent_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_estateLoading) const LinearProgressIndicator(),
            if (_estate != null) _EstateMentionHeader(estate: _estate!),
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
                      return _NoMessagesState(
                        message:
                            l10n?.chatNoMessages ??
                            'No messages yet. Start the conversation.',
                      );
                    case ChatLoadStatus.success:
                      if (state.messages.isEmpty) {
                        return _NoMessagesState(
                          message:
                              l10n?.chatNoMessages ??
                              'No messages yet. Start the conversation.',
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

class _NoMessagesState extends StatelessWidget {
  const _NoMessagesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 34,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: colors.onSurfaceVariant, height: 1.45),
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
        ? colorScheme.primary
        : colorScheme.surfaceContainerHigh;
    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;

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
              boxShadow: [
                if (isMine)
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
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
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
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
                      ? (l10n?.chatMessageHint ?? 'Write a message...')
                      : (l10n?.chatSignInToSend ?? 'Sign in to send a message'),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) =>
                  previous.isSending != current.isSending,
              builder: (context, state) => IconButton.filled(
                key: const ValueKey<String>('send-message'),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor: colors.surfaceContainerHigh,
                  disabledForegroundColor: colors.onSurfaceVariant,
                ),
                onPressed: enabled && !state.isSending ? () => onSend() : null,
                icon: state.isSending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                tooltip: l10n?.chatSendTooltip ?? 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstateMentionHeader extends StatelessWidget {
  const _EstateMentionHeader({required this.estate});

  final EstateEntity estate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;
    final title = estate.localizedTitle(langCode);
    final address = estate.location.localizedAddress(langCode);
    return InkWell(
      onTap: () => context.push(
        '${AppRoutes.propertyDetails}/${estate.id}',
        extra: estate,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                estate.coverImage,
                width: 66,
                height: 66,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 66,
                  height: 66,
                  color: colors.surfaceContainerHighest,
                  child: const Icon(Icons.home_work_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${estate.price.toInt()} EGP',
                    style: TextStyle(
                      color: colors.tertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (address.isNotEmpty)
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
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
