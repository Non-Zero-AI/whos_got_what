import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/data/user_events_provider.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/features/payment/services/payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/shared/widgets/optimized_image.dart';
import 'package:whos_got_what/shared/widgets/post_type_badge.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(child: Text('Event not found.'));
          }

          final isOrganizer = currentUser?.id == event.organizerId;
          final canEdit =
              event.startDate.difference(DateTime.now()).inHours >= 24;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: theme.scaffoldBackgroundColor,
                actions: [
                  if (isOrganizer) ...[
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color:
                            canEdit
                                ? null
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      onPressed:
                          canEdit
                              ? () {
                                context.push('/events/${event.id}/edit');
                              }
                              : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Note: Events cannot be edited within 24 hours of start time.',
                                    ),
                                  ),
                                );
                              },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ref, event),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'event-img-${event.id}',
                        child: Image.network(
                          event.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Theme.of(context).colorScheme.surface,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                        ),
                      ),
                      // Post Type Badge
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: PostTypeBadge(
                          postType: event.postType,
                          fontSize: 13,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date/Time
                      Text(
                        _formatEventTimeRange(event),
                        style: AppTextStyles.eventDateTime(
                          context,
                        ).copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        event.title,
                        style: AppTextStyles.headlinePrimary(context),
                      ),
                      const SizedBox(height: 16),
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              style: AppTextStyles.body(context).copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 24),

                      // Creator Info Section (Moved Up)
                      _EventCreatorInfo(organizerId: event.organizerId),

                      const SizedBox(height: 32),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 24),

                      // Event Details Header
                      Text(
                        'Event Details',
                        style: AppTextStyles.titleMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        event.description,
                        style: AppTextStyles.body(
                          context,
                        ).copyWith(height: 1.6, fontSize: 15),
                      ),
                      const SizedBox(height: 32),
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: () async {
                            try {
                              final paymentService = PaymentService(
                                Supabase.instance.client,
                              );
                              await paymentService.processPayment(
                                amount: event.price,
                                currency: 'usd',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Payment Successful!'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Payment Failed: $e')),
                                );
                              }
                            }
                          },
                          child: Text(
                            event.price == 0
                                ? 'Register for Free'
                                : 'Buy Ticket (\$${event.price.toStringAsFixed(2)})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Event?'),
            content: const Text(
              'This action cannot be undone. Are you sure you want to permanently delete this event?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(eventRepositoryProvider).deleteEvent(event.id);
        if (context.mounted) {
          context.pop(); // Go back from details
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Event deleted.')));
          // Refresh lists
          ref.invalidate(eventsProvider);
          ref.invalidate(userEventsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }
}

String _formatEventTimeRange(EventModel event) {
  final start = event.startDate;
  final end = event.endDate;

  final dateFormatter = DateFormat('EEEE, MMMM d, y');
  final timeFormatter = DateFormat('h:mm a');

  if (event.isAllDay) {
    return '${dateFormatter.format(start)} • All Day';
  }

  if (end == null) {
    return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}';
  }

  final sameDay =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  if (sameDay) {
    return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}–${timeFormatter.format(end)}';
  }

  final shortDateFormatter = DateFormat('MMM d, y');
  return '${shortDateFormatter.format(start)} ${timeFormatter.format(start)} – '
      '${shortDateFormatter.format(end)} ${timeFormatter.format(end)}';
}

class _EventCreatorInfo extends ConsumerWidget {
  final String organizerId;

  const _EventCreatorInfo({required this.organizerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(organizerId));

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        return InkWell(
          onTap: () => context.push('/profile/$organizerId'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: ClipOval(
                    child: OptimizedImage(
                      imageUrl: profile.avatarUrl ?? '',
                      width: 48,
                      height: 48,
                      placeholder: const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName ?? profile.username ?? 'Organizer',
                        style: AppTextStyles.titleMedium(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (profile.username != null)
                        Text(
                          '@${profile.username}',
                          style: AppTextStyles.captionMuted(context),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 50),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
