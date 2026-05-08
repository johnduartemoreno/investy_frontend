class RecommendationModel {
  final String ticker;
  final String name;
  final String reason;
  final int suggestedAmountCents;
  final bool strong;

  const RecommendationModel({
    required this.ticker,
    required this.name,
    required this.reason,
    required this.suggestedAmountCents,
    required this.strong,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      reason: json['reason'] as String,
      suggestedAmountCents: json['suggestedAmountCents'] as int,
      strong: json['strong'] as bool,
    );
  }
}
