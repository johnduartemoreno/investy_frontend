import 'recommendation_model.dart';

/// Snapshot of the user's financial state when the session was generated.
class OwlContextSnapshot {
  final int portfolioValueCents;
  final int cashBalanceCents;
  final String riskProfile;
  final int holdingsCount;

  const OwlContextSnapshot({
    required this.portfolioValueCents,
    required this.cashBalanceCents,
    required this.riskProfile,
    required this.holdingsCount,
  });

  factory OwlContextSnapshot.fromJson(Map<String, dynamic> json) {
    return OwlContextSnapshot(
      portfolioValueCents: json['portfolioValueCents'] as int,
      cashBalanceCents: json['cashBalanceCents'] as int,
      riskProfile: json['riskProfile'] as String,
      holdingsCount: json['holdingsCount'] as int,
    );
  }

  /// USD dollars for display via CurrencyFormatter.
  double get portfolioValue => portfolioValueCents / 100.0;
  double get cashBalance => cashBalanceCents / 100.0;
}

/// One persisted Owl AI recommendation session (B29).
class OwlSessionModel {
  final String id;
  final String language;
  final DateTime createdAt;
  final List<RecommendationModel> recommendations;
  final OwlContextSnapshot contextSnapshot;

  const OwlSessionModel({
    required this.id,
    required this.language,
    required this.createdAt,
    required this.recommendations,
    required this.contextSnapshot,
  });

  factory OwlSessionModel.fromJson(Map<String, dynamic> json) {
    return OwlSessionModel(
      id: json['id'] as String,
      language: json['language'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      contextSnapshot: OwlContextSnapshot.fromJson(
        json['contextSnapshot'] as Map<String, dynamic>,
      ),
    );
  }

  /// Ticker symbols of this session's recommendations (for chip display).
  List<String> get tickers =>
      recommendations.map((r) => r.ticker).toList(growable: false);
}
