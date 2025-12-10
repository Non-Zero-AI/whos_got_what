import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final ThemeMode mode;
  final Color accentColor;

  const ThemeState({
    required this.mode,
    required this.accentColor,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    Color? accentColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState(
      mode: ThemeMode.system,
      accentColor: Color(0xFF6200EE), // Default accent
    );
  }

  void toggleTheme(bool isDark) {
    state = state.copyWith(mode: isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
