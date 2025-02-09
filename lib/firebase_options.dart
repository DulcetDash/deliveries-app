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
    apiKey: 'AIzaSyC7MfejaMP1lcYNP4bS3E-MRiT4-Zz3Fzg',
    appId: '1:659785961534:web:634afbf0bc3076b113c16f',
    messagingSenderId: '659785961534',
    projectId: 'dulcetdash-403312',
    authDomain: 'dulcetdash-403312.firebaseapp.com',
    storageBucket: 'dulcetdash-403312.appspot.com',
    measurementId: 'G-S1QS17C73Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8qWib_6PyDhYIHtM9wINVfJZG2kt2hAo',
    appId: '1:659785961534:android:88068d9c074d0b2013c16f',
    messagingSenderId: '659785961534',
    projectId: 'dulcetdash-403312',
    storageBucket: 'dulcetdash-403312.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXT_I29RcBFzuif6DcR3DBuG102z2DDi0',
    appId: '1:659785961534:ios:b4ba3c2237b6ae8613c16f',
    messagingSenderId: '659785961534',
    projectId: 'dulcetdash-403312',
    storageBucket: 'dulcetdash-403312.appspot.com',
    iosBundleId: 'com.example.dulcetdash',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXT_I29RcBFzuif6DcR3DBuG102z2DDi0',
    appId: '1:659785961534:ios:39d3d97a700b9e5d13c16f',
    messagingSenderId: '659785961534',
    projectId: 'dulcetdash-403312',
    storageBucket: 'dulcetdash-403312.appspot.com',
    iosBundleId: 'com.example.dulcetdash.RunnerTests',
  );
}
