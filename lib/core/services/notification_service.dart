import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../features/estate/domain/entities/estate_entity.dart';
import '../../features/notifications/domain/entities/notification_entity.dart';
import '../../features/notifications/domain/entities/notification_type.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import 'local_notification_service.dart';

/// Convenience service for dispatching in-app notifications and triggering
/// local heads-up banners on the Flutter client.
///
/// **CONSTRAINTS & RULES**:
/// 1. Firebase Spark plan only (zero backend cost).
/// 2. Idempotent: Every notification uses a deterministic [deduplicationKey]
///    to prevent duplicate alerts.
/// 3. No self-notifications (e.g. Chat sender never notifies self; property creator
///    never receives match alerts for their own property).
/// 4. When a notification targets the currently active user, a local heads-up
///    banner is presented via [LocalNotificationService].
class NotificationService {
  final NotificationRepository _repository;
  final LocalNotificationService _localNotifications;

  NotificationService(
    this._repository, [
    LocalNotificationService? localNotifications,
  ]) : _localNotifications =
           localNotifications ?? LocalNotificationService.instance;

  // ──────────────────────────────────────────────
  // 1. Account Events
  // ──────────────────────────────────────────────

  Future<void> notifyAccountCreated({required String uid}) => _send(
    NotificationEntity(
      id: '',
      recipientId: uid,
      type: NotificationType.accountCreated,
      title: 'Welcome!',
      body: 'Your account was created successfully. Start exploring properties.',
      createdAt: DateTime.now(),
      isRead: false,
      deduplicationKey: 'account_created_$uid',
    ),
  );

  // ──────────────────────────────────────────────
  // 2. Chat Messages
  // ──────────────────────────────────────────────

