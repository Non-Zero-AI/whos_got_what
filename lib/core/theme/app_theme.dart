import 'package:flutter/material.dart';

class AppTheme {
  // --- Design Guide Color Palette ---

  // Core colors from design guide
  static const Color n8nBlue = Color(0xFF007AFF); // Primary Brand Blue
  static const Color n8nBlueDark = Color(0xFF0056B3); // Darker Blue for Gradients
  static const Color n8nDark = Color(0xFF040506);
  static const Color n8nGrey = Color(0xFF1F1F1F);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);

  // Light theme colors
  static const Color _lightBgTop = Color(0xFFF5F7F9);
  static const Color _lightBgBottom = Color(0xFFE6EDF5);
  static const Color _lightSurface = Colors.white;
  static const Color _lightText = Color(0xFF2D2D2D);
  static const Color _lightAccent = Color.fromARGB(255, 9, 138, 208);

  // Dark theme colors
  static const Color _darkBgTop = Color(0xFF1F1F1F);
  static const Color _darkBgBottom = Color(0xFF121212);
  static const Color _darkSurface = n8nGrey;
  static const Color _darkText = Color(0xFFE6EDF5);
  static const Color _darkAccent = Color.fromARGB(255, 8, 221, 232);

  static const Color _buttonBase = Color.fromARGB(255, 0, 213, 255);
  static const Color _buttonHighlight = n8nBlueDark;

  // Gradient color getters for background system
  static List<Color> get lightGradientColors => [_lightBgTop, _lightBgBottom];

  static List<Color> get darkGradientColors => [_darkBgTop, _darkBgBottom];

  // Legacy support (using surface color as single bg for theme canvasColor)
  static const Color lightBg = _lightSurface;
  static const Color darkBg = _darkSurface;

  /// Builds the standard matte background following the design guide:
  /// 1. Diagonal gradient (topCenter → bottomCenter)
  /// 2. Noise texture overlay
  /// 3. Content layer
  static Widget buildBackground({
    required BuildContext context,
    required Widget child,
    double? noiseOpacity,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Layer 1: Background Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark ? darkGradientColors : lightGradientColors,
            ),
          ),
        ),

        // Layer 2: Noise Texture Overlay
        Positioned.fill(
          child: Opacity(
            opacity: noiseOpacity ?? 0.03,
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

  static ThemeData getTheme({required ThemeMode mode, Color? accentColor}) {
    final Color? overrideAccent = accentColor;
    final bool isLight = mode == ThemeMode.light;

    if (isLight) {
      // Light Theme
      return _buildTheme(
        brightness: Brightness.light,
        bg: _lightBgTop,
        surface: _lightSurface,
        primary: overrideAccent ?? _lightAccent,
        text: _lightText,
      );
    }

    // Dark Theme
    return _buildTheme(
      brightness: Brightness.dark,
      bg: _darkBgTop,
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
    final bool isDark = brightness == Brightness.dark;
    final baseTheme =
        isDark ? ThemeData.dark() : ThemeData.light();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
      onSurface: text,
      primary: primary,
    );

    final ButtonStyle matteButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return primary.withValues(alpha: 0.4);
        }
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered)) {
          return isDark ? primary.withValues(alpha: 0.9) : primary.withValues(alpha: 0.85);
        }
        return primary;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(isDark ? Colors.white : Colors.white),
      elevation: WidgetStateProperty.resolveWith<double>((states) {
        if (states.contains(WidgetState.pressed)) return 2.0;
        return 4.0;
      }),
      shadowColor: WidgetStateProperty.all<Color>(
        isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.12),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter', // Updated to follow guide suggestions
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      canvasColor: isDark ? n8nGrey : _lightBgBottom,
      cardColor: surface,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: text,
        displayColor: text,
        fontFamily: 'Adamina',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: matteButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: matteButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: matteButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(color: primary.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}

