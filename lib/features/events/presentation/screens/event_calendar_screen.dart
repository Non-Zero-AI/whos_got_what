import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/presentation/widgets/event_card.dart';

class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  ConsumerState<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: eventsAsync.when(
        data: (events) {
          final selectedEvents = events.where((e) {
            final d = e.startDate;
            return d.year == _selectedDay.year && d.month == _selectedDay.month && d.day == _selectedDay.day;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _focusedDay,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    currentDate: DateTime.now(),
                    onDateChanged: (day) {
                      setState(() {
                        _selectedDay = day;
                        _focusedDay = day;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('EEEE, MMM d, y').format(_selectedDay),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No events scheduled for this day.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          return EventCard(event: selectedEvents[index]);
                        },
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
}
