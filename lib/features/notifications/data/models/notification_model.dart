import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_type.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.type,
    required super.title,
    required super.body,
    required super.createdAt,
    required super.isRead,
    super.entityType,
    super.entityId,
    super.deduplicationKey,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] as String? ?? '',
      type: NotificationType.fromJson(data['type'] as String? ?? ''),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: _parseDate(data['createdAt']) ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      entityType: data['entityType'] as String?,
      entityId: data['entityId'] as String?,
      deduplicationKey: data['deduplicationKey'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'recipientId': recipientId,
    'type': type.toJson(),
    'title': title,
    'body': body,
    'createdAt': FieldValue.serverTimestamp(),
    'isRead': isRead,
    if (entityType != null) 'entityType': entityType,
    if (entityId != null) 'entityId': entityId,
    if (deduplicationKey != null) 'deduplicationKey': deduplicationKey,
  };

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

