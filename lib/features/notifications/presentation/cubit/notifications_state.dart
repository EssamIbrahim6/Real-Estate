import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final String? error;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, notifications, error];
}

