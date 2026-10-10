// Replace this file by running FlutterFire CLI from the `ekagaj` folder:
//   dart pub global activate flutterfire_cli
//   flutterfire configure -y
//
// Until then, `DefaultFirebaseOptions.isConfigured` is false and the app
// runs without initializing Firebase (UI still works).

// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Placeholder project id. `flutterfire configure` overwrites this file with your real project.
const String _kUnconfiguredProjectId = 'YOUR_PROJECT_ID';

class DefaultFirebaseOptions {
  /// True after you run `flutterfire configure` (real project id replaces the placeholder).
  static bool get isConfigured => android.projectId != _kUnconfiguredProjectId;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for Linux. '
          'Re-run FlutterFire CLI with Linux enabled or run on Android/iOS/Web/Windows.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAW3d00tj7n2v2HXjJp02BY_1dzLVvoybo',
    appId: '1:368321225041:web:0a27914c48bb1fe0eff370',
    messagingSenderId: '368321225041',
    projectId: 'ekagaj-95d3d',
    authDomain: 'ekagaj-95d3d.firebaseapp.com',
    storageBucket: 'ekagaj-95d3d.firebasestorage.app',
    measurementId: 'G-8TX0XFFRGD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-P_5GSM_TMPfWxWycmfXqrHrl0u49Jak',
    appId: '1:392641930402:android:bda3f9e20dd5e09a23a3fb',
    messagingSenderId: '392641930402',
    projectId: 'ekagaj-a34db',
    storageBucket: 'ekagaj-a34db.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOv2O-sRijfrqhFpEXVtmbjM5ppGirHoE',
    appId: '1:368321225041:ios:8b33930a876dc833eff370',
    messagingSenderId: '368321225041',
    projectId: 'ekagaj-95d3d',
    storageBucket: 'ekagaj-95d3d.firebasestorage.app',
    iosBundleId: 'com.ekagaj.ekagaj',
  );

  // macOS was not in the FlutterFire platform list; reuse iOS app config for macOS builds.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOv2O-sRijfrqhFpEXVtmbjM5ppGirHoE',
    appId: '1:368321225041:ios:8b33930a876dc833eff370',
    messagingSenderId: '368321225041',
    projectId: 'ekagaj-95d3d',
    storageBucket: 'ekagaj-95d3d.firebasestorage.app',
    iosBundleId: 'com.ekagaj.ekagaj',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBxrjPuK1vUK4xUI0TKmKqJpkyIRQmoW4E',
    appId: '1:392641930402:web:bef55fca79f4399323a3fb',
    messagingSenderId: '392641930402',
    projectId: 'ekagaj-a34db',
    authDomain: 'ekagaj-a34db.firebaseapp.com',
    storageBucket: 'ekagaj-a34db.firebasestorage.app',
    measurementId: 'G-R7VDNJ9GGZ',
  );

}