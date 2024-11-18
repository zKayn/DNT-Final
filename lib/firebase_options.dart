// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDjKSxPfciCymlqhEu8fBdpiRDLZDgC208',
    appId: '1:758909414405:web:51ab19f95676b70f5ac06c',
    messagingSenderId: '758909414405',
    projectId: 'final-dnt',
    authDomain: 'final-dnt.firebaseapp.com',
    databaseURL: 'https://final-dnt-default-rtdb.firebaseio.com',
    storageBucket: 'final-dnt.firebasestorage.app',
    measurementId: 'G-2RYG8K93RG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2WYP9OabxV82mOQURC6Cfqd49MBz_wWw',
    appId: '1:758909414405:android:ae099a4a85f513b35ac06c',
    messagingSenderId: '758909414405',
    projectId: 'final-dnt',
    databaseURL: 'https://final-dnt-default-rtdb.firebaseio.com',
    storageBucket: 'final-dnt.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBg8NwNuPlIs8T3Zgua52aC6DY0dTpJhpA',
    appId: '1:758909414405:ios:2d46e5e226f2fcea5ac06c',
    messagingSenderId: '758909414405',
    projectId: 'final-dnt',
    databaseURL: 'https://final-dnt-default-rtdb.firebaseio.com',
    storageBucket: 'final-dnt.firebasestorage.app',
    iosBundleId: 'com.example.shoppingapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBg8NwNuPlIs8T3Zgua52aC6DY0dTpJhpA',
    appId: '1:758909414405:ios:2d46e5e226f2fcea5ac06c',
    messagingSenderId: '758909414405',
    projectId: 'final-dnt',
    databaseURL: 'https://final-dnt-default-rtdb.firebaseio.com',
    storageBucket: 'final-dnt.firebasestorage.app',
    iosBundleId: 'com.example.shoppingapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDjKSxPfciCymlqhEu8fBdpiRDLZDgC208',
    appId: '1:758909414405:web:3b0dd52559e47aaf5ac06c',
    messagingSenderId: '758909414405',
    projectId: 'final-dnt',
    authDomain: 'final-dnt.firebaseapp.com',
    databaseURL: 'https://final-dnt-default-rtdb.firebaseio.com',
    storageBucket: 'final-dnt.firebasestorage.app',
    measurementId: 'G-ED9MSQ92V2',
  );

}