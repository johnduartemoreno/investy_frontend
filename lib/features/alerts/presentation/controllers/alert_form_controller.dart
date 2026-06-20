import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/alerts_remote_data_source.dart';
import '../providers/alerts_provider.dart';

part 'alert_form_controller.g.dart';

/// Pattern D — mutation controller for creating a price alert (B12).
/// Idle state is AsyncData(null). Invalidates [alertsProvider] only on success.
/// Deletion is done inline in the list tile (a fire-and-forget datasource call +
/// invalidate) — routing it through this autoDispose notifier from a `ref.read`
/// context disposes it mid-await and throws "Future already completed".
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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      await ref.read(alertsRemoteDataSourceProvider).createAlert(
            userId,
            symbol: symbol,
            direction: direction,
            targetPriceCents: targetPriceCents,
          );
    });
    if (state is AsyncData) {
      ref.invalidate(alertsProvider);
    }
  }
}
