import 'package:flutter/material.dart';

/// Navigation extras for the buy-asset route.
/// [signalLabel] and [signalColor] are optional — only set when navigating
/// from an Owl AI rec card so the SignalBadge can be shown.
class BuyAssetArgs {
  /// Pre-selected asset, when navigating from an Owl AI rec card. Null when
  /// navigating from a goal ("invest toward this goal") with no asset chosen yet.
  final String? symbol;
  final String? name;
  final int? priceCents;
  final String? signalLabel;
  final Color? signalColor;

  /// Optional goal to pre-assign this purchase to (set when navigating from a
  /// goal detail screen's "Invest toward this goal" button). [goalName] is shown
  /// in the selector so the user can confirm the pre-selection.
  final String? goalId;
  final String? goalName;

  const BuyAssetArgs({
    this.symbol,
    this.name,
    this.priceCents,
    this.signalLabel,
    this.signalColor,
    this.goalId,
    this.goalName,
  });
}
