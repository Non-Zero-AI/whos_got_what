import 'package:flutter/material.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';

/// MatteCard - Deprecated wrapper for NeumorphicContainer
/// Use NeumorphicContainer directly for new code
@Deprecated('Use NeumorphicContainer instead')
class MatteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double? width;
  final double? height;

  const MatteCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      surfaceColor: color,
      child: child,
    );
  }
}
