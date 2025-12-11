import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/presentation/widgets/event_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Who's Got What"),
      ),
      body: eventsAsync.when(
        data: (events) => RefreshIndicator(
          onRefresh: () => ref.refresh(eventsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return EventCard(event: events[index]);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
