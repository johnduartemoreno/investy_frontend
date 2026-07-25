/// A priced order, straight from the engine that will execute it.
///
/// These are not estimates. The backend quotes with the same rules, the same
/// arithmetic and the same rounding it uses to charge, so what is shown here is what
/// gets billed. That is why nothing in this file recomputes a fee.
class TradingQuoteModel {
  const TradingQuoteModel({
    required this.totalBeforeFeesCents,
    required this.feeCents,
    required this.totalCents,
    required this.components,
  });

  /// Order value before fees, in USD cents.
  final int totalBeforeFeesCents;

  /// Authoritative total fee, in USD cents.
  final int feeCents;

  /// What actually moves: notional + fee on a buy, notional − fee on a sell.
  final int totalCents;

  /// Per-charge detail. Rounded for display, so these will not always add up to
  /// [feeCents] — the rounding belongs to the total, not to any single charge.
  final List<TradingQuoteComponent> components;

  double get totalBeforeFees => totalBeforeFeesCents / 100.0;
  double get fee => feeCents / 100.0;
  double get total => totalCents / 100.0;

  factory TradingQuoteModel.fromJson(Map<String, dynamic> json) {
    // Strict on money (B40-F7). A missing fee silently read as 0 would show the user
    // a free trade and then charge them — exactly the class of lie this sprint exists
    // to remove. Let it throw; the screen shows its error state.
    return TradingQuoteModel(
      totalBeforeFeesCents: json['totalBeforeFeesCents'] as int,
      feeCents: json['feeCents'] as int,
      totalCents: json['totalCents'] as int,
      components: (json['components'] as List<dynamic>? ?? const [])
          .map((e) => TradingQuoteComponent.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class TradingQuoteComponent {
  const TradingQuoteComponent(
      {required this.chargeType, required this.feeCents});

  /// 'investy_commission' | 'sec_31' | 'finra_taf' | 'finra_cat' | 'broker_spread'
  final String chargeType;
  final int feeCents;

  double get fee => feeCents / 100.0;

  factory TradingQuoteComponent.fromJson(Map<String, dynamic> json) =>
      TradingQuoteComponent(
        chargeType: json['chargeType'] as String,
        feeCents: json['feeCents'] as int,
      );
}

/// Static trading rules. Cached — these change on the order of regulatory events.
class TradingConfigModel {
  const TradingConfigModel({required this.minBuyNotionalCents});

  /// Mirrors the server's floor so the UI can reject an obviously-too-small order
  /// without a round-trip. Never the authority: the server re-checks every order.
  final int minBuyNotionalCents;

  double get minBuyNotional => minBuyNotionalCents / 100.0;

  factory TradingConfigModel.fromJson(Map<String, dynamic> json) =>
      TradingConfigModel(
        minBuyNotionalCents: json['minBuyNotionalCents'] as int,
      );
}
