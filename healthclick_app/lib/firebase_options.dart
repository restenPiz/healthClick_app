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
    apiKey: 'AIzaSyCHIiDRhm-NoKiOJD2YIoIcmHjrlRr7lrs',
    appId: '1:50654751468:web:0cb060738db62e0a6dd3c9',
    messagingSenderId: '50654751468',
    projectId: 'healthclick-3b2ab',
    authDomain: 'healthclick-3b2ab.firebaseapp.com',
    storageBucket: 'healthclick-3b2ab.firebasestorage.app',
    measurementId: 'G-T04316N088',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBy8NHYLyzqUIkXPZ-dmpwNfn88sAfHg3I',
    appId: '1:50654751468:android:888a59f95e04ec4e6dd3c9',
    messagingSenderId: '50654751468',
    projectId: 'healthclick-3b2ab',
    storageBucket: 'healthclick-3b2ab.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-jruYCva6oAMHG2Xk1v1xjTkXMQNd9hM',
    appId: '1:50654751468:ios:7ae56e97aec7382a6dd3c9',
    messagingSenderId: '50654751468',
    projectId: 'healthclick-3b2ab',
    storageBucket: 'healthclick-3b2ab.firebasestorage.app',
    iosBundleId: 'com.example.healthclickApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-jruYCva6oAMHG2Xk1v1xjTkXMQNd9hM',
    appId: '1:50654751468:ios:7ae56e97aec7382a6dd3c9',
    messagingSenderId: '50654751468',
    projectId: 'healthclick-3b2ab',
    storageBucket: 'healthclick-3b2ab.firebasestorage.app',
    iosBundleId: 'com.example.healthclickApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCHIiDRhm-NoKiOJD2YIoIcmHjrlRr7lrs',
    appId: '1:50654751468:web:f7a14ceba1b0f52d6dd3c9',
    messagingSenderId: '50654751468',
    projectId: 'healthclick-3b2ab',
    authDomain: 'healthclick-3b2ab.firebaseapp.com',
    storageBucket: 'healthclick-3b2ab.firebasestorage.app',
    measurementId: 'G-H55K02CTR6',
  );
}
