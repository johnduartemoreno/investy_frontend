import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../models/price_alert_model.dart';

part 'alerts_remote_data_source.g.dart';

abstract class AlertsRemoteDataSource {
  /// Lists all price alerts for [userId], newest first.
  Future<List<PriceAlertModel>> getAlerts(String userId);

  /// Creates a price alert. Throws [DioException] on non-2xx (e.g. 409 when the
  /// active-alert limit is reached, 400 when the target is already met).
  Future<PriceAlertModel> createAlert(
    String userId, {
    required String symbol,
    required String direction,
    required int targetPriceCents,
  });

  /// Deletes the alert [alertId] owned by [userId].
  Future<void> deleteAlert(String userId, String alertId);
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  final Dio _dio;

  AlertsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<PriceAlertModel>> getAlerts(String userId) async {
    final response = await _dio.get('/api/v1/users/$userId/price-alerts');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PriceAlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PriceAlertModel> createAlert(
    String userId, {
    required String symbol,
    required String direction,
    required int targetPriceCents,
  }) async {
    final response = await _dio.post(
      '/api/v1/users/$userId/price-alerts',
      data: {
        'symbol': symbol,
        'direction': direction,
        'targetPriceCents': targetPriceCents,
      },
    );
    return PriceAlertModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAlert(String userId, String alertId) async {
    await _dio.delete('/api/v1/users/$userId/price-alerts/$alertId');
  }
}

@riverpod
AlertsRemoteDataSource alertsRemoteDataSource(Ref ref) {
  return AlertsRemoteDataSourceImpl(ref.watch(dioProvider));
}
