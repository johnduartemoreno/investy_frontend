import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/alerts_remote_data_source.dart';
import '../../data/models/price_alert_model.dart';

/// Pattern A — simple REST read of the user's price alerts (B12).
final alertsProvider =
    FutureProvider.autoDispose<List<PriceAlertModel>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  return ref.watch(alertsRemoteDataSourceProvider).getAlerts(userId);
});
