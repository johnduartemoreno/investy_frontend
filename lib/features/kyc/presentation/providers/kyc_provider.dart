import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/kyc_remote_datasource.dart';
import '../../data/models/kyc_status_model.dart';

/// Current user's KYC status — auto-refreshed when invalidated.
final kycStatusProvider =
    FutureProvider.autoDispose<KycStatusModel>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const KycStatusModel(status: 'not_started');
  }
  return ref.watch(kycRemoteDataSourceProvider).getStatus(userId);
});

/// Fetches a Sumsub SDK access token for the authenticated user.
final kycAccessTokenProvider =
    FutureProvider.autoDispose<String>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('Not authenticated');
  return ref.watch(kycRemoteDataSourceProvider).initFlow(userId);
});
