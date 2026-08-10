import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/kyc_remote_datasource.dart';
import '../../data/models/kyc_status_model.dart';

/// Current user's KYC status.
///
/// `autoDispose` is here for the project convention (feature providers must not
/// outlive their listeners) and for nothing else. **Never treat it as a
/// freshness guarantee.** `settings_screen`, `broker_gate_banner` and
/// `kyc_gate_banner` all watch this provider from screens that outlive the KYC
/// screen, so there is always at least one listener, the provider is never
/// disposed, and the cached value survives the whole session. Reading
/// `autoDispose` as "this refreshes itself" is exactly what left an
/// already-approved user staring at "under review" until they restarted the app
/// (B80).
///
/// Refreshing is explicit and lives in three places, none of which may be
/// removed on the assumption that another covers it:
///  - `KycStatusRefresher` — on return to the foreground (and on push tap).
///  - `KycScreen` — bounded polling while a decision is outstanding. This is
///    the one that closes the seconds-long race between "submitted" and
///    "approved", and the only one that works on iOS, where no push arrives at
///    all until APNs is configured (B37).
///  - `NotificationService` — on a `kyc_status` push while in the foreground.
final kycStatusProvider =
    FutureProvider.autoDispose<KycStatusModel>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const KycStatusModel(status: 'not_started');
  }
  return ref.watch(kycRemoteDataSourceProvider).getStatus(userId);
});

/// Fetches a Sumsub SDK access token for the authenticated user.
final kycAccessTokenProvider = FutureProvider.autoDispose<String>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('Not authenticated');
  return ref.watch(kycRemoteDataSourceProvider).initFlow(userId);
});
