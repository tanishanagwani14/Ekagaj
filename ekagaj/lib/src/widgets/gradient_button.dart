import 'package:flutter/material.dart';

import '../theme/ek_colors.dart';

enum GradientButtonVariant { primary, secondary }

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = GradientButtonVariant.primary,
    this.fullWidth = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final GradientButtonVariant variant;
  final bool fullWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    final buttonChild = Padding(
      padding: padding,
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: variant == GradientButtonVariant.primary ? Colors.white : EkColors.gray700,
            ),
        child: Center(child: child),
      ),
    );

    final content = switch (variant) {
      GradientButtonVariant.primary => DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [EkColors.blue500, EkColors.purple600],
            ),
            borderRadius: radius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D7C3AED),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: buttonChild,
        ),
      GradientButtonVariant.secondary => DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: EkColors.gray200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: buttonChild,
        ),
    };

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: content,
      ),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

