import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_remote_datasource.g.dart';

abstract class UserProfileRemoteDataSource {
  Future<void> upsertUserProfile(User firebaseUser);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  UserProfileRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> upsertUserProfile(User firebaseUser) async {
    final uid = firebaseUser.uid;
    debugPrint('🔥 [UserProfileRemoteDataSource] Upserting users/$uid');

    try {
      final docRef = firestore.collection('users').doc(uid);
      final docSnapshot = await docRef.get();

      final Map<String, dynamic> data = {
        'uid': uid,
        'email': firebaseUser.email,
        'display_name': firebaseUser.displayName,
        'photo_url': firebaseUser.photoURL,
        'phone_number': firebaseUser.phoneNumber,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (!docSnapshot.exists) {
        // New document defaults
        data['created_at'] = FieldValue.serverTimestamp();
        data['onboarding_completed'] = false;
        data['base_currency'] = 'COP';
        data['country'] = 'CO';
        data['track_mode'] = 'both';
        data['timezone'] = 'America/Bogota';
        data['preferred_language'] = 'es';
      } else {
        // Existing document - check for missing fields
        final currentData = docSnapshot.data();
        if (currentData != null) {
          if (!currentData.containsKey('onboarding_completed')) {
            data['onboarding_completed'] = false;
          }
          if (!currentData.containsKey('base_currency')) {
            data['base_currency'] = 'COP';
          }
          if (!currentData.containsKey('country')) {
            data['country'] = 'CO';
          }
          if (!currentData.containsKey('track_mode')) {
            data['track_mode'] = 'both';
          }
          if (!currentData.containsKey('timezone')) {
            data['timezone'] = 'America/Bogota';
          }
          if (!currentData.containsKey('preferred_language')) {
            data['preferred_language'] = 'es';
          }
        }
      }

      await docRef.set(data, SetOptions(merge: true));
      debugPrint(
          '🔥 [UserProfileRemoteDataSource] Upsert completed users/$uid');
    } catch (e) {
      debugPrint(
          '🔥 [UserProfileRemoteDataSource] Error upserting user profile: $e');
      rethrow;
    }
  }
}

@riverpod
UserProfileRemoteDataSource userProfileRemoteDataSource(Ref ref) {
  return UserProfileRemoteDataSourceImpl(FirebaseFirestore.instance);
}
