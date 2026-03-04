import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/asset.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

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
      await ref.read(dashboardRepositoryProvider).buyAsset(
            symbol: symbol,
            price: price,
            quantity: quantity,
          );
    });
  }

  Future<List<Asset>> searchAssets(String query) {
    return ref.read(dashboardRepositoryProvider).searchAssets(query);
  }
}
