import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'password_hasher.dart';
import 'user_repository.dart';
import 'user_roles.dart';
import 'username_auth.dart';

sealed class AdminEmployeeService {
  static Future<void> createEmployee({
    required String username,
    required String password,
    required String displayName,
    required String department,
    String role = UserRoles.employee,
  }) async {
    final normalized = UserRepository.normalizeUsername(username);
    if (normalized.isEmpty) {
      throw ArgumentError('Username is required.');
    }

    final primaryApp = Firebase.app();
    final secondary = await Firebase.initializeApp(
      name: 'secondary-admin-${DateTime.now().microsecondsSinceEpoch}',
      options: primaryApp.options,
    );

    UserCredential? cred;
    try {
      final auth = FirebaseAuth.instanceFor(app: secondary);
      final email = UsernameAuth.toSyntheticEmail(username);
      cred = await auth.createUserWithEmailAndPassword(email: email, password: password);

      final uid = cred.user?.uid;
      if (uid == null) {
        throw StateError('Failed to create user.');
      }

      final passwordHash = PasswordHasher.hash(password);
      final userRef = UserRepository.userDoc(uid);
      final nameRef = UserRepository.usernameDoc(normalized);

      await FirebaseFirestore.instance.runTransaction((txn) async {
        final taken = await txn.get(nameRef);
        if (taken.exists) {
          throw StateError('Username is already taken.');
        }
        txn.set(nameRef, {'uid': uid});
        txn.set(userRef, {
          'uid': uid,
          'username': username.trim(),
          'usernameNormalized': normalized,
          'displayName': displayName.trim(),
          'department': department.trim(),
          'role': role,
          'passwordHash': passwordHash,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {
      try {
        await cred?.user?.delete();
      } catch (_) {}
      rethrow;
    } finally {
      try {
        await FirebaseAuth.instanceFor(app: secondary).signOut();
      } catch (_) {}
      await secondary.delete();
    }
  }
}
