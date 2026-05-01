import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../models/broker_account_model.dart';

part 'broker_remote_datasource.g.dart';

abstract class BrokerRemoteDataSource {
  Future<BrokerAccountModel> getAccount(String userId);
  Future<BrokerAccountModel> openAccount(String userId);
}

class BrokerRemoteDataSourceImpl implements BrokerRemoteDataSource {
  final Dio _dio;
  BrokerRemoteDataSourceImpl(this._dio);

  @override
  Future<BrokerAccountModel> getAccount(String userId) async {
    final response =
        await _dio.get('/api/v1/users/$userId/broker-account');
    return BrokerAccountModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BrokerAccountModel> openAccount(String userId) async {
    final response =
        await _dio.post('/api/v1/users/$userId/broker-account');
    return BrokerAccountModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
BrokerRemoteDataSource brokerRemoteDataSource(Ref ref) =>
    BrokerRemoteDataSourceImpl(ref.watch(dioProvider));
