import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/conversation_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_conversation_body.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.currentUserUid});

  final String? currentUserUid;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String? _currentUserUid;

  @override
  void initState() {
    super.initState();
    final uid =
        (widget.currentUserUid ?? FirebaseAuth.instance.currentUser?.uid)
            ?.trim();
    _currentUserUid = uid != null && uid.isNotEmpty ? uid : null;
    if (_currentUserUid != null) {
      context.read<ChatCubit>().watchConversations(_currentUserUid);
    }
  }

  void _openConversation(
    BuildContext context,
    String currentUserUid,
    ConversationEntity conversation,
  ) {
    final l10n = AppLocalizations.of(context);
    final title = conversation.customerId == currentUserUid
        ? (l10n?.chatAgentLabel ?? 'Agent')
        : (l10n?.chatCustomerLabel ?? 'Customer');
    context.pushNamed(
      AppRoutes.chatConversationName,
      pathParameters: {'conversationId': conversation.id},
      queryParameters: {
        'title': title,
        if (conversation.estateId?.trim().isNotEmpty == true)
          'estateId': conversation.estateId!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: ChatAppBar(title: l10n?.navChat ?? 'Chat'),
      body: _currentUserUid == null
          ? _ChatAuthenticationRequired(
              message:
                  l10n?.chatAuthRequired ??
                  'Sign in to view your conversations.',
            )
          : BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) => ChatConversationBody(
                state: state,
                currentUserUid: _currentUserUid,
                onRetry: () => context.read<ChatCubit>().watchConversations(
                  _currentUserUid,
                ),
                onOpenConversation: (conversation) =>
                    _openConversation(context, _currentUserUid, conversation),
                onArchiveConversation: (conversation) =>
                    _archiveConversation(context, conversation),
              ),
            ),
    );
  }

  Future<bool> _archiveConversation(
    BuildContext context,
    ConversationEntity conversation,
  ) async {
    final success = await context.read<ChatCubit>().archiveConversation(
      conversationId: conversation.id,
      participantUid: _currentUserUid!,
    );
    if (!context.mounted) return false;
    final l10n = AppLocalizations.of(context);
    if (success) {
      AppFeedback.success(
        context,
        l10n?.chatConversationArchived ?? 'Conversation archived.',
      );
    } else {
      AppFeedback.error(
        context,
        l10n?.chatArchiveFailed ?? 'Conversation could not be archived.',
      );
    }
    return success;
  }
}

class _ChatAuthenticationRequired extends StatelessWidget {
  const _ChatAuthenticationRequired({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(message, textAlign: TextAlign.center));
}
