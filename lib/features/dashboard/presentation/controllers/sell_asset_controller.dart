import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

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
      await ref
          .read(dashboardRepositoryProvider)
          .sellAsset(symbol, currentPrice, quantity);
    });
  }
}
