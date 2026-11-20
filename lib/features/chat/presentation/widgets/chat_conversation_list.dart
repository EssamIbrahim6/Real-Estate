import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../estate/domain/entities/estate_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/conversation_entity.dart';
import 'conversation_estate_preview.dart';
import 'conversation_participant_info.dart';

class ChatConversationList extends StatelessWidget {
  const ChatConversationList({
    super.key,
    required this.conversations,
    required this.currentUserUid,
    required this.onConversationTap,
    required this.onArchiveConversation,
    required this.inquiryLabel,
    required this.estatePreviews,
    required this.participantPreviews,
  });

  final List<ConversationEntity> conversations;
  final String currentUserUid;
  final ValueChanged<ConversationEntity> onConversationTap;
  final Future<bool> Function(ConversationEntity conversation)
  onArchiveConversation;
  final String inquiryLabel;
  final Map<String, EstateEntity> estatePreviews;
  final Map<String, ChatParticipant> participantPreviews;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    itemCount: conversations.length,
    separatorBuilder: (_, _) => const SizedBox(height: 4),
    itemBuilder: (context, index) {
      final conversation = conversations[index];
      return _ConversationCard(
        key: ValueKey<String>('conversation-${conversation.id}'),
        conversation: conversation,
        currentUserUid: currentUserUid,
        onTap: () => onConversationTap(conversation),
        inquiryLabel: inquiryLabel,
        estate: estatePreviews[conversation.id],
        participant: participantPreviews[conversation.id],
        onArchive: () => onArchiveConversation(conversation),
      );
    },
  );
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    super.key,
    required this.conversation,
    required this.currentUserUid,
    required this.onTap,
    required this.inquiryLabel,
    required this.estate,
    required this.participant,
    required this.onArchive,
  });

  final ConversationEntity conversation;
  final String currentUserUid;
  final VoidCallback onTap;
  final String inquiryLabel;
  final EstateEntity? estate;
  final ChatParticipant? participant;
  final Future<bool> Function() onArchive;

  @override
  Widget build(BuildContext context) {
    final isCustomer = conversation.customerId == currentUserUid;
    final readAt = conversation.lastReadAtByParticipant[currentUserUid];
    final isUnread =
        conversation.lastMessage != null &&
        conversation.lastSenderId != currentUserUid &&
        (readAt == null ||
            (conversation.lastMessageAt != null &&
                conversation.lastMessageAt!.isAfter(readAt)));
    final hasEstate = conversation.estateId?.trim().isNotEmpty == true;
    final colors = Theme.of(context).colorScheme;

    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: ValueKey<String>('dismissible-${conversation.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onArchive(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: AlignmentDirectional.centerEnd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined, color: colors.onPrimaryContainer),
            const SizedBox(height: 4),
            Text(
              l10n?.chatArchiveConversation ?? 'Archive',
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ],
        ),
      ),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isUnread
                    ? colors.primary.withValues(alpha: 0.4)
                    : colors.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ConversationParticipantInfo(
                        isUnread: isUnread,
                        isCustomer: isCustomer,
                        participant: participant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatConversationTime(
                        conversation.lastMessageAt,
                        context,
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isUnread
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (hasEstate) ...[
                      Icon(
                        Icons.home_work_outlined,
                        size: 15,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        conversation.lastMessage ?? inquiryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUnread
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasEstate) ...[
                  const SizedBox(height: 10),
                  if (estate case final value?)
                    ConversationEstatePreview(estate: value)
                  else
                    const _EstatePreviewLoading(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstatePreviewLoading extends StatelessWidget {
  const _EstatePreviewLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.home_work_outlined,
        color: colors.onSurfaceVariant,
        size: 22,
      ),
    );
  }
}

String _formatConversationTime(DateTime? timestamp, BuildContext context) {
  if (timestamp == null) return '';
  final now = DateTime.now();
  final localTime = timestamp.toLocal();
  if (now.year == localTime.year &&
      now.month == localTime.month &&
      now.day == localTime.day) {
    return TimeOfDay.fromDateTime(localTime).format(context);
  }
  return DateFormat.yMd(Localizations.localeOf(context).toString())
      .format(localTime);
}
