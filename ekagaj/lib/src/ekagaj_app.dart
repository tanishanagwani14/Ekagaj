import 'package:flutter/material.dart';

import 'routes/ek_routes.dart';
import 'theme/ek_theme.dart';

class EkagajApp extends StatelessWidget {
  const EkagajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekagaj',
      debugShowCheckedModeBanner: false,
      theme: EkTheme.light(),
      darkTheme: EkTheme.dark(),
      themeMode: ThemeMode.light,
      initialRoute: EkRoutes.splash,
      onGenerateRoute: EkRoutes.onGenerateRoute,
    );
  }
}

