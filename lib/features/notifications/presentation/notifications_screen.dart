import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/features/notifications/data/notification_providers.dart';
import 'package:whos_got_what/features/notifications/domain/models/notification_model.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationHistoryProvider);
    final theme = Theme.of(context);

    return AppTheme.buildBackground(
      context: context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: AppTextStyles.titleLarge(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () {
                ref
                    .read(notificationControllerProvider.notifier)
                    .markAllAsRead();
              },
            ),
          ],
        ),
        body: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: AppTextStyles.titleMedium(context).copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(notification: notification);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Mark as read
        if (!notification.isRead) {
          ref
              .read(notificationControllerProvider.notifier)
              .markAsRead(notification.id);
        }

        // Navigate to payload if exists
        final eventId = notification.payload?['event_id'];
        if (eventId != null) {
          context.push('/home/events/$eventId');
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? theme.colorScheme.surface
                  : theme.colorScheme.primaryContainer.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              size: 20,
              color: notification.isRead
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.body(context).copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      dateFormat.format(notification.createdAt),
                      style: AppTextStyles.captionMuted(
                        context,
                      ).copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: AppTextStyles.captionMuted(
                    context,
                  ).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
