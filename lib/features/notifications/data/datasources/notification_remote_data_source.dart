import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> createNotification(NotificationEntity notification);
  Stream<List<NotificationModel>> watchForUser(String uid);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String uid);
  Future<int> getUnreadCount(String uid);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  const NotificationRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('notifications');

  @override
  Future<void> createNotification(NotificationEntity notification) async {
    // Deduplicate: if a deduplicationKey is set, check for existing doc first.
    if (notification.deduplicationKey != null &&
        notification.deduplicationKey!.isNotEmpty) {
      final existing = await _col
          .where('recipientId', isEqualTo: notification.recipientId)
          .where(
            'deduplicationKey',
            isEqualTo: notification.deduplicationKey,
          )
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        debugPrint(
          '[Notifications] Duplicate skipped: ${notification.deduplicationKey}',
        );
        return;
      }
    }

    final model = NotificationModel(
      id: '',
      recipientId: notification.recipientId,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      createdAt: notification.createdAt,
      isRead: false,
      entityType: notification.entityType,
      entityId: notification.entityId,
      deduplicationKey: notification.deduplicationKey,
    );

    await _col.add(model.toFirestore());
  }

  @override
  Stream<List<NotificationModel>> watchForUser(String uid) {
    return _col
        .where('recipientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(NotificationModel.fromFirestore).toList(
                growable: false,
              ),
        );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _col.doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String uid) async {
    final unread = await _col
        .where('recipientId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (unread.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<int> getUnreadCount(String uid) async {
    final snap = await _col
        .where('recipientId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snap.count ?? 0;
  }
}

