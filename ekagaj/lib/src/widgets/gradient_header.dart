import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.colors,
    required this.child,
    this.bottomRadius = 40,
    this.padding = const EdgeInsets.fromLTRB(24, 56, 24, 32),
  });

  final List<Color> colors;
  final Widget child;
  final double bottomRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bottomRadius),
          bottomRight: Radius.circular(bottomRadius),
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}

