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
    apiKey: 'AIzaSyBUbB-h-kMscMAuLYSqGxhl2L4m-ifZalw',
    appId: '1:192468342798:web:53408642c585095bce445f',
    messagingSenderId: '192468342798',
    projectId: 'hookup4u-6be59',
    authDomain: 'hookup4u-6be59.firebaseapp.com',
    storageBucket: 'hookup4u-6be59.firebasestorage.app',
    measurementId: 'G-FY0CFYBJL0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDf2tFDkkZ6I4GMx8Dplujb3yGglP02AXE',
    appId: '1:192468342798:android:52361d732c264974ce445f',
    messagingSenderId: '192468342798',
    projectId: 'hookup4u-6be59',
    storageBucket: 'hookup4u-6be59.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0dEyF7_bVTFPkJOZDwOVpn1Ikiwbw5oI',
    appId: '1:192468342798:ios:ac90a20e9cfba3e6ce445f',
    messagingSenderId: '192468342798',
    projectId: 'hookup4u-6be59',
    storageBucket: 'hookup4u-6be59.firebasestorage.app',
    androidClientId: '192468342798-iprs8pp3neij56rqdg2q86d085gaqbbc.apps.googleusercontent.com',
    iosClientId: '192468342798-o5e9nsdf6q2d6ma43is8vt96amm3fauu.apps.googleusercontent.com',
    iosBundleId: 'com.soloparent.app',
  );

}