import 'package:firebase_auth/firebase_auth.dart';

import 'user_repository.dart';

sealed class UsernameAuth {
  static String toSyntheticEmail(String username) {
    final cleaned = username.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '.');
    return '$cleaned@ekagaj.local';
  }

  /// Signs in with Firebase Auth (synthetic email) and requires a matching `users/{uid}` row.
  static Future<void> signInWithUsernamePassword({
    required String username,
    required String password,
  }) async {
    final email = toSyntheticEmail(username);
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    final profile = await UserRepository.fetchCurrentUser();
    if (profile == null || !profile.exists) {
      await FirebaseAuth.instance.signOut();
      throw StateError('This account is not provisioned. Contact your administrator.');
    }
  }
}

