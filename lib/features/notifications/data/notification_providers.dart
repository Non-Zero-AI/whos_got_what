import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/notifications/data/notification_repository.dart';
import 'package:whos_got_what/features/notifications/data/push_notification_service.dart';
import 'package:whos_got_what/features/notifications/domain/models/notification_model.dart';

/// Provider for notification history
final notificationHistoryProvider = FutureProvider<List<NotificationModel>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return ref
      .watch(notificationRepositoryProvider)
      .getNotificationHistory(user.id);
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final history = ref.watch(notificationHistoryProvider).value ?? [];
  return history.where((n) => !n.isRead).length;
});

/// Provider for notification-based navigation
/// Stores the eventId to navigate to
class NotificationNavigationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setEventId(String? id) => state = id;
  void clear() => state = null;
}

final notificationNavigationProvider =
    NotifierProvider<NotificationNavigationNotifier, String?>(
      NotificationNavigationNotifier.new,
    );

/// Controller for managing notification subscriptions and history
class NotificationController extends Notifier<void> {
  @override
  void build() {}

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(notificationId);
    ref.invalidate(notificationHistoryProvider);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead(user.id);
    ref.invalidate(notificationHistoryProvider);
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.deleteNotification(notificationId);
    ref.invalidate(notificationHistoryProvider);
  }

  /// Toggle notification subscription for a profile
  Future<void> toggleSubscription(String profileId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    final isSubscribed = await repo.isSubscribedToProfile(user.id, profileId);

    if (isSubscribed) {
      await repo.unsubscribeFromProfile(user.id, profileId);
    } else {
      await repo.subscribeToProfile(user.id, profileId);
    }

    // Invalidate the provider to refresh UI
    ref.invalidate(isSubscribedToNotificationsProvider(profileId));
  }

  /// Subscribe to a profile's notifications
  Future<void> subscribe(String profileId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    await repo.subscribeToProfile(user.id, profileId);
    ref.invalidate(isSubscribedToNotificationsProvider(profileId));
  }

  /// Unsubscribe from a profile's notifications
  Future<void> unsubscribe(String profileId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    await repo.unsubscribeFromProfile(user.id, profileId);
    ref.invalidate(isSubscribedToNotificationsProvider(profileId));
  }

  /// Update global push notification setting
  Future<void> setPushNotificationsEnabled(bool enabled) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    await repo.updateNotificationPreferences(
      userId: user.id,
      enablePushNotifications: enabled,
    );

    // If disabling, also remove device token
    if (!enabled) {
      final pushService = ref.read(pushNotificationServiceProvider);
      await pushService.removeDeviceToken();
    }

    ref.invalidate(notificationPreferencesProvider);
  }
}

/// Provider for notification controller
final notificationControllerProvider =
    NotifierProvider<NotificationController, void>(NotificationController.new);

/// Provider to check if push notifications are enabled at the system level
final systemNotificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final pushService = ref.watch(pushNotificationServiceProvider);
  return pushService.areNotificationsEnabled();
});
