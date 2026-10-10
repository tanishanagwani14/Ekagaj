import 'package:flutter/material.dart';

import '../../services/app_session.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/gradient_header.dart';

class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.body,
    this.showLogout = false,
  });

  final String title;
  final String body;
  final bool showLogout;

  static void openPrivacy(BuildContext context) {
    _push(
      context,
      title: 'Privacy Settings',
      body:
          'Control how your data is used within Ekagaj.\n\n'
          '• Profile visibility: Team members in your organization\n'
          '• Activity data: Used for attendance and task reports\n'
          '• Notifications: Optional alerts for tasks and messages\n\n'
          'Contact your administrator to change organization-wide policies.',
    );
  }

  static void openHelp(BuildContext context) {
    _push(
      context,
      title: 'Help Center',
      body:
          'Need help using Ekagaj?\n\n'
          '• Home: Quick overview of your day\n'
          '• Tasks: Create and filter tasks from the Tasks tab\n'
          '• Attendance: View monthly attendance summary\n'
          '• Messages: Real-time team chat via Firebase\n'
          '• Admin: Add employees from Profile → Admin Panel\n\n'
          'For technical issues, contact your IT administrator.',
    );
  }

  static void openAbout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SettingsDetailScreen(
          title: 'About Ekagaj',
          showLogout: true,
          body:
              'Ekagaj — Modern Organization Management\n\n'
              'Version 1.0.0\n\n'
              'Built for teams to manage attendance, tasks, messaging, and employee records in one place.\n\n'
              'Sign out below when you are done for the day.',
        ),
      ),
    );
  }

  static void _push(BuildContext context, {required String title, required String body}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsDetailScreen(title: title, body: body),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await AppSession.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GradientHeader(
            colors: const [EkColors.blue500, EkColors.purple600],
            child: Row(
              children: [
                _BackButton(),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.ekTextPrimary,
                        height: 1.5,
                      ),
                ),
                if (showLogout) ...[
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}
