import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/chat/data/models/conversation_model.dart';
import 'package:real_estate_app/features/chat/data/models/message_model.dart';

void main() {
  group('ConversationModel', () {
    test('maps Firestore values and timestamps', () {
      final createdAt = DateTime.utc(2026, 10, 4, 12);
      final lastMessageAt = DateTime.utc(2026, 10, 4, 13);
      final readAt = DateTime.utc(2026, 10, 4, 14);

      final conversation = ConversationModel.fromMap({
        'participants': ['customer-uid', 'agent-user-uid'],
        'customerId': 'customer-uid',
        'agentUserId': 'agent-user-uid',
        'agentId': 'agent-document-id',
        'estateId': 'estate-document-id',
        'createdAt': Timestamp.fromDate(createdAt),
        'lastMessage': 'Interested in this property',
        'lastMessageAt': Timestamp.fromDate(lastMessageAt),
        'lastSenderId': 'customer-uid',
        'lastReadAtByParticipant': {'customer-uid': Timestamp.fromDate(readAt)},
      }, 'conversation-id');

      expect(conversation.id, 'conversation-id');
      expect(conversation.participants, ['customer-uid', 'agent-user-uid']);
      expect(conversation.customerId, 'customer-uid');
      expect(conversation.agentUserId, 'agent-user-uid');
      expect(conversation.agentId, 'agent-document-id');
      expect(conversation.estateId, 'estate-document-id');
      expect(conversation.createdAt!.isAtSameMomentAs(createdAt), isTrue);
      expect(conversation.lastMessage, 'Interested in this property');
      expect(
        conversation.lastMessageAt!.isAtSameMomentAs(lastMessageAt),
        isTrue,
      );
      expect(conversation.lastSenderId, 'customer-uid');
      expect(
        conversation.lastReadAtByParticipant['customer-uid']!.isAtSameMomentAs(
          readAt,
        ),
        isTrue,
      );
    });

    test('allows absent last-message timestamp', () {
      final conversation = ConversationModel.fromMap({
        'participants': <String>[],
        'customerId': 'customer',
        'agentUserId': 'agent',
        'agentId': 'agent-doc',
        'estateId': 'estate',
        'lastMessageAt': null,
        'lastReadAtByParticipant': null,
      }, 'conversation-id');

      expect(conversation.lastMessageAt, isNull);
      expect(conversation.lastReadAtByParticipant, isEmpty);
    });

    test('serializes timestamps and only the required conversation fields', () {
      final createdAt = DateTime.utc(2026, 10, 4, 12);
      final lastMessageAt = DateTime.utc(2026, 10, 4, 13);
      final model = ConversationModel(
        id: 'conversation-id',
        participants: const ['customer', 'agent-user'],
        customerId: 'customer',
        agentUserId: 'agent-user',
        agentId: 'agent-doc',
        estateId: 'estate',
        createdAt: createdAt,
        lastMessage: 'Hello',
        lastMessageAt: lastMessageAt,
        lastSenderId: 'customer',
      );

      final map = model.toFirestore();

      expect(map.keys.toSet(), {
        'participants',
        'customerId',
        'agentUserId',
        'agentId',
        'estateId',
        'createdAt',
        'lastMessage',
        'lastMessageAt',
        'lastSenderId',
        'lastReadAtByParticipant',
      });
      expect(
        (map['createdAt'] as Timestamp).toDate().isAtSameMomentAs(createdAt),
        isTrue,
      );
      expect(
        (map['lastMessageAt'] as Timestamp).toDate().isAtSameMomentAs(
          lastMessageAt,
        ),
        isTrue,
      );
    });
  });

  group('MessageModel', () {
    test('maps and serializes message timestamp fields', () {
      final createdAt = DateTime.utc(2026, 10, 4, 12);
      final message = MessageModel.fromMap({
        'senderId': 'sender-uid',
        'text': 'Hello',
        'createdAt': Timestamp.fromDate(createdAt),
      }, 'message-id');

      expect(message.id, 'message-id');
      expect(message.senderId, 'sender-uid');
      expect(message.text, 'Hello');
      expect(message.createdAt!.isAtSameMomentAs(createdAt), isTrue);

      final map = MessageModel(
        id: message.id,
        senderId: message.senderId,
        text: message.text,
        createdAt: createdAt,
      ).toFirestore();
      expect(map.keys.toSet(), {'senderId', 'text', 'createdAt'});
      expect(
        (map['createdAt'] as Timestamp).toDate().isAtSameMomentAs(createdAt),
        isTrue,
      );
    });
  });
}
