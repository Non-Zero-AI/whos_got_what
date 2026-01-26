import 'package:flutter/material.dart';

/// Neumorphic container widget following Agent Rules:
/// - Matches surface color to background color (same-surface rule)
/// - Dual shadows: dark (bottom-right) + light (top-left)
/// - Supports pressed/inset states
/// - Uses BoxDecoration.borderRadius
class NeumorphicContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? surfaceColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool isPressed;
  final double depth;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.surfaceColor,
    this.width,
    this.height,
    this.onTap,
    this.isPressed = false,
    this.depth = 1.0,
  });

  @override
  State<NeumorphicContainer> createState() => _NeumorphicContainerState();
}

class _NeumorphicContainerState extends State<NeumorphicContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Get background color from canvasColor (set in theme)
    final bgColor = theme.canvasColor;
    
    // Surface color matches background (same-surface rule)
    final surfaceColor = widget.surfaceColor ?? bgColor;
    
    // Determine if container should appear pressed
    final pressed = widget.isPressed || _isPressed;
    
    // Radius based on component role: cards use 20-24, buttons use 12-16
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    
    // Shadow parameters based on Tier 1 (8 radius, (0, 4) offset)
    final blurRadius = pressed ? 4.0 : 8.0;
    final spreadRadius = 0.0;
    final offset = pressed ? 2.0 : 4.0;
    
    // Calculate shadow colors based on theme brightness
    // Tier 1 uses 12% opacity for dark shadows
    final darkShadowColor = isDark
        ? Colors.black.withValues(alpha: pressed ? 0.08 : 0.12)
        : Colors.black.withValues(alpha: pressed ? 0.05 : 0.08);

    // Light highlight (top-left) should be subtle, especially in dark mode
    final lightShadowColor = isDark
        ? Colors.white.withValues(alpha: pressed ? 0.02 : 0.03)
        : Colors.white.withValues(alpha: pressed ? 0.4 : 0.6);
    
    // Shadow offsets: dark (bottom-right), light (top-left)
    final darkOffset = Offset(0, offset);
    final lightOffset = Offset(0, -0.5); // Sharpest possible thin top highlight

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: radius,
        boxShadow: [
          // Dark shadow (bottom-right)
          BoxShadow(
            color: darkShadowColor,
            offset: darkOffset,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
          // Light highlight (top-left)
          BoxShadow(
            color: lightShadowColor,
            offset: lightOffset,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: widget.child,
    );

    // Wrap with gesture detector if onTap is provided
    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) {
          if (!widget.isPressed) {
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) {
          if (!widget.isPressed) {
            setState(() => _isPressed = false);
          }
          widget.onTap?.call();
        },
        onTapCancel: () {
          if (!widget.isPressed) {
            setState(() => _isPressed = false);
          }
        },
        child: container,
      );
    }

    return container;
  }
}

