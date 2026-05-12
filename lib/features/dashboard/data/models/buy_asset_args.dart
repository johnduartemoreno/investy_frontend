import 'package:flutter/material.dart';

/// Navigation extras for the buy-asset route.
/// [signalLabel] and [signalColor] are optional — only set when navigating
/// from an Owl AI rec card so the SignalBadge can be shown.
class BuyAssetArgs {
  final String symbol;
  final String name;
  final int priceCents;
  final String? signalLabel;
  final Color? signalColor;

  const BuyAssetArgs({
    required this.symbol,
    required this.name,
    required this.priceCents,
    this.signalLabel,
    this.signalColor,
  });
}
