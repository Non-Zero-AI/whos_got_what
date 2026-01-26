import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode mode;

  const ThemeState({this.mode = ThemeMode.dark});

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
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
    return const ThemeState(mode: ThemeMode.dark);
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_isDarkKey);

      ThemeMode mode = ThemeMode.dark;
      if (isDark != null) {
        mode = isDark ? ThemeMode.dark : ThemeMode.light;
      }

      state = state.copyWith(mode: mode);
    } catch (e) {
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

  void toggleTheme(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(mode: newMode);
    _saveThemePreference(isDark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
