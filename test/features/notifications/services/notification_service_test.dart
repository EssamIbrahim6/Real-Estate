import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/services/notification_service.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_type.dart';
import 'package:real_estate_app/features/notifications/domain/repositories/notification_repository.dart';

class _FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> created = [];

  @override
  ResultVoid createNotification(NotificationEntity notification) async {
    created.add(notification);
    return (failure: null, isSuccess: true);
  }

  @override
  Stream<List<NotificationEntity>> watchForUser(String uid) {
    return const Stream.empty();
  }

  @override
  ResultVoid markAsRead(String notificationId) async {
    return (failure: null, isSuccess: true);
  }

  @override
  ResultVoid markAllAsRead(String uid) async {
    return (failure: null, isSuccess: true);
  }

  @override
  Future<int> getUnreadCount(String uid) async {
    return 0;
  }
}

void main() {
  late _FakeNotificationRepository repository;
  late NotificationService service;

  setUp(() {
    repository = _FakeNotificationRepository();
    service = NotificationService(repository);
  });

  group('NotificationService', () {
    test('notifyAccountCreated sends accountCreated notification', () async {
      await service.notifyAccountCreated(uid: 'user_123');

      expect(repository.created.length, 1);
      final item = repository.created.first;
      expect(item.recipientId, 'user_123');
      expect(item.type, NotificationType.accountCreated);
      expect(item.deduplicationKey, 'account_created_user_123');
    });

    test('notifyChatMessage sends chatMessage notification with preview', () async {
      await service.notifyChatMessage(
        messageId: 'msg_99',
        recipientId: 'agent_user_1',
        senderName: 'Jane',
        conversationId: 'conv_42',
        messagePreview: 'Is the apartment still available for rent?',
      );

      expect(repository.created.length, 1);
      final item = repository.created.first;
      expect(item.recipientId, 'agent_user_1');
      expect(item.type, NotificationType.chatMessage);
      expect(item.entityType, 'conversation');
      expect(item.entityId, 'conv_42');
      expect(item.deduplicationKey, 'chat_msg_msg_99');
      expect(item.title, 'New message from Jane');
      expect(item.body, 'Is the apartment still available for rent?');
    });

    test('notifyBookingReceived notifies agent with booking details', () async {
      await service.notifyBookingReceived(
        bookingId: 'b_77',
        agentUserId: 'agent_uid_5',
        customerName: 'Omar',
        estateTitle: 'Sea View Villa',
      );

      expect(repository.created.length, 1);
      final item = repository.created.first;
      expect(item.recipientId, 'agent_uid_5');
      expect(item.type, NotificationType.bookingReceived);
      expect(item.entityType, 'booking');
      expect(item.entityId, 'b_77');
      expect(item.deduplicationKey, 'booking_new_b_77');
    });

    test('notifyBookingStatusChanged notifies customer with status', () async {
      await service.notifyBookingStatusChanged(
        bookingId: 'b_77',
        customerId: 'customer_10',
        estateTitle: 'Sea View Villa',
        newStatus: 'confirmed',
      );

      expect(repository.created.length, 1);
      final item = repository.created.first;
      expect(item.recipientId, 'customer_10');
      expect(item.type, NotificationType.bookingStatusChanged);
      expect(item.body, contains('confirmed'));
      expect(item.deduplicationKey, 'booking_status_b_77_confirmed');
    });

    test('notifyListingPublished notifies owner with listing details', () async {
      await service.notifyListingPublished(
        estateId: 'estate_88',
        ownerId: 'owner_99',
        estateTitle: 'Modern Loft',
      );

      expect(repository.created.length, 1);
      final item = repository.created.first;
      expect(item.recipientId, 'owner_99');
      expect(item.type, NotificationType.listingStatusChanged);
      expect(item.entityType, 'estate');
      expect(item.entityId, 'estate_88');
      expect(item.deduplicationKey, 'listing_published_estate_88');
    });
  });
}

