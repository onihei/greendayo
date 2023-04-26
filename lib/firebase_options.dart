// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAABCUV2tq4jvJJfxDv_n0iTIrV8asKuvw',
    appId: '1:853677427401:web:d51bf2dbf8ec5cd2eedb18',
    messagingSenderId: '853677427401',
    projectId: 'yamyam-ac34b',
    authDomain: 'yamyam-ac34b.firebaseapp.com',
    storageBucket: 'yamyam-ac34b.appspot.com',
    measurementId: 'G-WN5GNRYG5Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKF7UmIQOsZZ--TwQlfBcWU7ZsOfd0a4s',
    appId: '1:853677427401:android:3f8288d5ce178a99eedb18',
    messagingSenderId: '853677427401',
    projectId: 'yamyam-ac34b',
    storageBucket: 'yamyam-ac34b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqFh5maunSFucf6OaderHYgjoMrKm6j94',
    appId: '1:853677427401:ios:7050cd82d43d6728eedb18',
    messagingSenderId: '853677427401',
    projectId: 'yamyam-ac34b',
    storageBucket: 'yamyam-ac34b.appspot.com',
    androidClientId: '853677427401-p9ck239cuvu8ebtnh343muamcr9dqipl.apps.googleusercontent.com',
    iosClientId: '853677427401-9ruom7t23cd5l693ve6l3vctpgvpohpj.apps.googleusercontent.com',
    iosBundleId: 'com.susipero.greendayo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqFh5maunSFucf6OaderHYgjoMrKm6j94',
    appId: '1:853677427401:ios:7050cd82d43d6728eedb18',
    messagingSenderId: '853677427401',
    projectId: 'yamyam-ac34b',
    storageBucket: 'yamyam-ac34b.appspot.com',
    androidClientId: '853677427401-p9ck239cuvu8ebtnh343muamcr9dqipl.apps.googleusercontent.com',
    iosClientId: '853677427401-9ruom7t23cd5l693ve6l3vctpgvpohpj.apps.googleusercontent.com',
    iosBundleId: 'com.susipero.greendayo',
  );
}