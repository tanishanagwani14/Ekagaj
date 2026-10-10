import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import 'user_roles.dart';

/// Firestore helpers and profile loading for signed-in Firebase Auth users.
sealed class UserRepository {
  static const usersCollection = 'users';
  static const usernamesCollection = 'usernames';

  static UserProfile? _cached;

  static UserProfile? get cachedProfile => _cached;

  static void setCachedProfile(UserProfile? value) => _cached = value;

  static String normalizeUsername(String username) {
    return username.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  static bool isValidUsername(String username) {
    final normalized = normalizeUsername(username);
    if (normalized.isEmpty || normalized == '.' || normalized == '..') {
      return false;
    }
    if (normalized.contains('/')) return false;
    return RegExp(r'^[a-z0-9][a-z0-9._-]{0,59}$').hasMatch(normalized);
  }

  static DocumentReference<Map<String, dynamic>> newUserDoc() {
    return FirebaseFirestore.instance.collection(usersCollection).doc();
  }

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return FirebaseFirestore.instance.collection(usersCollection).doc(uid);
  }

  static DocumentReference<Map<String, dynamic>> usernameDoc(String normalizedUsername) {
    return FirebaseFirestore.instance.collection(usernamesCollection).doc(normalizedUsername);
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> userDocByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final snap = await FirebaseFirestore.instance
        .collection(usersCollection)
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first;
  }

  static Future<UserProfile?> loadProfileForAuthUser(User user) async {
    final email = user.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return null;

    final firestore = FirebaseFirestore.instance;

    final byAuth = await firestore
        .collection(usersCollection)
        .where('authUid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (byAuth.docs.isNotEmpty) {
      final doc = byAuth.docs.first;
      final profile = UserProfile.fromMap(doc.id, doc.data());
      _cached = profile;
      return profile;
    }

    final byEmail = await firestore
        .collection(usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (byEmail.docs.isEmpty) return null;

    final doc = byEmail.docs.first;
    await doc.reference.set({'authUid': user.uid}, SetOptions(merge: true));
    final profile = UserProfile.fromMap(doc.id, {...doc.data(), 'authUid': user.uid});
    _cached = profile;
    return profile;
  }

  static Future<void> createAdminProfile({
    required User authUser,
    required String displayName,
    required String username,
  }) async {
    final email = authUser.email?.trim().toLowerCase() ?? '';
    final normalized = normalizeUsername(username);
    if (!isValidUsername(username)) {
      throw ArgumentError('Choose a valid username.');
    }

    final firestore = FirebaseFirestore.instance;
    final existingEmail = await firestore
        .collection(usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (existingEmail.docs.isNotEmpty) {
      throw StateError('An account with this email already exists.');
    }

    final userRef = newUserDoc();
    final nameRef = usernameDoc(normalized);

    await firestore.runTransaction((txn) async {
      final taken = await txn.get(nameRef);
      if (taken.exists) throw StateError('Username is already taken.');

      txn.set(nameRef, {'uid': userRef.id});
      txn.set(userRef, {
        'uid': userRef.id,
        'authUid': authUser.uid,
        'email': email,
        'username': username.trim(),
        'usernameNormalized': normalized,
        'displayName': displayName.trim(),
        'department': 'Administration',
        'role': UserRoles.admin,
        'status': 'active',
        'attendance': '—',
        'tasksCompleted': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> linkEmployeeProfile({
    required User authUser,
    required String displayName,
    required String username,
  }) async {
    final email = authUser.email?.trim().toLowerCase() ?? '';
    final normalized = normalizeUsername(username);

    final firestore = FirebaseFirestore.instance;
    final pending = await firestore
        .collection(usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (pending.docs.isNotEmpty) {
      final doc = pending.docs.first;
      final role = (doc.data()['role'] as String?) ?? UserRoles.employee;
      if (UserRoles.isAdminRole(role)) {
        throw StateError('Use the Admin portal for this email.');
      }
      await doc.reference.set({
        'authUid': authUser.uid,
        'displayName': displayName.trim().isEmpty
            ? doc.data()['displayName'] ?? displayName
            : displayName.trim(),
      }, SetOptions(merge: true));
      return;
    }

    if (!isValidUsername(username)) {
      throw ArgumentError('Choose a valid username.');
    }

    final userRef = newUserDoc();
    final nameRef = usernameDoc(normalized);

    await firestore.runTransaction((txn) async {
      final taken = await txn.get(nameRef);
      if (taken.exists) throw StateError('Username is already taken.');

      txn.set(nameRef, {'uid': userRef.id});
      txn.set(userRef, {
        'uid': userRef.id,
        'authUid': authUser.uid,
        'email': email,
        'username': username.trim(),
        'usernameNormalized': normalized,
        'displayName': displayName.trim(),
        'department': 'General',
        'role': UserRoles.employee,
        'status': 'active',
        'attendance': '—',
        'tasksCompleted': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<String> fetchCurrentDisplayName() async {
    return _cached?.displayName ?? AppSessionFallback.displayName;
  }

  static Future<bool> currentUserIsAdmin() async {
    return UserRoles.isAdminRole(_cached?.role ?? AppSessionFallback.role);
  }

  static String timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

/// Used only when no session is loaded (should not happen after auth gate).
sealed class AppSessionFallback {
  static const displayName = 'Guest';
  static const username = 'guest';
  static const department = '';
  static const role = UserRoles.employee;
}
