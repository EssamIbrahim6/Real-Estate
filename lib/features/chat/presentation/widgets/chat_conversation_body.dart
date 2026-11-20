import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/conversation_entity.dart';
import '../cubit/chat_state.dart';
import 'chat_conversation_list.dart';

class ChatConversationBody extends StatelessWidget {
  const ChatConversationBody({
    super.key,
    required this.state,
    required this.currentUserUid,
    required this.onRetry,
    required this.onOpenConversation,
    required this.onArchiveConversation,
  });

  final ChatState state;
  final String currentUserUid;
  final VoidCallback onRetry;
  final ValueChanged<ConversationEntity> onOpenConversation;
  final Future<bool> Function(ConversationEntity conversation)
  onArchiveConversation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (state.conversationsStatus) {
      case ChatLoadStatus.initial:
      case ChatLoadStatus.loading:
        return const ChatListSkeleton();
      case ChatLoadStatus.failure:
        return AppErrorView(
          message:
              l10n?.chatLoadError ??
              'Could not load conversations. Please try again.',
          onRetry: onRetry,
        );
      case ChatLoadStatus.empty:
        return _EmptyConversations(
          title: l10n?.chatEmptyTitle ?? 'No conversations yet',
          description:
              l10n?.chatEmptyMessage ??
              'Start a conversation with an agent from a property.',
        );
      case ChatLoadStatus.success:
        if (state.conversations.isEmpty) {
          return _EmptyConversations(
            title: l10n?.chatEmptyTitle ?? 'No conversations yet',
            description:
                l10n?.chatEmptyMessage ??
                'Start a conversation with an agent from a property.',
          );
        }
        return ChatConversationList(
          conversations: state.conversations,
          currentUserUid: currentUserUid,
          onConversationTap: onOpenConversation,
          onArchiveConversation: onArchiveConversation,
          inquiryLabel: l10n?.chatInquiry ?? 'Property inquiry',
          estatePreviews: state.estatePreviews,
          participantPreviews: state.participantPreviews,
        );
    }
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    icon: Icons.chat_bubble_outline_rounded,
    title: title,
    description: description,
  );
}
