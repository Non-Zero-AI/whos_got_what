import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeState {
  final AppPalette palette;
  final ThemeMode mode;
  final Color? accentColor;

  const ThemeState({
    this.palette = AppPalette.matteLight,
    this.mode = ThemeMode.light,
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
  static const String _isDarkKey = 'is_dark';
  bool _isInitialized = false;

  @override
  ThemeState build() {
    if (!_isInitialized) {
      _isInitialized = true;
      _loadThemePreference();
    }
    return const ThemeState();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_isDarkKey);
      if (isDark != null) {
        state = state.copyWith(mode: isDark ? ThemeMode.dark : ThemeMode.light);
      }
    } catch (e) {
      // If loading fails, use default (light theme)
      debugPrint('Error loading theme preference: $e');
    }
  }

  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDarkKey, isDark);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  void setPalette(AppPalette palette) {
    state = state.copyWith(palette: palette);
  }

  void toggleTheme(bool isDark) {
    state = state.copyWith(mode: isDark ? ThemeMode.dark : ThemeMode.light);
    _saveThemePreference(isDark);
  }

  void setAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
