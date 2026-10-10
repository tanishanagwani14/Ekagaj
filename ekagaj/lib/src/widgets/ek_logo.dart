import 'package:flutter/material.dart';

class EkLogo extends StatelessWidget {
  const EkLogo({
    super.key,
    this.height = 72,
    this.maxWidth = 200,
    this.onLightBackground = false,
  });

  final double height;
  final double maxWidth;

  /// When true, shows logo on a subtle white card (for gradient headers).
  final bool onLightBackground;

  static const assetPath = 'assets/images/ekagaj_logo.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.business_rounded,
        size: height * 0.6,
        color: onLightBackground ? const Color(0xFF1D4ED8) : Colors.white,
      ),
    );

    if (!onLightBackground) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: image,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: image,
        ),
      ),
    );
  }
}
