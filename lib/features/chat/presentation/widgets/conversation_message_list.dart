import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../domain/entities/message_entity.dart';
import '../cubit/chat_state.dart';
import 'conversation_message_bubble.dart';
import 'message_date_separator.dart';
import 'no_messages_placeholder.dart';

class ConversationMessageList extends StatelessWidget {
  const ConversationMessageList({
    super.key,
    required this.status,
    required this.messages,
    required this.currentUserUid,
    required this.scrollController,
    required this.failureMessage,
    required this.emptyMessage,
    required this.onRetry,
    this.onDeleteForMe,
  });

  final ChatLoadStatus status;
  final List<MessageEntity> messages;
  final String? currentUserUid;
  final ScrollController scrollController;
  final String failureMessage;
  final String emptyMessage;
  final VoidCallback onRetry;
  final void Function(MessageEntity message)? onDeleteForMe;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChatLoadStatus.initial:
      case ChatLoadStatus.loading:
        return const MessageListSkeleton();
      case ChatLoadStatus.failure:
        return AppErrorView(message: failureMessage, onRetry: onRetry);
      case ChatLoadStatus.empty:
        return NoMessagesPlaceholder(message: emptyMessage);
      case ChatLoadStatus.success:
        if (messages.isEmpty) {
          return NoMessagesPlaceholder(message: emptyMessage);
        }
        return ListView.builder(
          key: const PageStorageKey<String>('chat-messages'),
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final messageDate = message.createdAt?.toLocal();
            final previousDate = index == 0
                ? null
                : messages[index - 1].createdAt?.toLocal();
            final showDate =
                messageDate != null &&
                !_sameCalendarDay(messageDate, previousDate);
            final dateLabel = showDate
                ? DateFormat.yMMMd(Localizations.localeOf(context).toString())
                      .format(messageDate)
                : null;

            return Column(
              children: [
                if (dateLabel != null)
                  MessageDateSeparator(
                    key: ValueKey<String>(
                      'chat-date-${messageDate?.year}-${messageDate?.month}-${messageDate?.day}',
                    ),
                    label: dateLabel,
                  ),
                GestureDetector(
                  key: ValueKey<String>('message-action-${message.id}'),
                  onLongPress: onDeleteForMe == null
                      ? null
                      : () => onDeleteForMe!(message),
                  child: ConversationMessageBubble(
                    message: message,
                    isMine: message.senderId == currentUserUid,
                  ),
                ),
              ],
            );
          },
        );
    }
  }
}

bool _sameCalendarDay(DateTime first, DateTime? second) =>
    second != null &&
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
