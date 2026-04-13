import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/asset_search_result_model.dart';
import '../../data/models/transaction_request_model.dart';
import '../screens/dashboard_screen.dart';
import '../../../../features/portfolio/presentation/providers/rest_portfolio_provider.dart';

part 'buy_asset_controller.g.dart';

@riverpod
class BuyAssetController extends _$BuyAssetController {
  @override
  FutureOr<void> build() {}

  Future<void> buyAsset({
    required String symbol,
    required double quantity,
    required double pricePerUnit,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      await ref.read(dashboardRemoteDataSourceProvider).createTransaction(
            userId,
            TransactionRequestModel.forTrade(
              type: 'BUY',
              symbol: symbol,
              quantity: quantity,
              pricePerUnit: pricePerUnit,
            ),
          );
    });
    if (state is AsyncData) {
      ref.invalidate(restDashboardProvider);
      ref.invalidate(restPortfolioProvider);
    }
  }

  /// Searches assets via REST backend (PostgreSQL). No Firestore dependency.
  Future<List<AssetSearchResultModel>> searchAssets(String query) {
    return ref.read(dashboardRemoteDataSourceProvider).searchAssets(query);
  }
}
