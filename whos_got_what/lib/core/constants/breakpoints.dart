import 'package:flutter/material.dart';

/// Centralized breakpoint constants for responsive design.
/// Breakpoints are content-based, not device-specific.
class Breakpoints {
  Breakpoints._();

  /// Compact layout threshold (mobile-first)
  /// Below this width, use single-column, linear layouts
  static const double compact = 600;

  /// Medium layout threshold (tablet)
  /// Between compact and expanded, use adaptive layouts
  static const double medium = 900;

  /// Expanded layout threshold (desktop)
  /// Above this width, use multi-column, information-rich layouts
  static const double expanded = 1200;

  /// Large layout threshold (wide desktop)
  /// Above this width, maximize information density
  static const double large = 1600;

  /// Check if current width is compact (mobile)
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compact;
  }

  /// Check if current width is medium (tablet)
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compact && width < expanded;
  }

  /// Check if current width is expanded (desktop)
  static bool isExpanded(BuildContext context) {
    return MediaQuery.of(context).size.width >= expanded;
  }

  /// Check if current width is large (wide desktop)
  static bool isLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= large;
  }

  /// Get current layout class
  static LayoutClass getLayoutClass(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compact) return LayoutClass.compact;
    if (width < medium) return LayoutClass.medium;
    if (width < expanded) return LayoutClass.expanded;
    return LayoutClass.large;
  }
}

/// Layout class enumeration
enum LayoutClass {
  compact,
  medium,
  expanded,
  large,
}

