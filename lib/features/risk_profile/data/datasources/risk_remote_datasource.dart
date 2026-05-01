import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../models/risk_profile_model.dart';

part 'risk_remote_datasource.g.dart';

abstract class RiskRemoteDataSource {
  Future<RiskProfileModel?> getProfile(String userId);
  Future<RiskProfileModel> submitAnswers(String userId, Map<int, int> answers);
}

class RiskRemoteDataSourceImpl implements RiskRemoteDataSource {
  final Dio _dio;
  RiskRemoteDataSourceImpl(this._dio);

  @override
  Future<RiskProfileModel?> getProfile(String userId) async {
    try {
      final response = await _dio.get('/api/v1/users/$userId/risk-profile');
      return RiskProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<RiskProfileModel> submitAnswers(
      String userId, Map<int, int> answers) async {
    final response = await _dio.post(
      '/api/v1/users/$userId/risk-profile',
      data: {'answers': answers},
    );
    return RiskProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
RiskRemoteDataSource riskRemoteDataSource(Ref ref) =>
    RiskRemoteDataSourceImpl(ref.watch(dioProvider));
