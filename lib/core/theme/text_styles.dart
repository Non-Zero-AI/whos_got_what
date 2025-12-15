import 'package:flutter/material.dart';

/// Centralized text styles following semantic naming conventions.
/// All styles inherit from Theme.textTheme and override only what changes.
class AppTextStyles {
  AppTextStyles._();

  /// Primary headline style - for main titles and prominent headings
  static TextStyle headlinePrimary(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ) ??
        TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        );
  }

  /// Large title style - for section headers
  static TextStyle titleLarge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600) ??
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        );
  }

  /// Medium title style - for subsection headers
  static TextStyle titleMedium(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600) ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        );
  }

  /// Small title style - for minor headers
  static TextStyle titleSmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        );
  }

  /// Body text with emphasis - for important body content
  static TextStyle bodyEmphasis(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500) ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        );
  }

  /// Standard body text
  static TextStyle body(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium ??
        TextStyle(fontSize: 14, color: theme.colorScheme.onSurface);
  }

  /// Small body text
  static TextStyle bodySmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall ??
        TextStyle(fontSize: 12, color: theme.colorScheme.onSurface);
  }

  /// Muted caption text - for secondary information
  static TextStyle captionMuted(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
        ) ??
        TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        );
  }

  /// Secondary label text - for less prominent labels
  static TextStyle labelSecondary(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ) ??
        TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        );
  }

  /// Primary label text - for prominent labels
  static TextStyle labelPrimary(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        );
  }

  /// Event date/time label style
  static TextStyle eventDateTime(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ) ??
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        );
  }

  /// Event title style
  static TextStyle eventTitle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ) ??
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        );
  }

  /// Event location style
  static TextStyle eventLocation(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
        ) ??
        TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        );
  }

  /// Event description style
  static TextStyle eventDescription(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 13,
          height: 1.4,
        ) ??
        TextStyle(
          fontSize: 13,
          height: 1.4,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        );
  }

  /// Event metadata style (views, check-ins, etc.)
  static TextStyle eventMetadata(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 11,
        ) ??
        TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        );
  }
}
