import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../models/dashboard_response_model.dart';
import '../models/transaction_request_model.dart';

part 'dashboard_remote_data_source.g.dart';

abstract class DashboardRemoteDataSource {
  /// Fetches the dashboard summary for [userId] from the Go REST backend.
  Future<DashboardResponseModel> getDashboard(String userId);

  /// Posts a new transaction for [userId] to the Go REST backend.
  /// Throws on non-2xx response.
  Future<void> createTransaction(
    String userId,
    TransactionRequestModel request,
  );
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<DashboardResponseModel> getDashboard(String userId) async {
    final response = await _dio.get('/api/v1/users/$userId/dashboard');
    return DashboardResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> createTransaction(
    String userId,
    TransactionRequestModel request,
  ) async {
    await _dio.post(
      '/api/v1/users/$userId/transactions',
      data: request.toJson(),
    );
  }
}

@riverpod
DashboardRemoteDataSource dashboardRemoteDataSource(Ref ref) {
  return DashboardRemoteDataSourceImpl(ref.watch(dioProvider));
}
