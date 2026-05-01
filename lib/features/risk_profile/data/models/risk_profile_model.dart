class RiskProfileModel {
  final int score;
  final String profile; // conservative | moderate | aggressive

  const RiskProfileModel({required this.score, required this.profile});

  factory RiskProfileModel.fromJson(Map<String, dynamic> json) {
    return RiskProfileModel(
      score: json['score'] as int,
      profile: json['profile'] as String,
    );
  }

  bool get isConservative => profile == 'conservative';
  bool get isModerate => profile == 'moderate';
  bool get isAggressive => profile == 'aggressive';
}
