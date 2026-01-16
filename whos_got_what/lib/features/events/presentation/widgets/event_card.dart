import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/shared/widgets/liquid_glass_container.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void openDetails() => context.go('/home/events/${event.id}');

    return LiquidGlassContainer(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.zero,
      onTap: openDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Header (Banner)
          Hero(
            tag: 'event-img-${event.id}',
            child: Image.network(
              event.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Business Info Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(event.imageUrl), // Placeholder for business logo
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BUSINESS NAME', // Placeholder
                          style: AppTextStyles.titleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '@handle',
                              style: AppTextStyles.captionMuted(context),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.stars, size: 14, color: AppTheme.tealAccent),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Business',
                              style: AppTextStyles.captionMuted(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 3. Event Title
                Text(
                  event.title,
                  style: AppTextStyles.eventTitle(context).copyWith(
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 4. Date/Time Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.tealAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.tealAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppTheme.tealAccent),
                      const SizedBox(width: 8),
                      Text(
                        _formatEventTimeRange(event),
                        style: AppTextStyles.eventDateTime(context).copyWith(
                          color: AppTheme.tealAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // 5. Location Row
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      event.location,
                      style: AppTextStyles.eventLocation(context).copyWith(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 6. Description Snippet
                Text(
                  event.description,
                  style: AppTextStyles.eventDescription(context).copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 20),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 20),
                
                // 7. Interaction Row
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.redAccent, size: 28),
                    const SizedBox(width: 24),
                    Icon(Icons.assistant_direction_outlined, color: AppTheme.tealAccent, size: 28),
                    const SizedBox(width: 24),
                    Icon(Icons.bookmark_border, color: AppTheme.amberAccent, size: 28),
                    const Spacer(),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: openDetails,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.tealAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'DETAILS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

String _formatEventTimeRange(EventModel event) {
  final start = event.startDate;
  final end = event.endDate;

  final dateFormatter = DateFormat('MMM d, y');
  final timeFormatter = DateFormat('h:mm a');

  // All-day event: show just date + "All Day"
  if (event.isAllDay) {
    return '${dateFormatter.format(start)} • All Day';
  }

  // No end time: show single timestamp
  if (end == null) {
    return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}';
  }

  // Same-day range: "Nov 11, 2025 • 6:00–8:00 PM"
  final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
  if (sameDay) {
    return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}–${timeFormatter.format(end)}';
  }

  // Multi-day range: "Nov 11, 6:00 PM – Nov 12, 9:00 AM"
  final shortDateFormatter = DateFormat('MMM d');
  return '${shortDateFormatter.format(start)}, ${timeFormatter.format(start)} – '
      '${shortDateFormatter.format(end)}, ${timeFormatter.format(end)}';
}
