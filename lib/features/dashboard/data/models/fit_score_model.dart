/// How well a prospective purchase fits *this* user (S19).
///
/// Nothing in this file computes anything. Every score, threshold and judgement
/// was decided on the server against the user's own records; the app's job is to
/// translate reason keys into sentences and lay them out. Recomputing any of it
/// here is how two parts of the same screen end up disagreeing.
class FitScoreModel {
  const FitScoreModel({
    required this.symbol,
    required this.assetName,
    required this.assetClass,
    required this.goalName,
    required this.score,
    required this.showScore,
    required this.cappedBy,
    required this.explanation,
    required this.components,
    required this.volatilityPct,
    required this.confidence,
  });

  final String symbol;
  final String assetName;
  final String assetClass;

  /// The goal this purchase was assessed against, empty when none was chosen.
  final String goalName;

  /// Null when the score must not be shown — either it could not be computed,
  /// or confidence was too low to stand behind it. The server withholds the
  /// number itself rather than sending it with a flag, so there is nothing here
  /// to leak by accident.
  final int? score;
  final bool showScore;

  /// Which prudence component held the score down ('concentration' | 'horizon'),
  /// empty when none did. Shown so the number never contradicts the breakdown
  /// the user is looking at.
  final String cappedBy;

  /// The owl's prose. Empty whenever the model was unavailable or said something
  /// that did not survive validation — the screen is built to work without it.
  final String explanation;

  final FitComponentsModel components;

  /// Observed annualised volatility, null when it could not be measured.
  final double? volatilityPct;

  final FitConfidenceModel confidence;

  factory FitScoreModel.fromJson(Map<String, dynamic> json) => FitScoreModel(
        symbol: json['symbol'] as String,
        assetName: json['assetName'] as String? ?? '',
        assetClass: json['assetClass'] as String? ?? '',
        goalName: json['goalName'] as String? ?? '',
        // Deliberately nullable, never defaulted: a missing score means "not
        // shown", and a 0 would tell the user this is a terrible fit.
        score: json['score'] as int?,
        showScore: json['showScore'] as bool? ?? false,
        cappedBy: json['cappedBy'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        components: FitComponentsModel.fromJson(
            json['components'] as Map<String, dynamic>),
        volatilityPct: (json['volatilityPct'] as num?)?.toDouble(),
        confidence: FitConfidenceModel.fromJson(
            json['confidence'] as Map<String, dynamic>),
      );
}

class FitComponentsModel {
  const FitComponentsModel({
    required this.profile,
    required this.horizon,
    required this.diversification,
    required this.concentration,
    required this.volatility,
  });

  final FitComponentModel profile;
  final FitComponentModel horizon;
  final FitComponentModel diversification;
  final FitComponentModel concentration;
  final FitComponentModel volatility;

  /// In the order the breakdown is displayed.
  List<FitComponentModel> get all =>
      [profile, horizon, diversification, concentration, volatility];

  factory FitComponentsModel.fromJson(Map<String, dynamic> json) =>
      FitComponentsModel(
        profile: FitComponentModel.fromJson(
            json['profile'] as Map<String, dynamic>, FitComponentKind.profile),
        horizon: FitComponentModel.fromJson(
            json['horizon'] as Map<String, dynamic>, FitComponentKind.horizon),
        diversification: FitComponentModel.fromJson(
            json['diversification'] as Map<String, dynamic>,
            FitComponentKind.diversification),
        concentration: FitComponentModel.fromJson(
            json['concentration'] as Map<String, dynamic>,
            FitComponentKind.concentration),
        volatility: FitComponentModel.fromJson(
            json['volatility'] as Map<String, dynamic>,
            FitComponentKind.volatility),
      );
}

enum FitComponentKind {
  profile,
  horizon,
  diversification,
  concentration,
  volatility,
}

class FitComponentModel {
  const FitComponentModel({
    required this.kind,
    required this.score,
    required this.reason,
    required this.caveat,
  });

  final FitComponentKind kind;

  /// Null means "we could not measure this", which is a different statement
  /// from a zero — a zero says the fit is bad. The row renders differently for
  /// each, and collapsing them here would state something false about the
  /// user's situation (§Data Governance).
  final int? score;

  /// Stable key from the backend, mapped to a translated sentence by the UI.
  final String reason;

  /// A weakness the component declared about its own data, empty when none.
  final String caveat;

  bool get scored => score != null;

  factory FitComponentModel.fromJson(
          Map<String, dynamic> json, FitComponentKind kind) =>
      FitComponentModel(
        kind: kind,
        score: json['score'] as int?,
        reason: json['reason'] as String? ?? '',
        caveat: json['caveat'] as String? ?? '',
      );
}

class FitConfidenceModel {
  const FitConfidenceModel({
    required this.pct,
    required this.level,
    required this.aboutYou,
    required this.aboutOurData,
  });

  final int pct;

  /// 'confidence_high' | 'confidence_medium' | 'confidence_low'
  final String level;

  /// What the user can tell us: no risk profile, no goal, no portfolio yet.
  final List<String> aboutYou;

  /// What is missing on our side. Kept apart so our data gap is never phrased
  /// as something the user forgot to do.
  final List<String> aboutOurData;

  factory FitConfidenceModel.fromJson(Map<String, dynamic> json) =>
      FitConfidenceModel(
        pct: json['pct'] as int? ?? 0,
        level: json['level'] as String? ?? 'confidence_low',
        aboutYou: (json['aboutYou'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(growable: false),
        aboutOurData: (json['aboutOurData'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(growable: false),
      );
}
