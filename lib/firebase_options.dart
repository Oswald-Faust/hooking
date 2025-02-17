import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDf2tFDkkZ6I4GMx8Dplujb3yGglP02AXE',
    appId: '1:192468342798:web:e063f16e97a4410ece445f',
    messagingSenderId: '192468342798',
    projectId: 'hookup4u-6be59',
    authDomain: 'hookup4u-6be59.firebaseapp.com',
    storageBucket: 'hookup4u-6be59.appspot.com',
    measurementId: 'G-6BE59',
    androidClientId: '192468342798-00000000000000000000000000000000.apps.googleusercontent.com',
    iosClientId: '192468342798-00000000000000000000000000000000.apps.googleusercontent.com',
    iosBundleId: 'com.example.hookup4u',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDf2tFDkkZ6I4GMx8Dplujb3yGglP02AXE',
    appId: '1:192468342798:android:e063f16e97a4410ece445f',
    messagingSenderId: '192468342798',
    projectId: 'hookup4u-6be59',
    storageBucket: 'hookup4u-6be59.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosBundleId: 'YOUR-IOS-BUNDLE-ID',
  );
}