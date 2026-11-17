import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_type.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unread = !notification.isRead;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unread
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant,
        ),
        boxShadow: [
          if (unread)
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unread) ...[
                  Container(
                    width: 4,
                    height: 54,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                _NotificationIcon(type: notification.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: colors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(context, notification.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: unread
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: unread ? FontWeight.w700 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return l10n?.notificationsJustNow ?? 'Just now';
    }
    if (difference.inHours < 1) {
      return l10n?.notificationsMinutesAgo(difference.inMinutes) ??
          '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return l10n?.notificationsHoursAgo(difference.inHours) ??
          '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) {
      return '${l10n?.notificationsYesterday ?? 'Yesterday'} · ${DateFormat.jm(locale).format(dateTime)}';
    }
    if (difference.inDays < 7) {
      return l10n?.notificationsDaysAgo(difference.inDays) ??
          '${difference.inDays}d ago';
    }
    return DateFormat.yMMMd(locale).format(dateTime);
  }
}

class _NotificationIcon extends StatelessWidget {
  final NotificationType type;
  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, color) = switch (type) {
      NotificationType.accountCreated => (
        Icons.person_add_alt_1_rounded,
        colors.primary,
      ),
      NotificationType.chatMessage => (
        Icons.chat_bubble_rounded,
        colors.secondary,
      ),
      NotificationType.bookingReceived => (
        Icons.calendar_month_rounded,
        colors.tertiary,
      ),
      NotificationType.bookingStatusChanged => (
        Icons.event_available_rounded,
        colors.primary,
      ),
      NotificationType.listingStatusChanged => (
        Icons.home_work_rounded,
        colors.secondary,
      ),
      NotificationType.newMatchingProperty => (
        Icons.auto_awesome_rounded,
        colors.tertiary,
      ),
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}
