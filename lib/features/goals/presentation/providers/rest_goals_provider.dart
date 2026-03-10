import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../../../features/dashboard/data/models/goal_response_model.dart';

/// Fetches the authenticated user's financial goals from the Go REST backend.
/// Emits AsyncLoading → AsyncData<List<GoalResponseModel>> → AsyncError.
final restGoalsProvider =
    FutureProvider.autoDispose<List<GoalResponseModel>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  return ref.watch(dashboardRemoteDataSourceProvider).getGoals(userId);
});
