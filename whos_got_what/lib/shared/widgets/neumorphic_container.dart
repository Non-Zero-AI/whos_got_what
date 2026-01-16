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
    
    // Shadow parameters based on depth and pressed state
    final shadowIntensity = widget.depth;
    final blurRadius = pressed ? 8.0 : (12.0 + shadowIntensity * 4);
    final spreadRadius = pressed ? 0.0 : (1.0 + shadowIntensity * 0.5);
    final offset = pressed ? 2.0 : (6.0 + shadowIntensity * 2);
    
    // Calculate shadow colors based on theme brightness
    final darkShadowColor = isDark
        ? Colors.black.withValues(alpha: pressed ? 0.3 : 0.4)
        : Colors.black.withValues(alpha: pressed ? 0.05 : 0.1);
    
    final lightShadowColor = isDark
        ? Colors.white.withValues(alpha: pressed ? 0.02 : 0.05)
        : Colors.white.withValues(alpha: pressed ? 0.15 : 0.2);
    
    // Shadow offsets: dark (bottom-right), light (top-left)
    final darkOffset = pressed
        ? Offset(offset * 0.5, offset * 0.5) // Inset appearance
        : Offset(offset, offset);
    final lightOffset = pressed
        ? Offset(-offset * 0.5, -offset * 0.5) // Inset appearance
        : Offset(-offset, -offset);

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