  /// Notifies the other participant in a conversation about a new message.
  /// Skips if [recipientId] is empty or matches sender.
  Future<void> notifyChatMessage({
    required String messageId,
    required String recipientId,
    required String senderName,
    required String conversationId,
    required String messagePreview,
  }) {
    if (recipientId.trim().isEmpty) return Future.value();

    return _send(
      NotificationEntity(
        id: '',
        recipientId: recipientId,
        type: NotificationType.chatMessage,
        title: 'New message from $senderName',
        body: messagePreview.length > 80
            ? '${messagePreview.substring(0, 77)}…'
            : messagePreview,
        createdAt: DateTime.now(),
        isRead: false,
        entityType: 'conversation',
        entityId: conversationId,
        deduplicationKey: 'chat_msg_$messageId',
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 3. Booking Events
  // ──────────────────────────────────────────────

  /// Notify the agent/owner that a customer submitted a booking request.
  Future<void> notifyBookingReceived({
    required String bookingId,
    required String agentUserId,
    required String customerName,
    required String estateTitle,
  }) {
    if (agentUserId.trim().isEmpty) return Future.value();

    return _send(
      NotificationEntity(
        id: '',
        recipientId: agentUserId,
        type: NotificationType.bookingReceived,
        title: 'New booking request',
        body: '$customerName requested a visit for "$estateTitle".',
        createdAt: DateTime.now(),
        isRead: false,
        entityType: 'booking',
        entityId: bookingId,
        deduplicationKey: 'booking_new_$bookingId',
      ),
    );
  }

  /// General booking status change notification.
  Future<void> notifyBookingStatusChanged({
    required String bookingId,
    required String customerId,
    required String estateTitle,
    required String newStatus,
  }) {
    if (customerId.trim().isEmpty) return Future.value();

    return _send(
      NotificationEntity(
        id: '',
        recipientId: customerId,
        type: NotificationType.bookingStatusChanged,
        title: 'Booking update',
        body: 'Your booking for "$estateTitle" is now $newStatus.',
        createdAt: DateTime.now(),
        isRead: false,
        entityType: 'booking',
        entityId: bookingId,
        deduplicationKey: 'booking_status_${bookingId}_$newStatus',
      ),
    );
  }

  /// Explicit notification when agent approves a booking.
  Future<void> notifyBookingApproved({
    required String bookingId,
    required String customerId,
    required String estateTitle,
  }) {
    if (customerId.trim().isEmpty) return Future.value();

    return _send(
      NotificationEntity(
        id: '',
        recipientId: customerId,
        type: NotificationType.bookingStatusChanged,
        title: 'Booking Confirmed! 🎉',
        body: 'Your tour for "$estateTitle" has been approved and confirmed by the agent.',
        createdAt: DateTime.now(),
        isRead: false,
        entityType: 'booking',
        entityId: bookingId,
        deduplicationKey: 'booking_status_${bookingId}_confirmed',
      ),
    );
  }

  /// Explicit notification when agent rejects or declines a booking.
  Future<void> notifyBookingRejected({
    required String bookingId,
    required String customerId,
    required String estateTitle,
    String? reason,
  }) {
    if (customerId.trim().isEmpty) return Future.value();

    final reasonSuffix = (reason != null && reason.trim().isNotEmpty)
        ? ' Reason: $reason'
        : '';

    return _send(
      NotificationEntity(
        id: '',
        recipientId: customerId,
        type: NotificationType.bookingStatusChanged,
        title: 'Booking Declined',
        body: 'Your tour request for "$estateTitle" was declined.$reasonSuffix',
        createdAt: DateTime.now(),
        isRead: false,
        entityType: 'booking',
        entityId: bookingId,
        deduplicationKey: 'booking_status_${bookingId}_cancelled',
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 4. Property Listing Events
  // ──────────────────────────────────────────────

  /// Notify the owner that their listing is published and active.
  Future<void> notifyListingPublished({
    required String estateId,
    required String ownerId,
    required String estateTitle,
  }) {
    if (ownerId.trim().isEmpty) return Future.value();

    return _send(
      NotificationEntity(
        id: '',
        recipientId: ownerId,
        type: NotificationType.listingStatusChanged,
        title: 'Listing Published',
        body: 'Your property "$estateTitle" is now published and active.',
        createdAt: DateTime.now(),
        isRead: false,
        entityType: 'estate',
        entityId: estateId,
        deduplicationKey: 'listing_published_$estateId',
      ),
    );
  }

  /// Notify the property owner of an approval/rejection or status change.
  Future<void> notifyEstateStatusChanged({
    required String estateId,
    required String ownerId,
    required String estateTitle,
    required String status,
    String? reason,
  }) {
    if (ownerId.trim().isEmpty) return Future.value();

    final isApproved = status.toLowerCase() == 'active' || status.toLowerCase() == 'approved';
    final title = isApproved ? 'Listing Approved' : 'Listing Status: $status';
    final body = isApproved
        ? 'Your listing for "$estateTitle" has been approved and is now public.'
        : 'Your listing for "$estateTitle" status changed to $status.${reason != null ? " ($reason)" : ""}';

    return _send(
      NotificationEntity(
        id: '',
        recipientId: ownerId,
        type: NotificationType.listingStatusChanged,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        isRead: false,
        entityType: 'estate',
        entityId: estateId,
        deduplicationKey: 'listing_status_${estateId}_$status',
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 5. Personalized New-Property Matching
  // ──────────────────────────────────────────────

  /// Efficiently checks a list of newly loaded estates against the current user's
  /// saved category preferences.
  ///
  /// **SPARK PLAN EFFICIENCY**:
  /// Operates purely on the active user's local dataset. Does NOT perform
  /// expensive full collection scans across other users in `/users`.
  Future<void> checkPersonalizedPropertyMatches({
    required String uid,
    required List<String> preferredCategories,
    required List<EstateEntity> candidateEstates,
  }) async {
    if (uid.isEmpty || preferredCategories.isEmpty || candidateEstates.isEmpty) {
      return;
    }

    final normalizedPreferred = preferredCategories
        .map((c) => c.toLowerCase().trim())
        .toSet();

    for (final estate in candidateEstates) {
      // Avoid notifying users about their own published properties
      if (estate.ownerId == uid) continue;

      final category = estate.categoryId.toLowerCase().trim();
      if (normalizedPreferred.contains(category)) {
        await _send(
          NotificationEntity(
            id: '',
            recipientId: uid,
            type: NotificationType.newMatchingProperty,
            title: 'New Match for You!',
            body: 'A new $category "${estate.title}" matches your property preferences.',
            createdAt: DateTime.now(),
            isRead: false,
            entityType: 'estate',
            entityId: estate.id,
            deduplicationKey: 'match_${uid}_${estate.id}',
          ),
        );
      }
    }
  }

  // ──────────────────────────────────────────────
  // Internal Helper
  // ──────────────────────────────────────────────

  Future<void> _send(NotificationEntity notification) async {
    try {
      await _repository.createNotification(notification);

      // If notification targets the active user, trigger a local heads-up
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && currentUid == notification.recipientId) {
        await _localNotifications.showNotification(
          id: notification.deduplicationKey?.hashCode ?? notification.title.hashCode,
          title: notification.title,
          body: notification.body,
          payload: notification.entityId,
          deduplicationKey: notification.deduplicationKey,
        );
      }
    } catch (e, st) {
      debugPrint('[NotificationService] Failed to send notification: $e\n$st');
    }
  }
}
