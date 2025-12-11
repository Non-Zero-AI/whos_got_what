import 'package:flutter/material.dart';

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
  static const Color _lightBg = Color(0xFFE6E9F0); // light counterpart of #3C424E
  static const Color _lightSurface = Color(0xFFF3F5F9); // light counterpart of #607282
  static const Color _lightText = Color(0xFF2C3440);
  static const Color _lightAccent = Color(0xFF72808D);

  // 2. Matte Dark
  static const Color _darkBg = Color(0xFF3C424E); // gradient start
  static const Color _darkSurface = Color(0xFF607282); // gradient end
  static const Color _darkText = Color(0xFFE6EDF5);
  static const Color _darkAccent = Color(0xFF72808D);

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

  static const Color _buttonBase = Color(0xFF444E5B);
  static const Color _buttonHighlight = Color(0xFF72808D);

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
    final baseTheme = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
      onSurface: text,
      background: bg,
      onBackground: text,
    );

    final ButtonStyle matteButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return _buttonBase.withOpacity(0.4);
        }
        if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
          return _buttonHighlight;
        }
        return _buttonBase;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(text),
      overlayColor: WidgetStateProperty.all<Color>(_buttonHighlight.withOpacity(0.1)),
      elevation: WidgetStateProperty.all<double>(0),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Adamina',
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      canvasColor: bg,
      cardColor: surface,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: matteButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: matteButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: matteButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(color: _buttonHighlight.withOpacity(0.7)),
          ),
        ),
      ),
      // Add other global component overrides here as needed
    );
  }
}
