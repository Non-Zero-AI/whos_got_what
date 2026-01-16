import 'dart:ui';
import 'package:flutter/material.dart';

/// A container that implements the "Liquid Glass" aesthetic:
/// - Frosted transparency (blur radius 20–25px)
/// - Gradient overlays (light → transparent)
/// - Rounded containers (radius 20–30px)
/// - Floating shadows (soft depth)
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.blur = 25.0,
    this.borderRadius = 24.0,
    this.color,
    this.gradient,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default frosted color if not provided
    final glassColor = color ?? (isDark 
        ? Colors.white.withValues(alpha: 0.05) 
        : Colors.white.withValues(alpha: 0.7));

    // Default border if not provided
    final glassBorder = border ?? Border.all(
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
      width: 0.5,
    );

    // Default glass gradient
    final glassGradient = gradient ?? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        (isDark ? Colors.white : Colors.white).withValues(alpha: 0.1),
        (isDark ? Colors.white : Colors.white).withValues(alpha: 0.0),
      ],
    );

    // Default shadows
    final glassShadows = boxShadow ?? [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
    ];

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: glassColor,
        gradient: glassGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: glassBorder,
        boxShadow: glassShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
