import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
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
      appBar: AppBar(
        title: Text(l10n?.notificationsTitle ?? 'Notifications'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (!state.hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    context.read<NotificationsCubit>().markAllAsRead(uid);
                  }
                },
                child: Text(l10n?.notificationsMarkAllRead ?? 'Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.initial ||
              state.status == NotificationsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationsStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.error ??
                          (l10n?.commonError ?? 'Something went wrong'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          context
                              .read<NotificationsCubit>()
                              .watchNotifications(uid);
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n?.commonRetry ?? 'Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 56,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.notificationsEmpty ?? 'No notifications yet.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                context.read<NotificationsCubit>().watchNotifications(uid);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
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

