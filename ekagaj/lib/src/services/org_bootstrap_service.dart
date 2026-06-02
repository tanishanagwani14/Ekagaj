import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'password_hasher.dart';
import 'user_repository.dart';
import 'user_roles.dart';
import 'username_auth.dart';

/// `_metadata/setup_complete` — created when the first admin finishes onboarding.
sealed class OrgBootstrapService {
  static final _setupDoc = FirebaseFirestore.instance.collection('_metadata').doc('setup_complete');

  /// `true` if an admin has already completed first-time setup (or read failed — fail closed).
  static Future<bool> isOrganizationInitialized() async {
    try {
      final snap = await _setupDoc.get();
      return snap.exists;
    } catch (_) {
      return true;
    }
  }

  /// Creates Firebase Auth user, `users/{uid}` (admin), `usernames/{norm}`, and [setup_complete].
  /// Caller must not be signed in as another user (will sign out first).
  static Future<void> registerFirstAdmin({
    required String username,
    required String password,
    required String displayName,
    String department = '',
  }) async {
    final normalized = UserRepository.normalizeUsername(username);
    if (normalized.isEmpty) {
      throw ArgumentError('Username is required.');
    }

    await FirebaseAuth.instance.signOut();

    final email = UsernameAuth.toSyntheticEmail(username);
    UserCredential? cred;
    try {
      cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;
      if (uid == null) {
        throw StateError('Failed to create account.');
      }

      final passwordHash = PasswordHasher.hash(password);
      final userRef = UserRepository.userDoc(uid);
      final nameRef = UserRepository.usernameDoc(normalized);
      final metaRef = _setupDoc;

      await FirebaseFirestore.instance.runTransaction((txn) async {
        final meta = await txn.get(metaRef);
        if (meta.exists) {
          throw StateError('An administrator has already been set up. Sign in instead.');
        }
        final taken = await txn.get(nameRef);
        if (taken.exists) {
          throw StateError('Username is already taken.');
        }
        txn.set(metaRef, {
          'completed': true,
          'createdBy': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        txn.set(nameRef, {'uid': uid});
        txn.set(userRef, {
          'uid': uid,
          'username': username.trim(),
          'usernameNormalized': normalized,
          'displayName': displayName.trim(),
          'department': department.trim(),
          'role': UserRoles.admin,
          'passwordHash': passwordHash,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {
      try {
        await cred?.user?.delete();
      } catch (_) {}
      rethrow;
    }
  }
}
