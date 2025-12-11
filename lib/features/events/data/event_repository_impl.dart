import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whos_got_what/features/events/domain/models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents();
}

class SupabaseEventRepository implements EventRepository {
  SupabaseEventRepository();

  @override
  Future<List<EventModel>> getEvents() async {
    // Return mock data for now until Supabase is populated
    return [
      EventModel(
        id: '1',
        title: 'Summer Roof Party',
        description: 'Join us for an amazing rooftop party with great music and vibes.',
        startDate: DateTime.now().add(const Duration(days: 2, hours: 18)),
        endDate: DateTime.now().add(const Duration(days: 2, hours: 22)),
        location: 'Downtown Rooftop, NY',
        price: 20.0,
        imageUrl: 'https://images.unsplash.com/photo-1514525253440-b393452e2729?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        organizerId: 'user1',
        likes: 124,
        views: 1024,
      ),
      EventModel(
        id: '2',
        title: 'Tech Meetup 2024',
        description: 'Networking event for tech enthusiasts and developers.',
        startDate: DateTime.now().add(const Duration(days: 5, hours: 9)),
        endDate: DateTime.now().add(const Duration(days: 5, hours: 12)),
        location: 'Tech Hub, SF',
        price: 0.0,
        imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        organizerId: 'user2',
        likes: 85,
        views: 856,
      ),
      EventModel(
        id: '3',
        title: 'Art Workshop',
        description: 'Learn painting basics with professional artists.',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: null,
        isAllDay: true,
        location: 'Art Studio, Chicago',
        price: 50.0,
        imageUrl: 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        organizerId: 'user3',
        likes: 210,
        views: 432,
      ),
    ];
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return SupabaseEventRepository();
});

final eventsProvider = FutureProvider<List<EventModel>>((ref) {
  return ref.watch(eventRepositoryProvider).getEvents();
});
