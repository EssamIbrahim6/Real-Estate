import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_type.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<NotificationsCubit>().watchNotifications(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.notificationsTitle ?? 'Notifications')),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.initial ||
              state.status == NotificationsStatus.loading) {
            return const NotificationListSkeleton();
          }

          if (state.status == NotificationsStatus.error) {
            return AppErrorView(
              message:
                  state.error ?? (l10n?.commonError ?? 'Something went wrong'),
              onRetry: () {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  context.read<NotificationsCubit>().watchNotifications(uid);
                }
              },
            );
          }

          if (state.notifications.isEmpty) {
            return AppEmptyState(
              icon: Icons.notifications_none_rounded,
              title: l10n?.notificationsEmpty ?? 'No notifications yet',
              description: l10n?.notificationsEmptyDescription ?? "You're all caught up. New property updates will appear here.",
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                context.read<NotificationsCubit>().watchNotifications(uid);
              }
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: state.notifications.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildActivityHeader(context, state);
                final notification = state.notifications[index - 1];
                return NotificationTile(
                  notification: notification,
                  onTap: () => _onNotificationTap(context, notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityHeader(BuildContext context, NotificationsState state) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.notificationsRecentActivity ?? 'Recent activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n?.notificationsUnreadSummary(state.unreadCount) ??
                      '${state.unreadCount} unread',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (state.hasUnread)
                TextButton.icon(
                  onPressed: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      context.read<NotificationsCubit>().markAllAsRead(uid);
                    }
                  },
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: Text(
                    l10n?.notificationsMarkAllRead ?? 'Mark all read',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) {
    // Mark as read
    context.read<NotificationsCubit>().markAsRead(notification.id);

    // Navigate based on entity type
    final entityId = notification.entityId;
    if (entityId == null || entityId.isEmpty) return;

    switch (notification.type) {
      case NotificationType.chatMessage:
        context.pushNamed(
          AppRoutes.chatConversationName,
          pathParameters: {'conversationId': entityId},
        );
      case NotificationType.bookingReceived:
      case NotificationType.bookingStatusChanged:
        context.pushNamed(AppRoutes.myBookingsName);
      case NotificationType.listingStatusChanged:
      case NotificationType.newMatchingProperty:
        context.push('${AppRoutes.propertyDetails}/$entityId');
      case NotificationType.accountCreated:
        // No navigation needed
        break;
    }
  }
}
