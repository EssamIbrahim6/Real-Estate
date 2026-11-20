import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../features/estate/domain/entities/estate_entity.dart';
import '../../domain/entities/chat_launch_request.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../../domain/entities/message_entity.dart';
import '../widgets/conversation_app_bar.dart';
import '../widgets/conversation_estate_card.dart';
import '../widgets/conversation_message_composer.dart';
import '../widgets/conversation_message_list.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.title,
    this.estateId,
    this.currentUserUid,
    this.launchRequest,
  });

  final String conversationId;
  final String title;
  final String? estateId;
  final String? currentUserUid;
  final ChatLaunchRequest? launchRequest;

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
  bool _isDraft = false;
  Object? _lastSendingFailure;
  Object? _lastActionFailure;

  @override
  void initState() {
    super.initState();
    _currentUserUid =
        widget.currentUserUid ?? FirebaseAuth.instance.currentUser?.uid;
    _scrollController.addListener(_updateNearBottom);
    final cubit = context.read<ChatCubit>();
    if (widget.launchRequest == null) {
      cubit.watchMessages(widget.conversationId);
      if (_currentUserUid != null) {
        cubit.markConversationAsRead(
          conversationId: widget.conversationId,
          participantUid: _currentUserUid,
        );
      }
    } else {
      _prepareConversation();
    }
    _loadEstate();
  }

  Future<void> _prepareConversation() async {
    final cubit = context.read<ChatCubit>();
    final conversation = await cubit.loadConversation(widget.conversationId);
    if (!mounted) return;
    if (conversation == null) {
      setState(() => _isDraft = true);
      return;
    }
    await cubit.watchMessages(widget.conversationId);
    final currentUserUid = _currentUserUid;
    if (currentUserUid != null) {
      await cubit.markConversationAsRead(
        conversationId: widget.conversationId,
        participantUid: currentUserUid,
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

  Future<void> _loadEstate() async {
    setState(() => _estateLoading = true);
    try {
      final estate = await context.read<ChatCubit>().loadConversationEstate(
        widget.conversationId,
        fallbackEstateId: widget.estateId,
      );
      if (!mounted) return;
      setState(() => _estate = estate);
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, _safeError(context, error.toString()));
      }
    } finally {
      if (mounted) setState(() => _estateLoading = false);
    }
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
      AppFeedback.error(context, _safeError(context, failure.message));
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
      launchRequest: widget.launchRequest,
    );
    if (!mounted) return;
    final latestState = context.read<ChatCubit>().state;
    if (!latestState.isSending && latestState.sendingFailure == null) {
      _messageController.clear();
      if (_isDraft) {
        setState(() => _isDraft = false);
        await cubit.watchMessages(widget.conversationId);
      }
    }
  }

  Future<void> _deleteMessageForMe(MessageEntity message) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.chatDeleteForMe ?? 'Delete for me'),
        content: Text(
          l10n?.chatDeleteMessageConfirm ??
              'Hide this message from your chat only?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-message-for-me'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n?.chatDeleteForMe ?? 'Delete for me'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || _currentUserUid == null || !mounted) return;
    final success = await context.read<ChatCubit>().deleteMessageForMe(
      conversationId: widget.conversationId,
      messageId: message.id,
      participantUid: _currentUserUid,
    );
    if (!mounted) return;
    if (success) {
      AppFeedback.success(
        context,
        l10n?.chatMessageHiddenForMe ?? 'Message hidden from your chat.',
      );
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
        appBar: ConversationAppBar(
          title: widget.title,
          onBack: () => context.pop(),
        ),
        body: Column(
          children: [
            if (_estateLoading) const LinearProgressIndicator(),
            if (_estate case final estate?)
              ConversationEstateCard(
                estate: estate,
                onTap: () => context.push(
                  '${AppRoutes.propertyDetails}/${estate.id}',
                  extra: estate,
                ),
              ),
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) => ConversationMessageList(
                  status: _isDraft
                      ? ChatLoadStatus.empty
                      : state.messagesStatus,
                  messages: state.messages
                      .where(
                        (message) =>
                            !message.hiddenFor.contains(_currentUserUid),
                      )
                      .toList(growable: false),
                  currentUserUid: _currentUserUid,
                  scrollController: _scrollController,
                  failureMessage: _safeError(
                    context,
                    state.messagesFailure?.message,
                  ),
                  emptyMessage:
                      l10n?.chatNoMessages ??
                      'No messages yet. Start the conversation.',
                  onRetry: () => context.read<ChatCubit>().watchMessages(
                    widget.conversationId,
                  ),
                  onDeleteForMe: _deleteMessageForMe,
                ),
              ),
            ),
            ConversationMessageComposer(
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

String _safeError(BuildContext context, String? message) {
  if (message == null ||
      message.toLowerCase().contains('firebase') ||
      message.toLowerCase().contains('cloud_firestore')) {
    return AppLocalizations.of(context)?.commonError ??
        'Something went wrong. Please try again.';
  }
  return message;
}
