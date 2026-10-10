import 'package:flutter/material.dart';

/// App-wide preferences (theme, etc.) shared across screens.
sealed class AppPreferences {
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
}
