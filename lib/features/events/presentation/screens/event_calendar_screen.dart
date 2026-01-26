import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/features/events/presentation/widgets/compact_event_card.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';

class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  ConsumerState<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  final Set<String> _expandedDays = {};

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return AppTheme.buildBackground(
      context: context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Timeline',
            style: AppTextStyles.titleLarge(context),
          ),
          centerTitle: false,
        ),
        body: eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Text(
                  'No events scheduled.',
                  style: AppTextStyles.body(context),
                ),
              );
            }

            final groupedEvents = _groupEventsByDate(events);
            final sortedDates = groupedEvents.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final dayEvents = groupedEvents[date]!;
                return _buildDaySection(context, date, dayEvents);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Map<DateTime, List<EventModel>> _groupEventsByDate(List<EventModel> events) {
    final Map<DateTime, List<EventModel>> grouped = {};
    for (final event in events) {
      final date = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(event);
    }
    // Sort events within each day by start time
    for (final date in grouped.keys) {
      grouped[date]!.sort((a, b) => a.startDate.compareTo(b.startDate));
    }
    return grouped;
  }

  Widget _buildDaySection(BuildContext context, DateTime date, List<EventModel> events) {
    final theme = Theme.of(context);
    final dayName = DateFormat('EEE').format(date).toUpperCase();
    final dayNumber = date.day.toString();
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final isExpanded = _expandedDays.contains(dateKey);
    final displayEvents = isExpanded ? events : events.take(3).toList();
    final hasMore = events.length > 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Date indicator
          SizedBox(
            width: 60,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  dayName,
                  style: AppTextStyles.captionMuted(context).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dayNumber,
                  style: AppTextStyles.titleLarge(context).copyWith(
                    fontSize: 24,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side: Events list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...displayEvents.map((event) => CompactEventCard(
                      event: event,
                      onTap: () {
                        context.push('/home/events/${event.id}');
                      },
                    )),
                if (hasMore && !isExpanded)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedDays.add(dateKey);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '+${events.length - 3} more',
                        style: AppTextStyles.labelSecondary(context).copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isExpanded && hasMore)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedDays.remove(dateKey);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Show less',
                        style: AppTextStyles.labelSecondary(context).copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
