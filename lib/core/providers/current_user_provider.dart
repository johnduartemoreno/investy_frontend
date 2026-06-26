import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current authenticated user's Firebase UID, or null if signed out.
///
/// Reads the FirebaseAuth singleton by default but is a provider so widget
/// tests can override it without bootstrapping Firebase. Global (no autoDispose)
/// — the UID is stable for the whole session.
final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});
