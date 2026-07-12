import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../../dashboard/data/models/transaction_request_model.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

part 'top_up_controller.g.dart';

/// Submits a cash DEPOSIT and busts the dashboard cache on success.
@riverpod
class TopUpController extends _$TopUpController {
  @override
  FutureOr<void> build() {}

  Future<void> deposit(double amountDollars) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      await ref.read(dashboardRemoteDataSourceProvider).createTransaction(
            userId,
            TransactionRequestModel.forCash(amountDollars, 'DEPOSIT'),
          );
    });
    if (state is AsyncData) {
      ref.invalidate(restDashboardProvider);
    }
  }
}
