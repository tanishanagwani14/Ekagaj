import 'package:flutter/material.dart';

import '../theme/ek_colors.dart';

class EkFab extends StatelessWidget {
  const EkFab({super.key, this.onPressed, this.bottom});

  final VoidCallback? onPressed;

  /// Distance from the bottom of the screen. Defaults above the bottom nav bar.
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final navClearance = MediaQuery.paddingOf(context).bottom + 112;
    return Positioned(
      right: 24,
      bottom: bottom ?? navClearance,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [EkColors.blue500, EkColors.purple600],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D7C3AED),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

