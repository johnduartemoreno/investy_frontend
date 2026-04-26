import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    // Check if user is already authenticated (session persistence)
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      debugPrint(
          '🔥 [AuthNotifier] Found existing session: ${firebaseUser.uid}');
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name:
            firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? '',
      );
    }

    debugPrint('🔥 [AuthNotifier] No existing session found');
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final useCase = LoginUseCase(repository);

    final result = await useCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp(
      String name, String email, String password, String displayCurrency) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final useCase = SignUpUseCase(repository);

    final result = await useCase(SignUpParams(
      name: name,
      email: email,
      password: password,
      displayCurrency: displayCurrency,
    ));

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final useCase = LogoutUseCase(repository);

    final result = await useCase(NoParams());

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> checkEmailVerification() async {
    debugPrint('🔥 [AuthNotifier] Checking email verification status...');

    final repository = ref.read(authRepositoryProvider);
    await repository.reloadUser();

    // Refresh the auth state
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      debugPrint(
          '🔥 [AuthNotifier] Email verified: ${firebaseUser.emailVerified}');
      state = AsyncValue.data(User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name:
            firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? '',
      ));
    }
  }

  Future<void> forgotPassword(String email) async {
    final repository = ref.read(authRepositoryProvider);
    final useCase = ForgotPasswordUseCase(repository);
    final result = await useCase(ForgotPasswordParams(email: email));
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => debugPrint('🔥 [AuthNotifier] Password reset email sent'),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final useCase = GoogleSignInUseCase(repository);
    final result = await useCase(NoParams());
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> resendVerificationEmail() async {
    debugPrint('🔥 [AuthNotifier] Resending verification email...');

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.sendVerificationEmail();

    result.fold(
      (failure) {
        debugPrint('🔥 [AuthNotifier] Error: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) => debugPrint('🔥 [AuthNotifier] Verification email resent'),
    );
  }
}
