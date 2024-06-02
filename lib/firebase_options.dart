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
    apiKey: 'AIzaSyB8ft09-VUFiiuOjPjDZR-25zb-0y73-pY',
    appId: '1:621628966821:web:cdda532c751b8c81768a4c',
    messagingSenderId: '621628966821',
    projectId: 'reservation-restaurant-5dba3',
    authDomain: 'reservation-restaurant-5dba3.firebaseapp.com',
    storageBucket: 'reservation-restaurant-5dba3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAar7nUv3mADLBFSEkQpgjLlauwsRRj5q8',
    appId: '1:621628966821:android:9230c09c0cc8baab768a4c',
    messagingSenderId: '621628966821',
    projectId: 'reservation-restaurant-5dba3',
    storageBucket: 'reservation-restaurant-5dba3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARg3aLl4m3JQo3uu0eZFeQV80DxSt7p58',
    appId: '1:621628966821:ios:5da6abf881197fb2768a4c',
    messagingSenderId: '621628966821',
    projectId: 'reservation-restaurant-5dba3',
    storageBucket: 'reservation-restaurant-5dba3.appspot.com',
    iosBundleId: 'com.example.pfe2024',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyARg3aLl4m3JQo3uu0eZFeQV80DxSt7p58',
    appId: '1:621628966821:ios:5da6abf881197fb2768a4c',
    messagingSenderId: '621628966821',
    projectId: 'reservation-restaurant-5dba3',
    storageBucket: 'reservation-restaurant-5dba3.appspot.com',
    iosBundleId: 'com.example.pfe2024',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB8ft09-VUFiiuOjPjDZR-25zb-0y73-pY',
    appId: '1:621628966821:web:00a5873c94b22e72768a4c',
    messagingSenderId: '621628966821',
    projectId: 'reservation-restaurant-5dba3',
    authDomain: 'reservation-restaurant-5dba3.firebaseapp.com',
    storageBucket: 'reservation-restaurant-5dba3.appspot.com',
  );
}
