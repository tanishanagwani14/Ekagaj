import 'package:flutter/material.dart';

import 'ek_colors.dart';

extension EkThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get ekTextPrimary => Theme.of(this).colorScheme.onSurface;

  Color get ekTextSecondary => Theme.of(this).colorScheme.onSurfaceVariant;

  Color get ekCardSurface => Theme.of(this).colorScheme.surface;

  Color get ekMutedSurface => isDark ? const Color(0xFF1F2937) : EkColors.gray100;

  Color get ekIconTileBg => isDark ? const Color(0xFF312E81) : const Color(0xFFF3E8FF);

  Color get ekProgressTrack => isDark ? const Color(0xFF374151) : EkColors.gray100;

  Color get ekNavBarSurface => Theme.of(this).colorScheme.surface;

  Color get ekNavBarBorder => isDark ? const Color(0xFF374151) : EkColors.gray200;

  Color get ekInputFill => isDark ? const Color(0xFF1F2937) : EkColors.gray100;
}
