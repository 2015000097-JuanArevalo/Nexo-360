// Generated-compatible Firebase options based on the latest project configuration.
// Run `flutterfire configure --project=nexo-360-9ed4c` if you replace the Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.windows => windows,
      _ => throw UnsupportedError(
          'Esta entrega está preparada para Android, Windows y Web.',
        ),
    };
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgm3K6AuUFMZLc7EZnQW7pKI7zDGyA43c',
    appId: '1:9819698541:web:97bd81caeab00b22409664',
    messagingSenderId: '9819698541',
    projectId: 'nexo-360-9ed4c',
    authDomain: 'nexo-360-9ed4c.firebaseapp.com',
    storageBucket: 'nexo-360-9ed4c.firebasestorage.app',
    measurementId: 'G-ZZQ3MDFSJ8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoS1_Ydr95otITGMwUczkf0zoAFXfVD1Y',
    appId: '1:9819698541:android:cfb70d86d2e91453409664',
    messagingSenderId: '9819698541',
    projectId: 'nexo-360-9ed4c',
    storageBucket: 'nexo-360-9ed4c.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgm3K6AuUFMZLc7EZnQW7pKI7zDGyA43c',
    appId: '1:9819698541:web:1929ed9a207db8da409664',
    messagingSenderId: '9819698541',
    projectId: 'nexo-360-9ed4c',
    authDomain: 'nexo-360-9ed4c.firebaseapp.com',
    storageBucket: 'nexo-360-9ed4c.firebasestorage.app',
    measurementId: 'G-13T52PYKJE',
  );
}
