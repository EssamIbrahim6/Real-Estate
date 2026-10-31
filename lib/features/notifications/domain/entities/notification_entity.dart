import 'package:equatable/equatable.dart';

import 'notification_type.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  /// e.g. "conversation", "booking", "estate"
  final String? entityType;

  /// The Firestore document id to navigate to on tap
  final String? entityId;

  /// Used for idempotency; at most one notification per key per recipient
  final String? deduplicationKey;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.entityType,
    this.entityId,
    this.deduplicationKey,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
    id: id,
    recipientId: recipientId,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    entityType: entityType,
    entityId: entityId,
    deduplicationKey: deduplicationKey,
  );

  @override
  List<Object?> get props => [
    id,
    recipientId,
    type,
    title,
    body,
    createdAt,
    isRead,
    entityType,
    entityId,
    deduplicationKey,
  ];
}

