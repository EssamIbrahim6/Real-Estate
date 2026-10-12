import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.text,
    super.createdAt,
  });

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return MessageModel.fromMap(
      document.data() ?? const <String, dynamic>{},
      document.id,
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore({Object? createdAtValue}) => {
    'senderId': senderId,
    'text': text,
    'createdAt':
        createdAtValue ??
        (createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!)),
  };

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
