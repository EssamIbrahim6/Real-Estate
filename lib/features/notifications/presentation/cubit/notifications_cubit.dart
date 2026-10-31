import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notification_repository.dart';
import 'notifications_state.dart';

export 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;
  StreamSubscription<dynamic>? _subscription;

  NotificationsCubit({required this.repository})
      : super(const NotificationsState());

  /// Start watching notifications for [uid].
  void watchNotifications(String uid) {
    _subscription?.cancel();
    emit(state.copyWith(status: NotificationsStatus.loading, clearError: true));
    _subscription = repository.watchForUser(uid).listen(
      (notifications) {
        emit(
          state.copyWith(
            status: NotificationsStatus.loaded,
            notifications: notifications,
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: NotificationsStatus.error,
            error: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await repository.markAsRead(notificationId);
    // Optimistically update local state
    final updated = state.notifications.map((n) {
      return n.id == notificationId ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(state.copyWith(notifications: updated));
  }

  Future<void> markAllAsRead(String uid) async {
    await repository.markAllAsRead(uid);
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    emit(state.copyWith(notifications: updated));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
