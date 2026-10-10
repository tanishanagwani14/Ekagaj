import 'package:flutter/material.dart';

import 'routes/ek_routes.dart';
import 'theme/app_preferences.dart';
import 'theme/ek_theme.dart';
import 'widgets/auth_gate.dart';

class EkagajApp extends StatelessWidget {
  const EkagajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppPreferences.themeMode,
        builder: (context, mode, _) {
          return MaterialApp(
            title: 'Ekagaj',
            debugShowCheckedModeBanner: false,
            theme: EkTheme.light(),
            darkTheme: EkTheme.dark(),
            themeMode: mode,
            initialRoute: EkRoutes.home,
            onGenerateRoute: EkRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
