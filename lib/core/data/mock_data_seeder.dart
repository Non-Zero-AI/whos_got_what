import 'package:supabase_flutter/supabase_flutter.dart';

class MockDataService {
  final SupabaseClient _supabase;

  MockDataService(this._supabase);

  Future<void> seedEvents() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final events = [
      {
        'creator_id': user.id,
        'title': 'Central Park Yoga',
        'description': 'Morning wellness session in the heart of the city. Bring your own mat!',
        'image_url': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=800&q=80',
        'start_time': DateTime.now().add(const Duration(days: 15, hours: 8)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 15, hours: 9, minutes: 30)).toIso8601String(),
        'is_all_day': false,
        'location': 'Sheep Meadow, Central Park',
        'price': 15.0,
      },
      {
        'creator_id': user.id,
        'title': 'Indie Film Festival',
        'description': 'Premiere of the latest independent shorts from around the world.',
        'image_url': 'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=800&q=80',
        'start_time': DateTime.now().add(const Duration(days: 20, hours: 18)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 20, hours: 22)).toIso8601String(),
        'is_all_day': false,
        'location': 'Metro Cinema, Downtown',
        'price': 25.0,
      },
      {
        'creator_id': user.id,
        'title': 'Gourmet Food Market',
        'description': 'Sample the finest local artisanal cheeses, breads, and wines.',
        'image_url': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
        'start_time': DateTime.now().add(const Duration(days: 5, hours: 10)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 5, hours: 16)).toIso8601String(),
        'is_all_day': true,
        'location': 'Union Square',
        'price': 0.0,
      },
      {
        'creator_id': user.id,
        'title': 'Tech Meetup: Web3',
        'description': 'Network with builders and thinkers in the Web3 space. Drinks provided.',
        'image_url': 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=800&q=80',
        'start_time': DateTime.now().add(const Duration(days: 12, hours: 19)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 12, hours: 21)).toIso8601String(),
        'is_all_day': false,
        'location': 'Innovation Hub, Floor 4',
        'price': 0.0,
      },
    ];

    for (final event in events) {
      try {
        await _supabase.from('events').insert(event);
      } on PostgrestException catch (e) {
        final msg = e.message.toLowerCase();
        if (msg.contains('column') && msg.contains('does not exist')) {
          final strippedEvent = Map<String, dynamic>.from(event)
            ..remove('location')
            ..remove('price');
          await _supabase.from('events').insert(strippedEvent);
        } else {
          rethrow;
        }
      }
    }
  }
}
