import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';

class UserEventsNotifier extends Notifier<List<EventModel>> {
  @override
  List<EventModel> build() {
    return const [];
  }

  void add(EventModel event) {
    state = [...state, event];
  }
}

final userEventsProvider = NotifierProvider<UserEventsNotifier, List<EventModel>>(
  UserEventsNotifier.new,
);
