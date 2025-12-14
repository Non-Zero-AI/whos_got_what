// ignore_for_file: unused_field
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
  static const Color _lightBg = Color(0xFFFEFAE0); // Cream / Matcha Light
  static const Color _lightSurface = Color(0xFFFFFBF0); // Slightly lighter for cards
  static const Color _lightText = Color(0xFF2C3440);
  static const Color _lightAccent = Color(0xFF72808D);

  // 2. Matte Dark
  static const Color _darkBg = Color(0xFF171417); // Darkest part of gradient
  static const Color _darkBgLight = Color(0xFF221E22); // Lightest part of gradient
  static const Color _darkSurface = Color(0xFF2A2A2A); // Updated surface for better contrast
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

  static const Color lightBg = _lightBg;
  static const Color darkGradientStart = _darkBg;
  static const Color darkGradientEnd = _darkBgLight;

  static ThemeData getTheme({
    required AppPalette palette,
    required ThemeMode mode,
    Color? accentColor,
  }) {
    final Color? overrideAccent = accentColor;
    final bool isLight = mode == ThemeMode.light;

    if (isLight) {
      // Force Light Theme (Cream/Matte Light) if mode is Light
      return _buildTheme(
        brightness: Brightness.light,
        bg: _lightBg,
        surface: _lightSurface,
        primary: overrideAccent ?? _lightAccent,
        text: _lightText,
      );
    }

    // Otherwise use Dark Theme (Default to Matte Dark logic or respect palette if it's a dark one)
    // Since only Matte Dark is default, we return that.
    return _buildTheme(
      brightness: Brightness.dark,
      bg: _darkBg,
      surface: _darkSurface,
      primary: overrideAccent ?? _darkAccent,
      text: _darkText,
    );
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
    );

    final ButtonStyle matteButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return _buttonBase.withValues(alpha: 0.4);
        }
        if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
          return _buttonHighlight;
        }
        return _buttonBase;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(text),
      overlayColor: WidgetStateProperty.all<Color>(_buttonHighlight.withValues(alpha: 0.1)),
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
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      canvasColor: bg,
      cardColor: surface,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: matteButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: matteButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: matteButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(color: _buttonHighlight.withValues(alpha: 0.7)),
          ),
        ),
      ),
      // Add other global component overrides here as needed
    );
  }
}
