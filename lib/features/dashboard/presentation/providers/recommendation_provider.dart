import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/recommendation_model.dart';

part 'recommendation_provider.g.dart';

/// Fetches AI recommendations for the current user.
/// Pass [forceRefresh] = true to bypass the server-side 24h cache.
@riverpod
Future<List<RecommendationModel>> recommendations(
  Ref ref, {
  bool forceRefresh = false,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('ERR_UNAUTHENTICATED');
  return ref.read(dashboardRemoteDataSourceProvider).getRecommendations(
        userId,
        forceRefresh: forceRefresh,
      );
}
