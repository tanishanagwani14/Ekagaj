import 'package:flutter/material.dart';

import '../screens/admin/admin_screen.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/followups/followups_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/first_admin_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/reminders/reminders_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/tasks/tasks_screen.dart';

sealed class EkRoutes {
  static const splash = '/';
  static const login = '/login';
  static const firstAdminSetup = '/setup-first-admin';
  static const home = '/home';
  static const attendance = '/attendance';
  static const tasks = '/tasks';
  static const chat = '/chat';
  static const followUps = '/follow-ups';
  static const reminders = '/reminders';
  static const profile = '/profile';
  static const admin = '/admin';
  static const notifications = '/notifications';
  static const settings = '/settings';

  static Route<void> onGenerateRoute(RouteSettings routeSettings) {
    final name = routeSettings.name ?? splash;

    Widget screen;
    switch (name) {
      case splash:
        screen = const SplashScreen();
        break;
      case login:
        screen = const LoginScreen();
        break;
      case firstAdminSetup:
        screen = const FirstAdminScreen();
        break;
      case home:
        screen = const HomeScreen();
        break;
      case attendance:
        screen = const AttendanceScreen();
        break;
      case tasks:
        screen = const TasksScreen();
        break;
      case chat:
        screen = const ChatScreen();
        break;
      case followUps:
        screen = const FollowUpsScreen();
        break;
      case reminders:
        screen = const RemindersScreen();
        break;
      case profile:
        screen = const ProfileScreen();
        break;
      case admin:
        screen = const AdminScreen();
        break;
      case notifications:
        screen = const NotificationsScreen();
        break;
      case settings:
        screen = const SettingsScreen();
        break;
      default:
        screen = const SplashScreen();
        break;
    }

    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (_) => screen,
    );
  }
}

