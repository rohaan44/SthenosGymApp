import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Return null so native platforms (Android/iOS) read from their native service files
    return null;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCUN89uPzff9NcJ6q1ypIVyPNWYpwycfL4",
    authDomain: "sthenos-gym-8de40.firebaseapp.com",
    projectId: "sthenos-gym-8de40",
    storageBucket: "sthenos-gym-8de40.firebasestorage.app",
    messagingSenderId: "589496774641",
    appId: "1:589496774641:web:5710ba9722081f6368de50",
  );
}
