import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/transaction_request_model.dart';
import '../screens/dashboard_screen.dart';

part 'sell_asset_controller.g.dart';

@riverpod
class SellAssetController extends _$SellAssetController {
  @override
  FutureOr<void> build() {
    // Initial state is void (data) or loading/error
  }

  Future<void> sellAsset({
    required String symbol,
    required double currentPrice,
    required double quantity,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      final total = currentPrice * quantity;
      await ref.read(dashboardRemoteDataSourceProvider).createTransaction(
            userId,
            TransactionRequestModel.fromDomain(total, 'SELL'),
          );
    });
    if (state is AsyncData) {
      ref.invalidate(restDashboardProvider);
    }
  }
}
