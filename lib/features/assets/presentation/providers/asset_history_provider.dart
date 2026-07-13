import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/asset_history_model.dart';

part 'asset_history_provider.g.dart';

/// Asset daily price series, keyed by (symbol, range). The detail screen owns
/// its own range in local state and re-watches with the new value.
@riverpod
Future<AssetHistoryModel> assetHistory(Ref ref, String symbol, String range) {
  return ref
      .watch(dashboardRemoteDataSourceProvider)
      .getAssetHistory(symbol, range);
}
