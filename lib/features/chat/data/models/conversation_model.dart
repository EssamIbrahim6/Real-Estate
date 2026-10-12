import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participants,
    required super.customerId,
    required super.agentUserId,
    required super.agentId,
    required super.estateId,
    super.createdAt,
    super.lastMessage,
    super.lastMessageAt,
    super.lastSenderId,
    super.lastReadAtByParticipant,
  });

  factory ConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return ConversationModel.fromMap(
      document.data() ?? const <String, dynamic>{},
      document.id,
    );
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    final rawReadAt = map['lastReadAtByParticipant'];
    final readAtByParticipant = <String, DateTime>{};
    if (rawReadAt is Map) {
      for (final entry in rawReadAt.entries) {
        final timestamp = _parseDateTime(entry.value);
        if (entry.key is String && timestamp != null) {
          readAtByParticipant[entry.key as String] = timestamp;
        }
      }
    }

    return ConversationModel(
      id: id,
      participants: (map['participants'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      customerId: map['customerId'] as String? ?? '',
      agentUserId: map['agentUserId'] as String? ?? '',
      agentId: map['agentId'] as String? ?? '',
      estateId: map['estateId'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: _parseDateTime(map['lastMessageAt']),
      lastSenderId: map['lastSenderId'] as String?,
      lastReadAtByParticipant: readAtByParticipant,
    );
  }

  Map<String, dynamic> toFirestore({
    Object? createdAtValue,
    Object? lastMessageAtValue,
  }) => {
    'participants': participants,
    'customerId': customerId,
    'agentUserId': agentUserId,
    'agentId': agentId,
    'estateId': estateId,
    'createdAt':
        createdAtValue ??
        (createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!)),
    'lastMessage': lastMessage,
    'lastMessageAt':
        lastMessageAtValue ??
        (lastMessageAt == null ? null : Timestamp.fromDate(lastMessageAt!)),
    'lastSenderId': lastSenderId,
    'lastReadAtByParticipant': lastReadAtByParticipant.map(
      (userId, dateTime) => MapEntry(userId, Timestamp.fromDate(dateTime)),
    ),
  };

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
