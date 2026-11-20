import 'package:flutter/material.dart';

import '../../../../core/widgets/person_avatar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/chat_participant.dart';

class ConversationParticipantInfo extends StatelessWidget {
  const ConversationParticipantInfo({
    super.key,
    required this.isUnread,
    required this.isCustomer,
    this.participant,
  });

  final bool isUnread;
  final bool isCustomer;
  final ChatParticipant? participant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final fallbackName = isCustomer
        ? (l10n?.chatAgentLabel ?? 'Agent')
        : (l10n?.chatCustomerLabel ?? 'Customer');
    final participantName = participant?.name.trim() ?? '';
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            PersonAvatar(
              photoUrl: participant?.photoUrl,
              radius: 27,
              iconSize: 25,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              iconColor: colors.primary,
            ),
            if (isUnread)
              PositionedDirectional(
                end: -1,
                top: -1,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: colors.tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            participantName.isNotEmpty ? participantName : fallbackName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
