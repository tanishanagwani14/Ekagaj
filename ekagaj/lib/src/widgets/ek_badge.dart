import 'package:flutter/material.dart';

import '../theme/ek_colors.dart';

enum EkBadgeVariant { primary, success, warning, danger, info }

class EkBadge extends StatelessWidget {
  const EkBadge(
    this.text, {
    super.key,
    this.variant = EkBadgeVariant.primary,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 999,
    this.background,
    this.foreground,
  });

  final String text;
  final EkBadgeVariant variant;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colorsFor(variant);
    final effectiveBg = background ?? bg;
    final effectiveFg = foreground ?? fg;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: effectiveFg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (Color, Color) _colorsFor(EkBadgeVariant v) {
    return switch (v) {
      EkBadgeVariant.primary => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      EkBadgeVariant.success => (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      EkBadgeVariant.warning => (const Color(0xFFFFEDD5), const Color(0xFF9A3412)),
      EkBadgeVariant.danger => (const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
      EkBadgeVariant.info => (const Color(0xFFF3E8FF), EkColors.purple600),
    };
  }
}

