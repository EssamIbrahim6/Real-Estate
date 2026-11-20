import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/message_entity.dart';

class ConversationMessageBubble extends StatelessWidget {
  const ConversationMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final MessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final bubbleColor = isMine
        ? colorScheme.primary
        : colorScheme.surfaceContainerHigh;
    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;

    return Semantics(
      label: isMine
          ? (l10n?.chatSentMessageSemantics ?? 'Sent message')
          : (l10n?.chatReceivedMessageSemantics ?? 'Received message'),
      child: Align(
        alignment: isMine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
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
              borderRadius: BorderRadiusDirectional.only(
                topStart: const Radius.circular(18),
                topEnd: const Radius.circular(18),
                bottomStart: Radius.circular(isMine ? 18 : 4),
                bottomEnd: Radius.circular(isMine ? 4 : 18),
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
