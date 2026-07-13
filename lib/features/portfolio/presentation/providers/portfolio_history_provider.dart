import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/portfolio_history_model.dart';

part 'portfolio_history_provider.g.dart';

/// Selected range for the portfolio-value chart (Pattern D3 — sync state).
/// Tapping a range chip calls `set`, which reactively re-fetches the history.
@riverpod
class PortfolioHistoryRange extends _$PortfolioHistoryRange {
  @override
  String build() => '1M';

  void set(String range) => state = range;
}

/// Portfolio daily-value series (Pattern B — reacts to the selected range).
@riverpod
Future<PortfolioHistoryModel> portfolioHistory(Ref ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const PortfolioHistoryModel(range: '', currency: 'USD', points: []);
  }
  final range = ref.watch(portfolioHistoryRangeProvider);
  return ref
      .watch(dashboardRemoteDataSourceProvider)
      .getPortfolioHistory(userId, range);
}

/// Today's change (Pattern C — derived): the latest snapshot vs the previous
/// one, in USD dollars + percent. Range-independent (last two daily points are
/// always yesterday/today). Null until at least two points exist.
final todaysChangeProvider =
    Provider.autoDispose<({double amount, double pct})?>((ref) {
  final history = ref.watch(portfolioHistoryProvider).valueOrNull;
  if (history == null || history.points.length < 2) return null;
  final last = history.points[history.points.length - 1].totalAmount;
  final prev = history.points[history.points.length - 2].totalAmount;
  final amount = last - prev;
  final pct = prev == 0 ? 0.0 : (amount / prev * 100);
  return (amount: amount, pct: pct);
});
