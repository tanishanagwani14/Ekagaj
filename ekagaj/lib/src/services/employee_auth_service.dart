import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../config/backend_config.dart';
import 'user_repository.dart';

/// Creates Firebase Auth logins for employees without signing out the admin.
sealed class EmployeeAuthService {
  static Future<void> createLoginForEmployee({
    required String email,
    required String password,
  }) async {
    if (!BackendConfig.useFirebase || !DefaultFirebaseOptions.isConfigured) {
      throw StateError('Firebase is not configured.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters.');
    }

    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'employee_auth_${DateTime.now().microsecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential credential;
      try {
        credential = await secondaryAuth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw StateError(
            'This email already has a login. The employee can sign in with their existing password.',
          );
        }
        rethrow;
      }

      final profile = await UserRepository.userDocByEmail(normalizedEmail);
      if (profile == null) {
        await credential.user?.delete();
        throw StateError('Employee profile not found. Please try adding the employee again.');
      }

      await profile.reference.set({
        'authUid': credential.user!.uid,
      }, SetOptions(merge: true));

      await secondaryAuth.signOut();
      if (kDebugMode) {
        debugPrint('Login created for $normalizedEmail');
      }
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }
}
