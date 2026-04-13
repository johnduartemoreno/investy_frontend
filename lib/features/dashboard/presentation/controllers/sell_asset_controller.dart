import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/transaction_request_model.dart';
import '../screens/dashboard_screen.dart';
import '../../../../features/portfolio/presentation/providers/rest_portfolio_provider.dart';

part 'sell_asset_controller.g.dart';

@riverpod
class SellAssetController extends _$SellAssetController {
  @override
  FutureOr<void> build() {}

  Future<void> sellAsset({
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
              type: 'SELL',
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
}
