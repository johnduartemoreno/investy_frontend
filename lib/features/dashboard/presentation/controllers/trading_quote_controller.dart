import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/trading_quote_model.dart';

part 'trading_quote_controller.g.dart';

/// Holds the priced quote for the order currently being composed.
///
/// Imperative (Pattern D) rather than a family read: the inputs change on every
/// keystroke, and a family keyed on quantity would spin up a provider per character.
/// The screen debounces and calls [fetch].
///
/// State meanings:
///  - `AsyncData(null)` — idle, nothing to quote yet (no asset or no quantity)
///  - `AsyncData(quote)` — priced; show the cost breakdown
///  - `AsyncLoading` — in flight
///  - `AsyncError` — quote failed; show no fee rather than a wrong fee
@riverpod
class TradingQuoteController extends _$TradingQuoteController {
  @override
  FutureOr<TradingQuoteModel?> build() => null;

  /// Prices the order. Returns to idle when there is nothing meaningful to price.
  Future<void> fetch({
    required String symbol,
    required String side,
    required double quantity,
    required int priceCents,
  }) async {
    if (quantity <= 0 || priceCents <= 0) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(dashboardRemoteDataSourceProvider).getTradingQuote(
            symbol: symbol,
            side: side,
            quantity: quantity,
            priceCents: priceCents,
          );
    });
  }

  /// Clears the quote — e.g. when the user deselects the asset.
  void clear() => state = const AsyncData(null);
}

/// The server's order floor, mirrored for instant client-side feedback.
///
/// Never the authority: the server re-checks every order regardless. If this fetch
/// fails the screen simply skips the local pre-check and lets the server answer.
final tradingConfigProvider =
    FutureProvider.autoDispose<TradingConfigModel>((ref) async {
  return ref.watch(dashboardRemoteDataSourceProvider).getTradingConfig();
});
