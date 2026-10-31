import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_type.dart';
import 'package:real_estate_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:real_estate_app/features/notifications/presentation/cubit/notifications_cubit.dart';

class _FakeNotificationRepository implements NotificationRepository {
  final _streamController = StreamController<List<NotificationEntity>>.broadcast();
  List<NotificationEntity> notifications = [];
  final List<String> markedReadIds = [];
  bool markAllCalled = false;

  void emitNotifications(List<NotificationEntity> items) {
    notifications = items;
    _streamController.add(items);
  }

  void emitError(Object error) {
    _streamController.addError(error);
  }

  @override
  ResultVoid createNotification(NotificationEntity notification) async {
    notifications.add(notification);
    _streamController.add(notifications);
    return (failure: null, isSuccess: true);
  }

  @override
  Stream<List<NotificationEntity>> watchForUser(String uid) {
    return _streamController.stream;
  }

  @override
  ResultVoid markAsRead(String notificationId) async {
    markedReadIds.add(notificationId);
    notifications = notifications.map((n) {
      return n.id == notificationId ? n.copyWith(isRead: true) : n;
    }).toList();
    _streamController.add(notifications);
    return (failure: null, isSuccess: true);
  }

  @override
  ResultVoid markAllAsRead(String uid) async {
    markAllCalled = true;
    notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
    _streamController.add(notifications);
    return (failure: null, isSuccess: true);
  }

  @override
  Future<int> getUnreadCount(String uid) async {
    return notifications.where((n) => !n.isRead).length;
  }

  void dispose() {
    _streamController.close();
  }
}

void main() {
  late _FakeNotificationRepository repository;
  late NotificationsCubit cubit;

  final testNotification1 = NotificationEntity(
    id: 'n1',
    recipientId: 'u1',
    type: NotificationType.chatMessage,
    title: 'Chat message',
    body: 'How are you?',
    createdAt: DateTime(2026, 10, 29),
    isRead: false,
    entityType: 'conversation',
    entityId: 'c1',
  );

  final testNotification2 = NotificationEntity(
    id: 'n2',
    recipientId: 'u1',
    type: NotificationType.bookingReceived,
    title: 'New booking',
    body: 'Visit scheduled',
    createdAt: DateTime(2026, 10, 29),
    isRead: false,
    entityType: 'booking',
    entityId: 'b1',
  );

  setUp(() {
    repository = _FakeNotificationRepository();
    cubit = NotificationsCubit(repository: repository);
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  group('NotificationsCubit', () {
    test('initial state has initial status and empty notifications', () {
      expect(cubit.state.status, NotificationsStatus.initial);
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.hasUnread, false);
    });

    test('watchNotifications emits loading and then loaded on stream event', () async {
      final states = <NotificationsState>[];
      cubit.stream.listen(states.add);

      cubit.watchNotifications('u1');
      expect(cubit.state.status, NotificationsStatus.loading);

      repository.emitNotifications([testNotification1, testNotification2]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, NotificationsStatus.loaded);
      expect(cubit.state.notifications.length, 2);
      expect(cubit.state.unreadCount, 2);
      expect(cubit.state.hasUnread, true);
    });

    test('watchNotifications handles stream error', () async {
      cubit.watchNotifications('u1');
      repository.emitError(const ServerFailure(message: 'Permission denied'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, NotificationsStatus.error);
      expect(cubit.state.error, contains('Permission denied'));
    });

    test('markAsRead updates item to isRead = true', () async {
      cubit.watchNotifications('u1');
      repository.emitNotifications([testNotification1, testNotification2]);
      await Future<void>.delayed(Duration.zero);

      await cubit.markAsRead('n1');

      expect(repository.markedReadIds, contains('n1'));
      final updatedN1 = cubit.state.notifications.firstWhere((n) => n.id == 'n1');
      expect(updatedN1.isRead, true);
      expect(cubit.state.unreadCount, 1);
    });

    test('markAllAsRead marks all notifications as read', () async {
      cubit.watchNotifications('u1');
      repository.emitNotifications([testNotification1, testNotification2]);
      await Future<void>.delayed(Duration.zero);

      await cubit.markAllAsRead('u1');

      expect(repository.markAllCalled, true);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.hasUnread, false);
    });
  });
}

