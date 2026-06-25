import 'package:backend/firebase_config.dart';
import 'package:dart_frog/dart_frog.dart';

// Global Firebase initialization flag
bool _firebaseInitialized = false;

/// Middleware to initialize Firebase Admin SDK on first request
Handler middleware(Handler handler) {
  return (RequestContext context) async {
    // Initialize Firebase once on first request
    if (!_firebaseInitialized && !FirebaseConfig.isInitialized) {
      try {
        await FirebaseConfig.initialize();
        _firebaseInitialized = true;
      } catch (e) {
        // ignore: avoid_print
        print('⚠ Firebase initialization in middleware failed: $e');
        // Continue anyway - some endpoints might not need Firebase
      }
    }

    // Continue to route handler
    return handler(context);
  };
}
