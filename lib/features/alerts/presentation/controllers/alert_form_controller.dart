import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/current_user_provider.dart';
import '../../data/datasources/alerts_remote_data_source.dart';

part 'alert_form_controller.g.dart';

/// Pattern D — mutation controller for creating a price alert (B12).
/// Idle state is AsyncData(null).
///
/// The list refresh ([alertsProvider] invalidation) is NOT done here: the
/// sheet's success listener pops the modal, which disposes this autoDispose
/// notifier mid-flight — an `ref.invalidate` issued from this method right
/// after the await is dropped, so the new alert never shows in the list. The
/// sheet invalidates instead, from a ref that is still alive when it fires.
/// Same reason deletion is done inline in the list tile.
@riverpod
class AlertFormController extends _$AlertFormController {
  @override
  FutureOr<void> build() {}

  Future<void> createAlert({
    required String symbol,
    required String direction,
    required int targetPriceCents,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('User not authenticated');
      await ref.read(alertsRemoteDataSourceProvider).createAlert(
            userId,
            symbol: symbol,
            direction: direction,
            targetPriceCents: targetPriceCents,
          );
    });
  }
}
