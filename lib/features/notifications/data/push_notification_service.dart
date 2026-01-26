import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/main.dart' show firebaseInitialized;

import 'package:whos_got_what/core/constants/app_constants.dart';
import 'package:whos_got_what/features/notifications/data/notification_providers.dart';
import 'package:whos_got_what/features/notifications/domain/models/notification_model.dart';
import 'package:whos_got_what/features/notifications/data/notification_repository.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('Handling background message: ${message.messageId}');

    // Note: Background history saving is disabled here because
    // it requires an authenticated session which isn't guaranteed
    // in this isolate. History is usually saved by the backend
    // when the notification is triggered.
  } catch (e) {
    debugPrint('Background handler failed: $e');
  }
}

/// Service for handling push notifications via Firebase Cloud Messaging
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase;
  final Ref _ref;

  PushNotificationService(this._supabase, this._ref);

  /// Initialize the notification service
  Future<void> initialize() async {
    // Check if Firebase is available
    if (!firebaseInitialized) {
      debugPrint('Push notifications disabled - Firebase not configured');
      return;
    }

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Initialize local notifications for foreground display
    await _initializeLocalNotifications();

    // Configure foreground presentation for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('🔥 ON MESSAGE: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get and save the FCM token
    await _saveDeviceToken();

    // Log FCM token for testing
    if (kDebugMode) {
      await logFcmToken();
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_updateDeviceToken);
  }

  /// Log the FCM token for testing purposes
  Future<void> logFcmToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('🔥 FCM TOKEN: $token');
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('Notification permission granted: $granted');
    return granted;
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'new_events_channel',
        'New Events',
        description: 'Notifications for new events from profiles you follow',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 Received foreground message: ${message.messageId}');
    debugPrint('📦 Message data: ${message.data}');
    debugPrint('🔔 Message notification: ${message.notification?.title}');

    final notification = message.notification;
    // Extract title and body from either notification object or data payload
    String title = notification?.title ?? message.data['title'] ?? 'New Alert';
    String body = notification?.body ?? message.data['body'] ?? '';

    // If both are still empty, don't show or save
    if (title.isEmpty && body.isEmpty && message.data.isEmpty) {
      debugPrint('⚠️ Empty message received, ignoring.');
      return;
    }

    // Save notification to Supabase history
    final user = _supabase.auth.currentUser;
    if (user != null) {
      debugPrint('💾 Saving notification to history for user: ${user.id}');
      try {
        await _supabase.from('notifications').insert({
          'user_id': user.id,
          'title': title,
          'body': body,
          'payload': message.data,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Notification saved to history');
        // Refresh notification history
        _ref.invalidate(notificationHistoryProvider);
      } catch (e) {
        debugPrint('❌ Failed to save notification to history: $e');
      }
    } else {
      debugPrint('👤 No user logged in, not saving to history');
    }

    debugPrint('📢 Showing local notification banner');
    _showLocalNotification(
      title: title,
      body: body,
      payload: message.data['event_id'],
    );
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'new_events_channel',
      'New Events',
      channelDescription:
          'Notifications for new events from profiles you follow',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    final eventId = message.data['event_id'];
    if (eventId != null) {
      // Use go_router to navigate
      // Since we don't have the context here, we might need a GlobalKey
      // Or use a provider to trigger navigation in the UI
      _ref.read(notificationNavigationProvider.notifier).setEventId(eventId);
    }
  }

  /// Get the current FCM token
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        // Get APNs token first for iOS
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNs token not available yet');
          return null;
        }
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save the device token to Supabase
  Future<void> _saveDeviceToken() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final token = await getToken();
    if (token == null) return;

    await _updateDeviceToken(token);
  }

  /// Update the device token in Supabase
  Future<void> _updateDeviceToken(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('push_tokens').upsert({
        'user_id': user.id,
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, token');
      debugPrint('Device token saved successfully');
    } catch (e) {
      debugPrint('Error saving device token: $e');
    }
  }

  /// Remove the device token (call on logout)
  Future<void> removeDeviceToken() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final token = await getToken();
    if (token == null) return;

    try {
      await _supabase.from('push_tokens').delete().match({
        'user_id': user.id,
        'token': token,
      });
      debugPrint('Device token removed successfully');
    } catch (e) {
      debugPrint('Error removing device token: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!firebaseInitialized) return false;

    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  /// Open app notification settings
  Future<void> openNotificationSettings() async {
    await _messaging.requestPermission();
  }
}

/// Provider for the push notification service
final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(Supabase.instance.client, ref);
});
