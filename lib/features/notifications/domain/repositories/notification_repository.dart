import '../../../../core/utils/typedefs.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Create a notification in Firestore (client-side trigger).
  /// Returns silently if a document with [deduplicationKey] already exists
  /// for [recipientId].
  ResultVoid createNotification(NotificationEntity notification);

  /// Real-time stream of the 50 most recent notifications for [uid].
  Stream<List<NotificationEntity>> watchForUser(String uid);

  /// Mark a single notification as read.
  ResultVoid markAsRead(String notificationId);

  /// Mark all notifications for [uid] as read.
  ResultVoid markAllAsRead(String uid);

  /// Returns the count of unread notifications for [uid].
  Future<int> getUnreadCount(String uid);
}

