import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Free, local-only notification service using `flutter_local_notifications`.
///
/// Handles displaying native foreground heads-up banners when the app is
/// active in foreground.
///
/// **IMPORTANT ARCHITECTURAL LIMITATION**:
/// Local notifications run strictly within the Flutter client process.
/// They CANNOT listen to Firestore or trigger alerts when the app is
/// completely closed or terminated by the operating system.
class LocalNotificationService {
  static final LocalNotificationService instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() => instance;

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final Set<String> _shownDeduplicationKeys = <String>{};
  bool _isInitialized = false;

  static const String channelId = 'real_estate_channel';
  static const String channelName = 'Real Estate Alerts';
  static const String channelDescription =
      'Important updates about bookings, chats, and properties';

  /// Initializes the local notification plugin for Android and iOS.
  Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );

    // Create standard Android notification channel
    final androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
  }

  /// Explicitly requests system notification permissions on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    bool granted = false;

    // Android 13+ (API 33+)
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final androidGranted = await androidPlugin.requestNotificationsPermission();
      granted = androidGranted ?? false;
    }

    // iOS / macOS
    final darwinPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (darwinPlugin != null) {
      final iOSGranted = await darwinPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = granted || (iOSGranted ?? false);
    }

    return granted;
  }

  /// Displays an immediate local notification heads-up.
  ///
  /// If [deduplicationKey] is provided and has already been shown in this
  /// session, it will be skipped to prevent redundant alert spamming.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? deduplicationKey,
  }) async {
    if (deduplicationKey != null &&
        deduplicationKey.isNotEmpty &&
        _shownDeduplicationKeys.contains(deduplicationKey)) {
      debugPrint('[LocalNotification] Skipped duplicate alert: $deduplicationKey');
      return;
    }

    if (deduplicationKey != null && deduplicationKey.isNotEmpty) {
      _shownDeduplicationKeys.add(deduplicationKey);
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[LocalNotification] Error showing notification: $e');
    }
  }

  /// Clears in-memory session deduplication cache.
  void clearDeduplicationCache() {
    _shownDeduplicationKeys.clear();
  }
}

