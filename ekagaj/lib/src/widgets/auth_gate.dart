import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';



import '../screens/login/login_screen.dart';

import '../services/app_session.dart';
import '../services/notification_realtime_service.dart';
import '../services/reminder_alarm_service.dart';

import '../theme/ek_theme.dart';



class AuthGate extends StatefulWidget {

  const AuthGate({super.key, required this.child});



  final Widget child;



  @override

  State<AuthGate> createState() => _AuthGateState();

}



class _AuthGateState extends State<AuthGate> {

  @override

  Widget build(BuildContext context) {

    return ValueListenableBuilder<bool>(
      valueListenable: AppSession.authenticating,
      builder: (context, isAuthenticating, _) {
        return StreamBuilder<User?>(
          stream: AppSession.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingApp();
            }

            final user = snapshot.data;
            if (user == null || isAuthenticating) {
              return const _LoginHost();
            }

            return _ProfileGate(user: user, child: widget.child);
          },
        );
      },
    );

  }

}



/// Ensures a Firestore profile exists for the signed-in Firebase user.

class _ProfileGate extends StatefulWidget {

  const _ProfileGate({required this.user, required this.child});



  final User user;

  final Widget child;



  @override

  State<_ProfileGate> createState() => _ProfileGateState();

}



class _ProfileGateState extends State<_ProfileGate> {

  bool _loading = true;



  @override

  void initState() {

    super.initState();

    _resolveProfile();

  }



  @override

  void didUpdateWidget(covariant _ProfileGate oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.uid != widget.user.uid) {

      _resolveProfile();

    }

  }



  Future<void> _resolveProfile() async {

    setState(() => _loading = true);



    if (AppSession.profile.value == null) {

      await AppSession.restoreSession();

    }



    if (!mounted) return;

    final profile = AppSession.profile.value;
    if (profile != null) {
      await ReminderAlarmService.syncPendingAlarms(userId: profile.id);
      await NotificationRealtimeService.start(profile.id);
    }



    if (AppSession.profile.value == null) {

      // Stale Firebase session with no Ekagaj profile — clear it so login appears.

      await AppSession.signOut();

      if (mounted) setState(() => _loading = false);

      return;

    }



    if (mounted) setState(() => _loading = false);

  }



  @override

  Widget build(BuildContext context) {

    if (_loading) {

      return const _LoadingApp(message: 'Loading your profile…');

    }



    return ValueListenableBuilder(

      valueListenable: AppSession.profile,

      builder: (context, profile, _) {

        if (profile == null) {

          return const _LoginHost();

        }

        return widget.child;

      },

    );

  }

}



class _LoadingApp extends StatelessWidget {

  const _LoadingApp({this.message});



  final String? message;



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: EkTheme.light(),

      home: Scaffold(

        body: Center(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const CircularProgressIndicator(),

              if (message != null) ...[

                const SizedBox(height: 16),

                Text(message!, style: Theme.of(context).textTheme.bodyMedium),

              ],

            ],

          ),

        ),

      ),

    );

  }

}



class _LoginHost extends StatelessWidget {

  const _LoginHost();



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: EkTheme.light(),

      darkTheme: EkTheme.dark(),

      home: const LoginScreen(),

    );

  }

}



/// Shown inside the main app when profile is missing (fallback).

class SessionSignInPrompt extends StatelessWidget {

  const SessionSignInPrompt({

    super.key,

    required this.title,

    required this.message,

  });



  final String title;

  final String message;



  Future<void> _goToLogin(BuildContext context) async {

    await AppSession.signOut();

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(Icons.login_rounded, size: 56, color: Theme.of(context).colorScheme.primary),

              const SizedBox(height: 20),

              Text(

                title,

                textAlign: TextAlign.center,

                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),

              ),

              const SizedBox(height: 12),

              Text(

                message,

                textAlign: TextAlign.center,

                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),

              ),

              const SizedBox(height: 28),

              FilledButton.icon(

                onPressed: () => _goToLogin(context),

                icon: const Icon(Icons.arrow_forward_rounded),

                label: const Text('Go to Sign In'),

                style: FilledButton.styleFrom(

                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}


