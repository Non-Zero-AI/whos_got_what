import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

class ThemeState {
  final AppPalette palette;
  final ThemeMode mode;
  final Color? accentColor;

  const ThemeState({
    this.palette = AppPalette.matteDark,
    this.mode = ThemeMode.dark,
    this.accentColor,
  });

  ThemeState copyWith({
    AppPalette? palette,
    ThemeMode? mode,
    Color? accentColor,
  }) {
    return ThemeState(
      palette: palette ?? this.palette,
      mode: mode ?? this.mode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState();
  }

  void setPalette(AppPalette palette) {
    state = state.copyWith(palette: palette);
  }

  void toggleTheme(bool isDark) {
    state = state.copyWith(mode: isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
