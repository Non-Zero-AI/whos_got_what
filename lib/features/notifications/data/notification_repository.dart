import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/notifications/domain/models/notification_model.dart';

/// Repository for managing notification subscriptions and history
class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  /// Get user's notification history
  Future<List<NotificationModel>> getNotificationHistory(String userId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((row) {
          try {
            // Ensure payload is a Map
            if (row['payload'] == null) {
              row['payload'] = <String, dynamic>{};
            }
            return NotificationModel.fromJson(row);
          } catch (e) {
            debugPrint('Error parsing notification: $e');
            // Return a dummy model or skip. Skipping is better for UI stability.
            return null;
          }
        })
        .whereType<NotificationModel>()
        .toList();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _supabase.from('notifications').delete().eq('id', notificationId);
  }

  /// Subscribe to notifications from a profile
  /// This means when that profile creates an event, the user will be notified
  Future<void> subscribeToProfile(String subscriberId, String profileId) async {
    try {
      await _supabase.from('notification_subscriptions').insert({
        'subscriber_id': subscriberId,
        'profile_id': profileId,
      });
    } on PostgrestException catch (e) {
      // Ignore duplicate key errors (user already subscribed)
      if (!e.message.contains('duplicate')) {
        rethrow;
      }
    }
  }

  /// Unsubscribe from notifications from a profile
  Future<void> unsubscribeFromProfile(
    String subscriberId,
    String profileId,
  ) async {
    await _supabase.from('notification_subscriptions').delete().match({
      'subscriber_id': subscriberId,
      'profile_id': profileId,
    });
  }

  /// Check if user is subscribed to notifications from a profile
  Future<bool> isSubscribedToProfile(
    String subscriberId,
    String profileId,
  ) async {
    final response =
        await _supabase
            .from('notification_subscriptions')
            .select('created_at')
            .match({'subscriber_id': subscriberId, 'profile_id': profileId})
            .maybeSingle();
    return response != null;
  }

  /// Get all profiles a user is subscribed to
  Future<List<String>> getSubscribedProfiles(String subscriberId) async {
    final response = await _supabase
        .from('notification_subscriptions')
        .select('profile_id')
        .eq('subscriber_id', subscriberId);

    return (response as List<dynamic>)
        .map((row) => row['profile_id'] as String)
        .toList();
  }

  /// Get all subscribers of a profile (users who want to be notified)
  Future<List<String>> getProfileSubscribers(String profileId) async {
    final response = await _supabase
        .from('notification_subscriptions')
        .select('subscriber_id')
        .eq('profile_id', profileId);

    return (response as List<dynamic>)
        .map((row) => row['subscriber_id'] as String)
        .toList();
  }

  /// Update user's global notification preferences
  Future<void> updateNotificationPreferences({
    required String userId,
    required bool enablePushNotifications,
    bool? enableEmailNotifications,
  }) async {
    await _supabase.from('notification_preferences').upsert({
      'user_id': userId,
      'push_enabled': enablePushNotifications,
      if (enableEmailNotifications != null)
        'email_enabled': enableEmailNotifications,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  /// Get user's notification preferences
  Future<NotificationPreferences> getNotificationPreferences(
    String userId,
  ) async {
    final response =
        await _supabase
            .from('notification_preferences')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

    if (response == null) {
      // Return default preferences
      return NotificationPreferences(
        userId: userId,
        pushEnabled: true,
        emailEnabled: false,
      );
    }

    return NotificationPreferences.fromJson(response);
  }

  /// Send a push notification to all subscribers when an event is created
  /// This calls a Supabase Edge Function that handles the actual FCM sending
  Future<void> notifySubscribersOfNewEvent({
    required String creatorId,
    required String eventId,
    required String eventTitle,
    required String creatorName,
  }) async {
    try {
      // Call Supabase Edge Function to send notifications
      await _supabase.functions.invoke(
        'send-event-notification',
        body: {
          'creator_id': creatorId,
          'event_id': eventId,
          'event_title': eventTitle,
          'creator_name': creatorName,
        },
      );
      debugPrint('Notification request sent for event: $eventId');
    } catch (e) {
      debugPrint('Error sending notification: $e');
      // Don't throw - notification failure shouldn't break event creation
    }
  }
}

/// User's notification preferences
class NotificationPreferences {
  final String userId;
  final bool pushEnabled;
  final bool emailEnabled;
  final DateTime? updatedAt;

  NotificationPreferences({
    required this.userId,
    required this.pushEnabled,
    required this.emailEnabled,
    this.updatedAt,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      userId: json['user_id'] as String,
      pushEnabled: (json['push_enabled'] as bool?) ?? true,
      emailEnabled: (json['email_enabled'] as bool?) ?? false,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  NotificationPreferences copyWith({bool? pushEnabled, bool? emailEnabled}) {
    return NotificationPreferences(
      userId: userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      updatedAt: DateTime.now(),
    );
  }
}

/// Provider for notification repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

/// Provider to check if current user is subscribed to a profile's notifications
final isSubscribedToNotificationsProvider = FutureProvider.family<bool, String>(
  (ref, profileId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    return ref
        .watch(notificationRepositoryProvider)
        .isSubscribedToProfile(user.id, profileId);
  },
);

/// Provider for user's notification preferences
final notificationPreferencesProvider = FutureProvider<NotificationPreferences>(
  (ref) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return NotificationPreferences(
        userId: '',
        pushEnabled: false,
        emailEnabled: false,
      );
    }
    return ref
        .watch(notificationRepositoryProvider)
        .getNotificationPreferences(user.id);
  },
);
