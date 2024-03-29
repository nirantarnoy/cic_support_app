// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSkLPXZu8PShFqIfdN26CTNtTN65nbwkc',
    appId: '1:327372551535:web:508e1bff2f879a9459e49a',
    messagingSenderId: '327372551535',
    projectId: 'fcmflutter-ed115',
    authDomain: 'fcmflutter-ed115.firebaseapp.com',
    storageBucket: 'fcmflutter-ed115.appspot.com',
    measurementId: 'G-R5R15YZB20',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYC0L59Hnzqr9i_UsqqvlgMeooi0095qU',
    appId: '1:327372551535:android:c5b9a899bddb5f9359e49a',
    messagingSenderId: '327372551535',
    projectId: 'fcmflutter-ed115',
    storageBucket: 'fcmflutter-ed115.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEqvp93lqXAGj7JdZ7uWTmWiJrpPqJYnQ',
    appId: '1:327372551535:ios:384fdefb7a0cefda59e49a',
    messagingSenderId: '327372551535',
    projectId: 'fcmflutter-ed115',
    storageBucket: 'fcmflutter-ed115.appspot.com',
    iosClientId: '327372551535-e6j66calfk87jnbumt9k1hhhddisoc8p.apps.googleusercontent.com',
    iosBundleId: 'com.cicdev2022.flutterCicSupport',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCEqvp93lqXAGj7JdZ7uWTmWiJrpPqJYnQ',
    appId: '1:327372551535:ios:8c0fee19effd673559e49a',
    messagingSenderId: '327372551535',
    projectId: 'fcmflutter-ed115',
    storageBucket: 'fcmflutter-ed115.appspot.com',
    iosClientId: '327372551535-br9j0973ntcfkglgf9uphjdo0q64phpn.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterCicSupport',
  );
}
