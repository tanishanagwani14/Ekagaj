import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/ekagaj_app.dart';
import 'src/config/backend_config.dart';
import 'src/services/reminder_alarm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  await ReminderAlarmService.init();
  runApp(const EkagajApp());
}

Future<void> _initializeFirebase() async {
  if (!BackendConfig.useFirebase) {
    if (kDebugMode) {
      debugPrint('Firestore disabled (local mode).');
    }
    return;
  }

  if (!DefaultFirebaseOptions.isConfigured) {
    if (kDebugMode) {
      debugPrint(
        'Firebase is not configured. From the ekagaj folder run:\n'
        '  dart pub global activate flutterfire_cli\n'
        '  flutterfire configure\n'
        'Then rebuild.',
      );
    }
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    if (kDebugMode) {
      debugPrint('Firebase initialized (${DefaultFirebaseOptions.android.projectId}).');
    }
  } catch (e, st) {
    debugPrint('Firebase init failed: $e\n$st');
  }
}
