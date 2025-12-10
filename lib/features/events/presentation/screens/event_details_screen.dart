import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/payment/services/payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, you'd fetch specific event by ID. 
    // Here we just find it from the list for demo purposes.
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      body: eventsAsync.when(
        data: (events) {
          final event = events.firstWhere((e) => e.id == eventId, orElse: () => events.first);
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(event.title, style: const TextStyle(shadows: [Shadow(blurRadius: 10.0, color: Colors.black)])),
                  background: Hero(
                    tag: 'event-img-${event.id}',
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                         DateFormat('EEEE, MMMM d, y • h:mm a').format(event.date),
                         style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(event.description, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(child: Text(event.location, style: Theme.of(context).textTheme.titleMedium)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: () async {
                            try {
                               final paymentService = PaymentService(Supabase.instance.client);
                               await paymentService.processPayment(amount: event.price, currency: 'usd');
                               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
                            } catch (e) {
                               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: $e')));
                            }
                          },
                          child: Text(event.price == 0 ? 'Register for Free' : 'Buy Ticket (\$${event.price.toStringAsFixed(2)})'),
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
}
