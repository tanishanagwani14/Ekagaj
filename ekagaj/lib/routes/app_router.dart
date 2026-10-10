import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../features/dashboard/presentation/dashboard_shell.dart';

sealed class AppRoutes {
  static const home = '/home';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => const MaterialPage(child: DashboardShell()),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('${AppConstants.appName} route not found: ${state.uri}'),
        ),
      ),
    ),
  );
}
