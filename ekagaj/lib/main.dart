import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/ekagaj_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (DefaultFirebaseOptions.isConfigured) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else if (kDebugMode) {
      debugPrint(
        'Firebase is not configured. From the ekagaj folder run:\n'
        '  dart pub global activate flutterfire_cli\n'
        '  flutterfire configure -y\n'
        'Then rebuild. This generates lib/firebase_options.dart and native config files.',
      );
    }
  } catch (e, st) {
    debugPrint('Firebase init failed: $e\n$st');
  }
  runApp(const EkagajApp());
}
