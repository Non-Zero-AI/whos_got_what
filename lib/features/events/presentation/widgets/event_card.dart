import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    void openDetails() => context.go('/home/events/${event.id}');

    return GestureDetector(
      onTap: openDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.cardColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            Hero(
              tag: 'event-img-${event.id}',
              child: Image.network(
                event.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: colorScheme.surface,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatEventTimeRange(event),
                            style: GoogleFonts.inter(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    event.title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.inter(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Description snippet
                  Text(
                    event.description,
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Views + check-in info
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.views} views',
                        style: GoogleFonts.inter(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.push_pin_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Check-in',
                        style: GoogleFonts.inter(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Social row + Details button
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.favorite_border, color: colorScheme.onSurface),
                          onPressed: () {}, // TODO: like action
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.share_outlined, color: colorScheme.onSurface),
                          onPressed: () {}, // TODO: share action
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            event.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () {}, // TODO: bookmark toggle
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: openDetails,
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut),
    );
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
