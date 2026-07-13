import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../models/asset_search_result_model.dart';
import '../models/create_goal_request_model.dart';
import '../models/dashboard_response_model.dart';
import '../models/goal_response_model.dart';
import '../models/owl_session_model.dart';
import '../models/recommendation_model.dart';
import '../models/transaction_request_model.dart';
import '../../../../features/assets/data/models/asset_history_model.dart';
import '../../../../features/portfolio/data/models/portfolio_history_model.dart';
import '../../../../features/portfolio/data/models/portfolio_response_model.dart';

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

  /// Fetches all financial goals for [userId] from the Go REST backend.
  Future<List<GoalResponseModel>> getGoals(String userId);

  /// Creates a new financial goal for [userId]. Throws on non-2xx response.
  Future<GoalResponseModel> createGoal(
    String userId,
    CreateGoalRequestModel request,
  );

  /// Fetches portfolio holdings for [userId] from the Go REST backend.
  Future<PortfolioResponseModel> getPortfolio(String userId);

  /// Daily portfolio-value series for the given range (1W|1M|3M|1Y|ALL).
  Future<PortfolioHistoryModel> getPortfolioHistory(
      String userId, String range);

  /// Daily closing-price series for an asset (1W|1M|3M|1Y|ALL).
  Future<AssetHistoryModel> getAssetHistory(String symbol, String range);

  /// Searches assets by symbol or name prefix. Returns up to 10 results.
  Future<List<AssetSearchResultModel>> searchAssets(String query);

  /// Fetches AI-generated investment recommendations for [userId].
  /// [language] sets the language of AI-generated reasons (en/es/pt).
  /// Pass [forceRefresh] = true to bypass the server-side cache.
  Future<List<RecommendationModel>> getRecommendations(
    String userId, {
    String language = 'en',
    bool forceRefresh = false,
  });

  /// Fetches persisted Owl AI recommendation sessions, newest first (B29).
  Future<List<OwlSessionModel>> getRecommendationHistory(
    String userId, {
    int limit = 20,
    int offset = 0,
  });
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

  @override
  Future<List<GoalResponseModel>> getGoals(String userId) async {
    final response = await _dio.get('/api/v1/users/$userId/goals');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => GoalResponseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GoalResponseModel> createGoal(
    String userId,
    CreateGoalRequestModel request,
  ) async {
    final response = await _dio.post(
      '/api/v1/users/$userId/goals',
      data: request.toJson(),
    );
    return GoalResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PortfolioResponseModel> getPortfolio(String userId) async {
    final response = await _dio.get('/api/v1/users/$userId/portfolio');
    return PortfolioResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PortfolioHistoryModel> getPortfolioHistory(
      String userId, String range) async {
    final response = await _dio.get(
      '/api/v1/users/$userId/portfolio/history',
      queryParameters: {'range': range},
    );
    return PortfolioHistoryModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<AssetHistoryModel> getAssetHistory(String symbol, String range) async {
    final response = await _dio.get(
      '/api/v1/assets/$symbol/history',
      queryParameters: {'range': range},
    );
    return AssetHistoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<AssetSearchResultModel>> searchAssets(String query) async {
    final response =
        await _dio.get('/api/v1/assets', queryParameters: {'q': query});
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AssetSearchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RecommendationModel>> getRecommendations(
    String userId, {
    String language = 'en',
    bool forceRefresh = false,
  }) async {
    final params = <String, String>{'lang': language};
    if (forceRefresh) params['refresh'] = 'true';
    final response = await _dio.get(
      '/api/v1/users/$userId/recommendations',
      queryParameters: params,
      options: Options(headers: {'Accept-Language': language}),
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['recommendations'] as List<dynamic>;
    return list
        .map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OwlSessionModel>> getRecommendationHistory(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/api/v1/users/$userId/recommendations/history',
      queryParameters: {'limit': '$limit', 'offset': '$offset'},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['sessions'] as List<dynamic>;
    return list
        .map((e) => OwlSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

@riverpod
DashboardRemoteDataSource dashboardRemoteDataSource(Ref ref) {
  return DashboardRemoteDataSourceImpl(ref.watch(dioProvider));
}
