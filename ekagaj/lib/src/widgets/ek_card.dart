import 'package:flutter/material.dart';

import '../theme/ek_colors.dart';
import '../theme/ek_theme_context.dart';

class EkCard extends StatelessWidget {
  const EkCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.variant = EkCardVariant.defaultCard,
    this.decoration,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EkCardVariant variant;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final baseDecoration = decoration ??
        BoxDecoration(
          color: context.ekCardSurface,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: const Color(0xFF374151)) : null,
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
        );

    final effectiveDecoration = switch (variant) {
      EkCardVariant.defaultCard => baseDecoration,
      EkCardVariant.gradient => baseDecoration.copyWith(
          gradient: EkColors.blueToPurple(),
          color: null,
          border: null,
        ),
    };

    final content = Container(
      decoration: effectiveDecoration,
      padding: padding,
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: content,
    );
  }
}

enum EkCardVariant { defaultCard, gradient }
