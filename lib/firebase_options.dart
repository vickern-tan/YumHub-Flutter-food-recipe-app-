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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpswiu37WQq8qBLETcGhnaaYEnlY-26DY',
    appId: '1:12092742398:android:0112f6e89bddbe0daf63af',
    messagingSenderId: '12092742398',
    projectId: 'yumhub-483b7',
    storageBucket: 'yumhub-483b7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkp-WuE_iw1kMoeiJs9lpbJuK_fsTpcoo',
    appId: '1:12092742398:ios:1b3288cfea27e7aeaf63af',
    messagingSenderId: '12092742398',
    projectId: 'yumhub-483b7',
    storageBucket: 'yumhub-483b7.appspot.com',
    androidClientId: '12092742398-5uuj8necclhd3uhv8slk97r9guha5g02.apps.googleusercontent.com',
    iosClientId: '12092742398-14i5rc99u31ttjihc6rjb6rck0nl1v29.apps.googleusercontent.com',
    iosBundleId: 'com.example.foodRecipeApp',
  );

}