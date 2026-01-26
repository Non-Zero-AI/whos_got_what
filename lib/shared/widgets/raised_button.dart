import 'package:flutter/material.dart';

class RaisedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final LinearGradient? gradient;
  
  const RaisedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 50,
    this.borderRadius,
    this.gradient,
  });

  @override
  State<RaisedButton> createState() => _RaisedButtonState();
}

class _RaisedButtonState extends State<RaisedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Default gradient based on primary color
    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary.withValues(alpha: 0.8),
        colorScheme.primary,
      ],
    );

    final effectiveGradient = widget.gradient ?? defaultGradient;
    final radius = widget.borderRadius ?? BorderRadius.circular(16);
    
    // Neumorphic shadow parameters based on Tier 1
    final blurRadius = _isPressed ? 4.0 : 8.0;
    final spreadRadius = 0.0;
    final offset = _isPressed ? 2.0 : 4.0;
    
    // Shadow colors that match background brightness and Tier 1 specs (12% opacity)
    final darkShadowColor = isDark
        ? Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.12)
        : Colors.black.withValues(alpha: _isPressed ? 0.05 : 0.08);
    
    final lightShadowColor = isDark
        ? Colors.white.withValues(alpha: _isPressed ? 0.02 : 0.03)
        : Colors.white.withValues(alpha: _isPressed ? 0.3 : 0.5);
    
    // Shadow offsets: Single directional shadow for Matte feel
    final darkOffset = Offset(0, offset);
    final lightOffset = const Offset(0, -0.5);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: effectiveGradient,
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
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: theme.textTheme.labelLarge!.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
