import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/upsert_user_profile_usecase.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

part 'user_profile_sync_provider.g.dart';

@Riverpod(keepAlive: true)
class UserProfileSync extends _$UserProfileSync {
  @override
  Stream<void> build() {
    debugPrint('🔥 [UserProfileSync] initialized');
    // Listen toauthState changes
    return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
      if (user != null) {
        debugPrint(
            '🔥 [UserProfileSync] auth user detected: ${user.uid}, verified: ${user.emailVerified}');

        // CRITICAL: Only upsert if email is verified
        if (user.emailVerified) {
          await _upsertProfile(user);
        } else {
          debugPrint(
              '🔥 [UserProfileSync] Skipping upsert - email not verified');
        }
      } else {
        debugPrint('🔥 [UserProfileSync] Auth state changed: User signed out.');
      }
    });
  }

  Future<void> _upsertProfile(User user) async {
    final repository = ref.read(userProfileRepositoryProvider);
    final useCase = UpsertUserProfileUseCase(repository);

    final result = await useCase(user);

    result.fold(
      (failure) =>
          debugPrint('🔥 [UserProfileSync] Upsert failed: ${failure.message}'),
      (_) =>
          debugPrint('🔥 [UserProfileSync] Upsert succeeded for ${user.uid}'),
    );
  }
}
