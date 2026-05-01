import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../models/kyc_status_model.dart';

part 'kyc_remote_datasource.g.dart';

abstract class KycRemoteDataSource {
  Future<KycStatusModel> getStatus(String userId);
  Future<String> initFlow(String userId);
}

class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final Dio _dio;
  KycRemoteDataSourceImpl(this._dio);

  @override
  Future<KycStatusModel> getStatus(String userId) async {
    final response = await _dio.get('/api/v1/users/$userId/kyc/status');
    return KycStatusModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> initFlow(String userId) async {
    final response =
        await _dio.post('/api/v1/users/$userId/kyc/init');
    final data = response.data as Map<String, dynamic>;
    final token = data['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('KYC init: empty access token from backend');
    }
    return token;
  }
}

@riverpod
KycRemoteDataSource kycRemoteDataSource(Ref ref) =>
    KycRemoteDataSourceImpl(ref.watch(dioProvider));
