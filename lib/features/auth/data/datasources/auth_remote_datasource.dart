import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/auth_exception.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(
      String name, String email, String password, String displayCurrency);
  Future<void> sendVerificationEmail();
  Future<void> reloadUser();
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<UserModel> signInWithGoogle();
  Future<void> deleteAccountEmail(String currentPassword);
  Future<void> deleteAccountGoogle();
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
        throw const AuthException(AuthErrorCode.unexpected);
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
          throw const AuthException(AuthErrorCode.userNotFound);
        case 'wrong-password':
        case 'invalid-credential':
          throw const AuthException(AuthErrorCode.invalidCredentials);
        case 'invalid-email':
          throw const AuthException(AuthErrorCode.invalidEmail);
        case 'user-disabled':
          throw const AuthException(AuthErrorCode.userDisabled);
        case 'too-many-requests':
          throw const AuthException(AuthErrorCode.tooManyRequests);
        case 'network-request-failed':
        case 'channel-error':
          throw const AuthException(AuthErrorCode.network);
        default:
          throw const AuthException(AuthErrorCode.unexpected);
      }
    } catch (e) {
      debugPrint('🔥 [AuthRemoteDataSource] Unexpected error: $e');
      throw const AuthException(AuthErrorCode.unexpected);
    }
  }

  @override
  Future<UserModel> signUp(String name, String email, String password,
      String displayCurrency) async {
    try {
      debugPrint('🔥 [AuthRemoteDataSource] Creating account for $email...');

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException(AuthErrorCode.unexpected);
      }

      await firebaseUser.updateDisplayName(name);

      debugPrint(
          '🔥 [AuthRemoteDataSource] Account created: ${firebaseUser.uid}');

      // Register user in backend with chosen display currency (ADR-02 — immutable after registration).
      // Non-fatal: if this fails, UpsertFromFirebase on first dashboard load creates the user with USD default.
      try {
        await dio.post(
          '/api/v1/users/${firebaseUser.uid}/onboard',
          data: {'displayCurrency': displayCurrency},
        );
        debugPrint(
            '🔥 [AuthRemoteDataSource] Backend user registered with currency $displayCurrency');
      } catch (e) {
        debugPrint(
            '🔥 [AuthRemoteDataSource] onboard call failed (non-fatal): $e');
      }

      debugPrint(
          '🔥 [AuthRemoteDataSource] Sending verification email to $email...');
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
          throw const AuthException(AuthErrorCode.emailInUse);
        case 'invalid-email':
          throw const AuthException(AuthErrorCode.invalidEmail);
        case 'weak-password':
          throw const AuthException(AuthErrorCode.weakPassword);
        case 'operation-not-allowed':
          throw const AuthException(AuthErrorCode.operationNotAllowed);
        default:
          throw const AuthException(AuthErrorCode.unexpected);
      }
    } catch (e) {
      debugPrint('🔥 [AuthRemoteDataSource] Unexpected error: $e');
      throw const AuthException(AuthErrorCode.unexpected);
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const AuthException(AuthErrorCode.noUserLoggedIn);
      }

      debugPrint(
          '🔥 [AuthRemoteDataSource] Resending verification email to ${user.email}...');
      await user.sendEmailVerification();
      debugPrint('🔥 [AuthRemoteDataSource] Verification email resent');
    } catch (e) {
      debugPrint(
          '🔥 [AuthRemoteDataSource] Error sending verification email: $e');
      throw const AuthException(AuthErrorCode.verificationEmailFailed);
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const AuthException(AuthErrorCode.noUserLoggedIn);
      }

      debugPrint('🔥 [AuthRemoteDataSource] Reloading user data...');
      await user.reload();

      final reloadedUser = FirebaseAuth.instance.currentUser;
      debugPrint(
          '🔥 [AuthRemoteDataSource] User reloaded. Email verified: ${reloadedUser?.emailVerified}');
    } catch (e) {
      debugPrint('🔥 [AuthRemoteDataSource] Error reloading user: $e');
      throw const AuthException(AuthErrorCode.refreshFailed);
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
          throw const AuthException(AuthErrorCode.invalidEmail);
        case 'network-request-failed':
          throw const AuthException(AuthErrorCode.network);
        default:
          throw const AuthException(AuthErrorCode.unexpected);
      }
    } catch (e) {
      throw const AuthException(AuthErrorCode.unexpected);
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
        throw const AuthException(AuthErrorCode.googleCancelled);
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
        throw const AuthException(AuthErrorCode.unexpected);
      }

      debugPrint(
          '🔥 [AuthRemoteDataSource] Google Sign-In successful: ${firebaseUser.uid}');

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name:
            firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? '',
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw const AuthException(
              AuthErrorCode.accountExistsWithDifferentCredential);
        case 'network-request-failed':
          throw const AuthException(AuthErrorCode.network);
        default:
          throw const AuthException(AuthErrorCode.unexpected);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('🔥 [AuthRemoteDataSource] Google Sign-In error: $e');
      throw const AuthException(AuthErrorCode.unexpected);
    }
  }

  @override
  Future<void> deleteAccountEmail(String currentPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const AuthException(AuthErrorCode.noUserLoggedIn);
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await _deleteBackendUser(user.uid);
      await user.delete();
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw const AuthException(AuthErrorCode.wrongPassword);
        case 'requires-recent-login':
          throw const AuthException(AuthErrorCode.requiresRecentLogin);
        default:
          throw const AuthException(AuthErrorCode.deletionFailed);
      }
    }
  }

  @override
  Future<void> deleteAccountGoogle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const AuthException(AuthErrorCode.noUserLoggedIn);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw const AuthException(AuthErrorCode.googleCancelled);
      }
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(cred);
      await _deleteBackendUser(user.uid);
      await user.delete();
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } on FirebaseAuthException {
      throw const AuthException(AuthErrorCode.deletionFailed);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(AuthErrorCode.deletionFailed);
    }
  }

  Future<void> _deleteBackendUser(String uid) async {
    try {
      await dio.delete('/api/v1/users/$uid');
    } catch (e) {
      debugPrint(
          '🔥 [AuthRemoteDataSource] Backend delete failed (continuing): $e');
    }
  }
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
}
