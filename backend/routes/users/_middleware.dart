import 'package:dart_frog/dart_frog.dart';
import 'package:firebase_admin/firebase_admin.dart'; // illustrative import
import 'package:http/http.dart' as http;
import 'dart:convert';

Handler middleware(Handler handler) {
  return handler.use(authenticationMiddleware());
}

Middleware authenticationMiddleware() {
  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['Authorization'];

      // 1. Token must be present and well-formed
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: 401,
          body: {
            'success': false,
            'code': 'AUTH001',
            'message': 'Invalid or expired token.',
          },
        );
      }

      final idToken = authHeader.substring(7); // strip "Bearer "

      // TODO: replace with real Firebase token verification
      final decodedToken = await verifyIdTokenSafely(idToken);

      // 2. Verify token with Firebase Admin SDK
      if (decodedToken == null) {
        return Response.json(
          statusCode: 401,
          body: {
            'success': false,
            'code': 'AUTH001',
            'message': 'Invalid or expired token.',
          },
        );
      }

      final uid = decodedToken.uid;

      // 3. Look up the Firestore user document
      final userDoc = await firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return Response.json(
          statusCode: 404,
          body: {
            'success': false,
            'code': 'AUTH004',
            'message': 'User not found.',
          },
        );
      }

      final userData = userDoc.data()!;

      // 4. deactivation gate, before anything else
      if (userData['is_deleted'] == true) {
        return Response.json(
          statusCode: 403,
          body: {
            'success': false,
            'code': 'AUTH006',
            'message': 'This account has been deactivated.',
          },
        );
      }

      // 5. Attach verified identity + user data to context
      //    so route handlers don't need to re-fetch or re-verify
      final updatedContext = context
          .provide<String>(() => uid)
          .provide<Map<String, dynamic>>(() => userData);

      return handler(updatedContext);
    };
  };
}

// Stub — returns the token as uid for now
Future<String?> verifyIdTokenSafely(String idToken) async {
  if (idToken.isEmpty) return null;
  return idToken; // replace this with real verification later
}

// Stub — returns fake user data for now
Future<Map<String, dynamic>?> getFirestoreUser(String uid) async {
  if (uid.isEmpty) return null;
  return {
    'uid': uid,
    'email': 'test@ciit.edu.ph',
    'name': 'Test User',
    'role': 'student',
    'is_deleted': false,
  };
}
