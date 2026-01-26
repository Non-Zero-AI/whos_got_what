import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple notifier that emits a timestamp whenever a scroll-to-top is requested.
class ScrollNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void scrollToTop() {
    state = DateTime.now().millisecondsSinceEpoch;
  }
}

final profileScrollToTopProvider = NotifierProvider<ScrollNotifier, int>(ScrollNotifier.new);
final homeScrollToTopProvider = NotifierProvider<ScrollNotifier, int>(ScrollNotifier.new);
