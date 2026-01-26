import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:whos_got_what/features/events/domain/models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents();
  Future<EventModel?> getEventById(String id);
  Future<List<EventModel>> getEventsByCreator(String creatorId);
  Future<EventModel> createEvent({
    required String creatorId,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isAllDay,
    required String imageUrl,
    String? location,
    double? price,
    String? ticketUrl,
    String? linkUrl,
    String? recurrence,
    double? latitude,
    double? longitude,
    String? postType,
  });
  Future<List<EventModel>> searchEvents(String query);
  Future<void> toggleBookmark(String userId, String eventId);
  Future<void> toggleLike(String userId, String eventId);
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates);
  Future<void> deleteEvent(String eventId);
  Future<void> archiveExpiredEvents();
  Future<List<EventModel>> getBookmarkedEvents(String userId);
}

class SupabaseEventRepository implements EventRepository {
  final SupabaseClient _supabase;

  SupabaseEventRepository(this._supabase);

  EventModel _fromRow(Map<String, dynamic> row) {
    final id = (row['id'] as String).toString();
    final title = (row['title'] as String?) ?? '';
    final description = (row['description'] as String?) ?? '';

    final startTimeRaw = row['start_time'];
    final endTimeRaw = row['end_time'];

    DateTime parseTs(dynamic v) {
      if (v is DateTime) return v;
      return DateTime.parse(v as String);
    }

    final startTime = parseTs(startTimeRaw);
    final endTime = parseTs(endTimeRaw);

    final isAllDay = (row['is_all_day'] as bool?) ?? false;
    final imageUrl =
        (row['image_url'] as String?) ??
        'https://placehold.co/1000x800/png?text=Event';

    final location = (row['location'] as String?) ?? '';
    final price = (row['price'] as num?)?.toDouble() ?? 0.0;

    final creatorId = (row['creator_id'] as String?) ?? '';

    final lat = (row['latitude'] as num?)?.toDouble();
    final lon = (row['longitude'] as num?)?.toDouble();

    return EventModel(
      id: id,
      title: title,
      description: description,
      startDate: startTime,
      endDate: isAllDay ? null : endTime,
      isAllDay: isAllDay,
      location: location,
      price: price,
      imageUrl: imageUrl,
      organizerId: creatorId,
      views: 0,
      likes: (row['likes_count'] as int?) ?? 0,
      bookmarksCount: (row['bookmarks_count'] as int?) ?? 0,
      isBookmarked: (row['is_bookmarked'] as bool?) ?? false,
      recurrence: row['recurrence'] as String?,
      latitude: lat,
      longitude: lon,
      postType: (row['post_type'] as String?) ?? 'event',
    );
  }

  @override
  Future<List<EventModel>> getEvents() async {
    // First archive expired events
    await archiveExpiredEvents();

    final response = await _supabase
        .from('events')
        .select()
        .order('created_at', ascending: false); // Most recent first

    final data = response as List<dynamic>;
    return (data as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_fromRow)
        .toList();
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    final row =
        await _supabase.from('events').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromRow(row);
  }

  @override
  Future<List<EventModel>> getEventsByCreator(String creatorId) async {
    final rows = await _supabase
        .from('events')
        .select()
        .eq('creator_id', creatorId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_fromRow)
        .toList();
  }

  @override
  Future<EventModel> createEvent({
    required String creatorId,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isAllDay,
    required String imageUrl,
    String? location,
    double? price,
    String? ticketUrl,
    String? linkUrl,
    String? recurrence,
    double? latitude,
    double? longitude,
    String? postType,
  }) async {
    Map<String, dynamic> payload = {
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_all_day': isAllDay,
      if (location != null && location.trim().isNotEmpty)
        'location': location.trim(),
      if (price != null) 'price': price,
      if (ticketUrl != null && ticketUrl.trim().isNotEmpty)
        'ticket_url': ticketUrl.trim(),
      if (linkUrl != null && linkUrl.trim().isNotEmpty)
        'link_url': linkUrl.trim(),
      'recurrence': recurrence ?? 'none',
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'plan_visibility': 'public', // Default ...
      'credits_required': 0,
      'total_slots': 0,
      'post_type': postType ?? 'event',
    };

    try {
      final row =
          await _supabase.from('events').insert(payload).select().single();
      return _fromRow(row);
    } on PostgrestException catch (e) {
      // Best-effort compatibility with older schemas missing optional columns.
      final msg = e.message.toLowerCase();
      final missingColumn =
          msg.contains('column') && msg.contains('does not exist');
      if (!missingColumn) rethrow;

      payload =
          Map<String, dynamic>.from(payload)
            ..remove('location')
            ..remove('price')
            ..remove('ticket_url')
            ..remove('link_url');

      final row =
          await _supabase.from('events').insert(payload).select().single();
      return _fromRow(row);
    }
  }

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    if (query.isEmpty) return getEvents();

    // Search in title and description
    final rows = await _supabase
        .from('events')
        .select()
        .or('title.ilike.%$query%,description.ilike.%$query%')
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_fromRow)
        .toList();
  }

  @override
  Future<void> toggleBookmark(String userId, String eventId) async {
    final exists =
        await _supabase.from('bookmarks').select().match({
          'user_id': userId,
          'event_id': eventId,
        }).maybeSingle();

    if (exists != null) {
      await _supabase.from('bookmarks').delete().match({
        'user_id': userId,
        'event_id': eventId,
      });
    } else {
      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'event_id': eventId,
      });
    }
  }

  @override
  Future<void> toggleLike(String userId, String eventId) async {
    final exists =
        await _supabase.from('likes').select().match({
          'user_id': userId,
          'event_id': eventId,
        }).maybeSingle();

    if (exists != null) {
      await _supabase.from('likes').delete().match({
        'user_id': userId,
        'event_id': eventId,
      });
    } else {
      await _supabase.from('likes').insert({
        'user_id': userId,
        'event_id': eventId,
      });
    }
  }

  @override
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    await _supabase.from('events').update(updates).eq('id', eventId);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _supabase.from('events').delete().eq('id', eventId);
  }

  // Archive events that have ended
  @override
  Future<void> archiveExpiredEvents() async {
    final now = DateTime.now();
    await _supabase
        .from('events')
        .update({'archived': true})
        .lt('end_time', now.toIso8601String())
        .eq('archived', false);
  }

  @override
  Future<List<EventModel>> getBookmarkedEvents(String userId) async {
    final response = await _supabase
        .from('bookmarks')
        .select('events(*)')
        .eq('user_id', userId);

    final data = response as List<dynamic>;
    return data
        .where((row) => row['events'] != null)
        .map((row) => _fromRow(row['events'] as Map<String, dynamic>))
        .toList();
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return SupabaseEventRepository(Supabase.instance.client);
});

final eventsProvider = FutureProvider<List<EventModel>>((ref) {
  return ref.watch(eventRepositoryProvider).getEvents();
});

final eventByIdProvider = FutureProvider.family<EventModel?, String>((ref, id) {
  return ref.watch(eventRepositoryProvider).getEventById(id);
});
