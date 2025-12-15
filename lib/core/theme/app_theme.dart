// ignore_for_file: unused_field
import 'package:flutter/material.dart';

enum AppPalette { matteLight, matteDark, luxury, clean, creamyDark }

class AppTheme {
  // --- Palette Definitions ---

  // 1. Matte Light (Textile Neomorphic Standard)
  // Light theme gradient: top-left → bottom-right (135°)
  static const Color _lightBgTop = Color(0xFFF4F5F7); // Light stop (top-left)
  static const Color _lightBgMid = Color(0xFFECEDEF); // Mid stop
  static const Color _lightBgBottom = Color(
    0xFFE2E3E6,
  ); // Dark stop (bottom-right)
  static const Color _lightSurface = Color(0xFFECEDEF); // Surface for cards
  static const Color _lightText = Color(0xFF2C3440);
  static const Color _lightAccent = Color(0xFF72808D);

  // 2. Matte Dark (Textile Neomorphic Standard)
  // Dark theme gradient: top-left → bottom-right (135°)
  static const Color _darkBgTop = Color(0xFF1C1C1E); // Light stop (top-left)
  static const Color _darkBgMid = Color(0xFF161618); // Mid stop
  static const Color _darkBgBottom = Color(
    0xFF0F0F12,
  ); // Dark stop (bottom-right)
  static const Color _darkSurface = Color(0xFF161618); // Surface for cards
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

  // Gradient color getters for background system
  static List<Color> get lightGradientColors => [
    _lightBgTop,
    _lightBgMid,
    _lightBgBottom,
  ];

  static List<Color> get darkGradientColors => [
    _darkBgTop,
    _darkBgMid,
    _darkBgBottom,
  ];

  // Legacy support (using mid color as single bg for theme canvasColor)
  static const Color lightBg = _lightBgMid;
  static const Color darkBg = _darkBgMid;

  /// Builds the standard textile neomorphic background following the three-layer Stack pattern:
  /// 1. Diagonal gradient (top-left → bottom-right, 135°)
  /// 2. Noise texture overlay
  /// 3. Content layer
  ///
  /// This method can be used in screens that need custom background implementations.
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
        // Layer 1: Diagonal Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? darkGradientColors : lightGradientColors,
            ),
          ),
        ),
        // Layer 2: Noise Texture Overlay
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
    required AppPalette palette,
    required ThemeMode mode,
    Color? accentColor,
  }) {
    final Color? overrideAccent = accentColor;
    final bool isLight = mode == ThemeMode.light;

    if (isLight) {
      // Light Theme (Textile Neomorphic Standard)
      return _buildTheme(
        brightness: Brightness.light,
        bg: _lightBgMid, // Use mid color for canvasColor (fallback)
        surface: _lightSurface,
        primary: overrideAccent ?? _lightAccent,
        text: _lightText,
      );
    }

    // Dark Theme (Textile Neomorphic Standard)
    return _buildTheme(
      brightness: Brightness.dark,
      bg: _darkBgMid, // Use mid color for canvasColor (fallback)
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
    final baseTheme =
        brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

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
      fontFamily: 'Adamina',
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      canvasColor: bg,
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
