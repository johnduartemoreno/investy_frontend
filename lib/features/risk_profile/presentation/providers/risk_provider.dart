import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/risk_remote_datasource.dart';
import '../../data/models/risk_profile_model.dart';

/// Current user's risk profile — null means not yet completed.
final riskProfileProvider =
    FutureProvider.autoDispose<RiskProfileModel?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;
  return ref.watch(riskRemoteDataSourceProvider).getProfile(userId);
});
