import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/portfolio_response_model.dart';

/// Fetches the current user's portfolio from the REST backend.
/// Auto-disposes when no longer watched.
final restPortfolioProvider =
    FutureProvider.autoDispose<PortfolioResponseModel>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const PortfolioResponseModel(
      holdings: [],
      totalInvestedCents: 0,
      currency: 'USD',
    );
  }
  return ref.watch(dashboardRemoteDataSourceProvider).getPortfolio(userId);
});
