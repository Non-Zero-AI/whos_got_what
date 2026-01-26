import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class DevModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Default to true in debug mode so user has full access immediately
    return kDebugMode;
  }

  void toggle() {
    state = !state;
  }

  void setEnabled(bool enabled) {
    state = enabled;
  }
}

final devModeProvider = NotifierProvider<DevModeNotifier, bool>(DevModeNotifier.new);
