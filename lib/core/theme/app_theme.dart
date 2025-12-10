import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppPalette {
  matteLight,
  matteDark,
  luxury,
  clean,
  creamyDark,
}

class AppTheme {
  // --- Palette Definitions ---

  // 1. Matte Light
  static const Color _lightBg = Color(0xFFE0E5EC);
  static const Color _lightSurface = Color(0xFFF0F3F7);
  static const Color _lightText = Color(0xFF4A5568);
  static const Color _lightAccent = Color(0xFF667EEA);

  // 2. Matte Dark
  static const Color _darkBg = Color(0xFF212529);
  static const Color _darkSurface = Color(0xFF2D3238);
  static const Color _darkText = Color(0xFFE2E8F0);
  static const Color _darkAccent = Color(0xFF81E6D9);

  // 3. Luxury (Navy & Gold)
  static const Color _navyBg = Color(0xFF001F3F);
  static const Color _navySurface = Color(0xFF003366);
  static const Color _luxuryText = Color(0xFFF5E8D8);
  static const Color _goldAccent = Color(0xFFC5A059);

  // 4. Clean (White & Navy)
  static const Color _cleanBg = Color(0xFFFFFFFF);
  static const Color _cleanSurface = Color(0xFFF9FAFB);
  static const Color _cleanText = Color(0xFF001F3F);
  static const Color _cleanAccent = Color(0xFF1D3557);

  // 5. Creamy Dark
  static const Color _creamyBg = Color(0xFF1C1C1C);
  static const Color _creamySurface = Color(0xFF2C2C2C);
  static const Color _creamyText = Color(0xFFF5E8D8);
  static const Color _warmAccent = Color(0xFFDAA520);


  static ThemeData getTheme({
    required AppPalette palette,
    required ThemeMode mode,
    Color? accentColor,
  }) {
    // If we want detailed mapping:
    // We can say if mode == dark, force a dark palette if 'palette' is matteLight.
    // Or we simply respect 'palette' as the source of truth for high-level "scheme".
    // For now, let's just use the palette as the base, and allow accent override.

    final Color? overrideAccent = accentColor;

    switch (palette) {
      case AppPalette.matteLight:
        return _buildTheme(
          brightness: Brightness.light,
          bg: _lightBg,
          surface: _lightSurface,
          primary: overrideAccent ?? _lightAccent,
          text: _lightText,
        );
      case AppPalette.matteDark:
        return _buildTheme(
          brightness: Brightness.dark,
          bg: _darkBg,
          surface: _darkSurface,
          primary: overrideAccent ?? _darkAccent,
          text: _darkText,
        );
      case AppPalette.luxury:
        return _buildTheme(
          brightness: Brightness.dark,
          bg: _navyBg,
          surface: _navySurface,
          primary: overrideAccent ?? _goldAccent,
          text: _luxuryText,
        );
      case AppPalette.clean:
        return _buildTheme(
          brightness: Brightness.light,
          bg: _cleanBg,
          surface: _cleanSurface,
          primary: overrideAccent ?? _cleanAccent,
          text: _cleanText,
        );
      case AppPalette.creamyDark:
        return _buildTheme(
          brightness: Brightness.dark,
          bg: _creamyBg,
          surface: _creamySurface,
          primary: overrideAccent ?? _warmAccent,
          text: _creamyText,
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color primary,
    required Color text,
  }) {
    final baseTextTheme = GoogleFonts.interTextTheme(
      brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        surface: surface,
        onSurface: text,
        background: bg,
        onBackground: text,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
      // Add other global component overrides here as needed
    );
  }
}
