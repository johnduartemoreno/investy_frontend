import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/broker_remote_datasource.dart';
import '../../data/models/broker_account_model.dart';

/// Current user's broker account status — returns null if no account yet (404).
final brokerAccountProvider =
    FutureProvider.autoDispose<BrokerAccountModel?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;
  try {
    return await ref.watch(brokerRemoteDataSourceProvider).getAccount(userId);
  } on Exception {
    // 404 = no broker account yet — not an error for the UI.
    return null;
  }
});
