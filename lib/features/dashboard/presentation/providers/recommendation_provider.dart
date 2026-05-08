import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/providers/locale_provider.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/recommendation_model.dart';

part 'recommendation_provider.g.dart';

/// Fetches AI recommendations for the current user.
/// Reasons are returned in the user's current app language (en/es/pt).
/// Pass [forceRefresh] = true to bypass the server-side 24h cache.
@riverpod
Future<List<RecommendationModel>> recommendations(
  Ref ref, {
  bool forceRefresh = false,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('ERR_UNAUTHENTICATED');
  final language = ref.watch(localeNotifierProvider).languageCode;
  return ref.read(dashboardRemoteDataSourceProvider).getRecommendations(
        userId,
        language: language,
        forceRefresh: forceRefresh,
      );
}
