import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/notifications/data/models/notification_model.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_type.dart';

void main() {
  group('NotificationModel', () {
    test('toFirestore formats fields properly', () {
      final now = DateTime(2026, 10, 29, 12, 0, 0);
      final model = NotificationModel(
        id: 'n1',
        recipientId: 'u123',
        type: NotificationType.chatMessage,
        title: 'New message',
        body: 'Hello there',
        createdAt: now,
        isRead: false,
        entityType: 'conversation',
        entityId: 'conv_1',
        deduplicationKey: 'chat_msg_1',
      );

      final map = model.toFirestore();

      expect(map['recipientId'], 'u123');
      expect(map['type'], 'chatMessage');
      expect(map['title'], 'New message');
      expect(map['body'], 'Hello there');
      expect(map['isRead'], false);
      expect(map['entityType'], 'conversation');
      expect(map['entityId'], 'conv_1');
      expect(map['deduplicationKey'], 'chat_msg_1');
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('fromFirestore deserializes data with fallback defaults', () {
      final now = DateTime(2026, 10, 29, 12, 0, 0);
      final map = {
        'recipientId': 'u456',
        'type': 'bookingReceived',
        'title': 'Booking Request',
        'body': 'User booked a tour',
        'createdAt': Timestamp.fromDate(now),
        'isRead': true,
        'entityType': 'booking',
        'entityId': 'b_123',
        'deduplicationKey': 'booking_new_b_123',
      };

      final model = NotificationModel(
        id: 'doc_456',
        recipientId: map['recipientId'] as String,
        type: NotificationType.fromJson(map['type'] as String),
        title: map['title'] as String,
        body: map['body'] as String,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        isRead: map['isRead'] as bool,
        entityType: map['entityType'] as String,
        entityId: map['entityId'] as String,
        deduplicationKey: map['deduplicationKey'] as String,
      );

      expect(model.id, 'doc_456');
      expect(model.recipientId, 'u456');
      expect(model.type, NotificationType.bookingReceived);
      expect(model.title, 'Booking Request');
      expect(model.body, 'User booked a tour');
      expect(model.isRead, true);
      expect(model.entityType, 'booking');
      expect(model.entityId, 'b_123');
      expect(model.deduplicationKey, 'booking_new_b_123');
    });

    test('NotificationType.fromJson falls back to chatMessage on unknown', () {
      final type = NotificationType.fromJson('unknown_type');
      expect(type, NotificationType.chatMessage);
    });
  });
}

