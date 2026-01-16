import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/features/payment/services/payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/shared/widgets/liquid_glass_container.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(child: Text('Event not found.'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'event-img-${event.id}',
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Date & Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LiquidGlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            borderRadius: 12,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppTheme.tealAccent),
                                const SizedBox(width: 8),
                                Text(
                                  _formatEventTimeRange(event),
                                  style: AppTextStyles.labelSecondary(context).copyWith(
                                    color: AppTheme.tealAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            event.price == 0 ? 'FREE' : '\$${event.price.toStringAsFixed(0)}',
                            style: AppTextStyles.titleLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.amberAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. Title
                      Text(
                        event.title,
                        style: AppTextStyles.titleLarge(context).copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Location HUD
                      LiquidGlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.location,
                                style: AppTextStyles.titleMedium(context),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 4. Description
                      Text(
                        'ABOUT THIS EVENT',
                        style: AppTextStyles.labelSecondary(context).copyWith(
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 16,
                          height: 1.6,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 5. Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton(
                          onPressed: () async {
                            try {
                               final paymentService = PaymentService(Supabase.instance.client);
                               await paymentService.processPayment(amount: event.price, currency: 'usd');
                               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful!')));
                            } catch (e) {
                               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.tealAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            event.price == 0 ? 'REGISTER NOW' : 'GET TICKETS',
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                      ),
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

String _formatEventTimeRange(EventModel event) {
  final start = event.startDate;
  final end = event.endDate;
  final dateFormatter = DateFormat('MMM d, y');
  final timeFormatter = DateFormat('h:mm a');

  if (event.isAllDay) return '${dateFormatter.format(start)} • All Day';
  if (end == null) return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}';

  final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
  if (sameDay) return '${dateFormatter.format(start)} • ${timeFormatter.format(start)} – ${timeFormatter.format(end)}';

  return '${dateFormatter.format(start)} – ${dateFormatter.format(end)}';
}
