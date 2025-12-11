import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_got_what/features/events/data/user_events_provider.dart';
import 'package:whos_got_what/features/events/presentation/widgets/event_card.dart';

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEvents = ref.watch(userEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: userEvents.isEmpty
          ? const Center(
              child: Text('You have not created any events yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userEvents.length,
              itemBuilder: (context, index) {
                return EventCard(event: userEvents[index]);
              },
            ),
    );
  }
}
