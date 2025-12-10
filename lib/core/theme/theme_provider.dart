import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

class ThemeState {
  final AppPalette palette;

  const ThemeState({
    this.palette = AppPalette.matteLight, // Default
  });

  ThemeState copyWith({
    AppPalette? palette,
  }) {
    return ThemeState(
      palette: palette ?? this.palette,
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
  
  // Helper to toggle between simple light/dark map if we want basic toggling, 
  // but for now we expose setPalette.
  void toggleSimpleMode() {
    if (state.palette == AppPalette.matteLight) {
        state = state.copyWith(palette: AppPalette.matteDark);
    } else {
        state = state.copyWith(palette: AppPalette.matteLight);
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
