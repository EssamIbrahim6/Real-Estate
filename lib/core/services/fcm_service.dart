import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'local_notification_service.dart';

/// Top-level background message handler required by Firebase Cloud Messaging.
/// Must be annotated with `@pragma('vm:entry-point')` to survive tree-shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Received message: ${message.messageId}');
}

/// Client-side Firebase Cloud Messaging (FCM) service.
///
/// **STRICT ZERO-COST & SECURITY CONSTRAINTS**:
/// 1. Firebase Spark plan only (no Cloud Functions, no paid backend).
/// 2. NO server-side FCM dispatching from Flutter client (never embed FCM Server
///    Keys, Service Account JSONs, or send HTTP requests to fcm.googleapis.com).
/// 3. Registers device FCM tokens in `/users/{uid}` so an external or future
///    trusted server can dispatch notifications.
///
/// **ARCHITECTURAL NOTE**:
/// Without a trusted server-side sender, Firestore document creation cannot
/// trigger remote push notifications when the app is in the background or closed.
class FcmService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final LocalNotificationService _localNotifications;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  FcmService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    LocalNotificationService? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _localNotifications =
           localNotifications ?? LocalNotificationService.instance;

  /// Initializes FCM listeners, requests permissions, and sets up message handlers.
  Future<void> initialize({
    void Function(RemoteMessage message)? onNotificationTap,
  }) async {
    try {
      // 1. Request notification permissions (iOS and Android 13+)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '[FCM] Notification authorization status: ${settings.authorizationStatus}',
      );

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Foreground message listener: show local heads-up notification
      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
          '[FCM Foreground] Title: ${message.notification?.title}, Body: ${message.notification?.body}',
        );

        final notification = message.notification;
        if (notification != null) {
          _localNotifications.showNotification(
            id: message.hashCode,
            title: notification.title ?? 'Notification',
            body: notification.body ?? '',
            payload: message.data['route'] as String? ?? message.data['entityId'] as String?,
            deduplicationKey: message.messageId,
          );
        }
      });

      // 4. Background message opened app listener (app was in background)
      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          debugPrint('[FCM] Notification clicked from background: ${message.data}');
          if (onNotificationTap != null) {
            onNotificationTap(message);
          }
        },
      );

      // 5. Cold start notification check (app was completely terminated)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null && onNotificationTap != null) {
        debugPrint('[FCM] Cold start message detected: ${initialMessage.data}');
        onNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('[FCM] Initialization error: $e');
    }
  }

  /// Registers and persists the current device's FCM token in Firestore under
  /// `/users/{uid}/fcmToken`.
  Future<void> registerDeviceToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _saveTokenToFirestore(uid, token);
      }

      // Listen for token rotations
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(uid, newToken);
      });
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  /// Removes or cleans up FCM listeners on sign out.
  Future<void> unregisterUser() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<void> _saveTokenToFirestore(String uid, String token) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != uid) return;

      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[FCM] Device token saved to Firestore for user $uid');
    } catch (e) {
      debugPrint('[FCM] Error saving token to Firestore: $e');
    }
  }

  /// Disposes stream subscriptions.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
  }
}

