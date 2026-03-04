import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> firebaseAuthSmokeTest() async {
  debugPrint('🔥 [FIREBASE SMOKE] Starting smoke test...');

  final auth = FirebaseAuth.instance;

  debugPrint(
      '🔥 [FIREBASE SMOKE] Current User: ${auth.currentUser?.uid ?? "null"}');

  auth.authStateChanges().listen((user) {
    if (user == null) {
      debugPrint(
          '🔥 [FIREBASE SMOKE] Auth State Change: User is currently signed out!');
    } else {
      debugPrint(
          '🔥 [FIREBASE SMOKE] Auth State Change: User signed in: ${user.uid}');
    }
  });
}
