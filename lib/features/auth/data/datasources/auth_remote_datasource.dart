import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String name, String email, String password);
  Future<void> sendVerificationEmail();
  Future<void> reloadUser();
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<UserModel> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      debugPrint('🔥 [AuthRemoteDataSource] Attempting login for $email...');

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Login succeeded but user is null');
      }

      debugPrint(
          '🔥 [AuthRemoteDataSource] Login successful: ${firebaseUser.uid}');

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: firebaseUser.displayName ?? email.split('@')[0],
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '🔥 [AuthRemoteDataSource] Firebase Auth Error: ${e.code} - ${e.message}');

      // Map Firebase error codes to user-friendly messages
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Invalid email or password');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later');
        case 'network-request-failed':
        case 'channel-error':
          throw Exception('Network error. Please check your connection');
        default:
          throw Exception(e.message ?? 'Authentication failed');
      }
    } catch (e) {
      debugPrint('🔥 [AuthRemoteDataSource] Unexpected error: $e');
      throw Exception('An unexpected error occurred. Please try again');
    }
  }

  @override
  Future<UserModel> signUp(String name, String email, String password) async {
    try {
      debugPrint('🔥 [AuthRemoteDataSource] Creating account for $email...');

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Sign up succeeded but user is null');
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      debugPrint(
          '🔥 [AuthRemoteDataSource] Account created: ${firebaseUser.uid}');
      debugPrint(
          '🔥 [AuthRemoteDataSource] Sending verification email to $email...');

      // Send verification email
      await firebaseUser.sendEmailVerification();
      debugPrint('🔥 [AuthRemoteDataSource] Verification email sent to $email');

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: name,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '🔥 [AuthRemoteDataSource] Firebase Auth Error: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account with this email already exists');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        default:
          throw Exception(e.message ?? 'Sign up failed');
      }
    } catch (e) {
      debugPrint('🔥 [AuthRemoteDataSource] Unexpected error: $e');
      throw Exception('An unexpected error occurred. Please try again');
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      debugPrint(
          '🔥 [AuthRemoteDataSource] Resending verification email to ${user.email}...');
      await user.sendEmailVerification();
      debugPrint('🔥 [AuthRemoteDataSource] Verification email resent');
    } catch (e) {
      debugPrint(
          '🔥 [AuthRemoteDataSource] Error sending verification email: $e');
      throw Exception('Failed to send verification email. Please try again');
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      debugPrint('🔥 [AuthRemoteDataSource] Reloading user data...');
      await user.reload();

      final reloadedUser = FirebaseAuth.instance.currentUser;
      debugPrint(
          '🔥 [AuthRemoteDataSource] User reloaded. Email verified: ${reloadedUser?.emailVerified}');
    } catch (e) {
      debugPrint('🔥 [AuthRemoteDataSource] Error reloading user: $e');
      throw Exception('Failed to refresh status. Please try again');
    }
  }

  @override
  Future<void> logout() async {
    debugPrint('🔥 [AuthRemoteDataSource] Signing out from Firebase...');
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    debugPrint('🔥 [AuthRemoteDataSource] Signed out successfully.');
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      debugPrint(
          '🔥 [AuthRemoteDataSource] Sending password reset email to $email...');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      debugPrint('🔥 [AuthRemoteDataSource] Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          // Don't reveal if email exists — security best practice
          debugPrint(
              '🔥 [AuthRemoteDataSource] User not found, but returning success silently.');
          return;
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection');
        default:
          throw Exception(e.message ?? 'Failed to send reset email');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      debugPrint('🔥 [AuthRemoteDataSource] Starting Google Sign-In...');

      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in dialog
        throw Exception('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Google sign-in succeeded but user is null');
      }

      debugPrint(
          '🔥 [AuthRemoteDataSource] Google Sign-In successful: ${firebaseUser.uid}');

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? '',
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
              'An account already exists with this email using a different sign-in method');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection');
        default:
          throw Exception(e.message ?? 'Google sign-in failed');
      }
    } catch (e) {
      if (e.toString().contains('cancelled')) rethrow;
      debugPrint('🔥 [AuthRemoteDataSource] Google Sign-In error: $e');
      throw Exception('Google sign-in failed. Please try again');
    }
  }
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
}
