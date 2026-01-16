// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppPalette { matteLight, matteDark, luxury, clean, creamyDark }

class AppTheme {
  // --- Palette Definitions ---

  // Liquid Glass Palette
  static const Color background = Color(0xFFF5F8FA);
  static const Color tealAccent = Color(0xFF3CBCC3);
  static const Color amberAccent = Color(0xFFFFD580);
  static const Color lavenderAccent = Color(0xFFBCA3E0);

  // Surface colors
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _darkSurface = Color(0xFF1A1D21);
  
  // Text colors
  static const Color _lightText = Color(0xFF1E293B);
  static const Color _darkText = Color(0xFFF1F5F9);

  // Button colors
  static const Color _buttonBase = Color(0xFF334155);
  static const Color _buttonHighlight = tealAccent;

  // Background Gradients
  static List<Color> get lightGradientColors => [
    background,
    const Color(0xFFE2E8F0),
  ];

  static List<Color> get darkGradientColors => [
    const Color(0xFF0F172A),
    const Color(0xFF1E293B),
  ];

  /// Builds the Liquid Glass background:
  /// 1. Subtle directional gradient
  /// 2. Noise texture overlay (from memories)
  /// 3. Content layer
  static Widget buildBackground({
    required BuildContext context,
    required Widget child,
    double? noiseOpacity,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final opacity = noiseOpacity ?? (isDark ? 0.04 : 0.03);

    return Stack(
      children: [
        // Layer 1: Subtle Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? darkGradientColors : lightGradientColors,
            ),
          ),
        ),
        // Layer 2: Noise Texture Overlay (The Secret Weapon)
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              'assets/images/noise.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Layer 3: Content
        child,
      ],
    );
  }

  static ThemeData getTheme({
    required ThemeMode mode,
    Color? accentColor,
  }) {
    final bool isLight = mode == ThemeMode.light;

    if (isLight) {
      return _buildTheme(
        brightness: Brightness.light,
        bg: background,
        surface: _lightSurface,
        primary: accentColor ?? tealAccent,
        text: _lightText,
      );
    }

    return _buildTheme(
      brightness: Brightness.dark,
      bg: const Color(0xFF0F172A),
      surface: _darkSurface,
      primary: accentColor ?? tealAccent,
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
    final baseTheme =
        brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
      onSurface: text,
    );

    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
      bodyColor: text,
      displayColor: text,
    );

    final ButtonStyle matteButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return _buttonBase.withValues(alpha: 0.4);
        }
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered)) {
          return _buttonHighlight;
        }
        return _buttonBase;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(text),
      overlayColor: WidgetStateProperty.all<Color>(
        _buttonHighlight.withValues(alpha: 0.1),
      ),
      elevation: WidgetStateProperty.all<double>(0),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      canvasColor: bg,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: text,
        ),
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
    );
  }
}
