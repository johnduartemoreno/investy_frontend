import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/asset.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/transaction_request_model.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../screens/dashboard_screen.dart';

part 'buy_asset_controller.g.dart';

@riverpod
class BuyAssetController extends _$BuyAssetController {
  @override
  FutureOr<void> build() {
    // Initial state is void (data) or loading/error
  }

  Future<void> buyAsset({
    required String symbol,
    required double price,
    required double quantity,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      final total = price * quantity;
      await ref.read(dashboardRemoteDataSourceProvider).createTransaction(
            userId,
            TransactionRequestModel.fromDomain(total, 'BUY'),
          );
    });
    if (state is AsyncData) {
      ref.invalidate(restDashboardProvider);
    }
  }

  Future<List<Asset>> searchAssets(String query) {
    return ref.read(dashboardRepositoryProvider).searchAssets(query);
  }
}
