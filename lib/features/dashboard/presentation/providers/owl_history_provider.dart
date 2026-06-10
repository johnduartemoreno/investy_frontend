import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/owl_session_model.dart';

/// Persisted Owl AI recommendation sessions, newest first (B29).
/// MVP: single page of 20 — no pagination UI yet.
final owlHistoryProvider =
    FutureProvider.autoDispose<List<OwlSessionModel>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  return ref
      .watch(dashboardRemoteDataSourceProvider)
      .getRecommendationHistory(userId, limit: 20);
});
