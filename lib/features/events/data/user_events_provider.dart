import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';

final userEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const <EventModel>[];

  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventsByCreator(user.id);
});

final userEventsByIdProvider = FutureProvider.family<List<EventModel>, String>((ref, userId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventsByCreator(userId);
});

final bookmarkedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const <EventModel>[];

  final repo = ref.watch(eventRepositoryProvider);
  return repo.getBookmarkedEvents(user.id);
});
