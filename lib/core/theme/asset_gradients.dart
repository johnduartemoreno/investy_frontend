import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Semantic gradient pairs for asset tickers, asset classes, and goal
/// categories. Single source of truth — never redefine these maps in
/// feature files.
abstract final class AssetGradients {
  static const List<Color> fallback = [
    AppTheme.brandPurple,
    AppTheme.brandPurpleLight,
  ];

  /// Green pair used for cash / savings iconography.
  static const List<Color> cash = [Color(0xFF065f46), Color(0xFF10b981)];

  static const Map<String, List<Color>> _byTicker = {
    'AAPL': [Color(0xFF1d4ed8), Color(0xFF3b82f6)],
    'VTI': cash,
    'BTC': [Color(0xFF78350f), Color(0xFFf59e0b)],
    'MSFT': [Color(0xFF4c1d95), Color(0xFF8b5cf6)],
    'IAU': [Color(0xFF881337), Color(0xFFf43f5e)],
  };

  static List<Color> ticker(String symbol) => _byTicker[symbol] ?? fallback;

  static List<Color> assetClass(String assetClass) {
    switch (assetClass) {
      case 'crypto':
        return const [Color(0xFF78350f), Color(0xFFf59e0b)];
      case 'etf':
        return fallback;
      default:
        return const [Color(0xFF1d4ed8), Color(0xFF3b82f6)];
    }
  }

  /// Single solid color per asset class for the allocation donut (segments +
  /// legend). Sourced from the ticker/class hues — the set
  /// {stock, crypto, etf, cash} passes the dataviz CVD validator (worst
  /// adjacent ΔE 86 deutan); the low-contrast pair vs surface is resolved by
  /// direct legend labels, never color alone.
  static const Map<String, Color> _allocationSolid = {
    'stock': Color(0xFF3b82f6),
    'crypto': Color(0xFFf59e0b),
    'etf': Color(0xFF8b5cf6),
    'cash': Color(0xFF10b981),
  };

  static Color allocationColor(String assetClass) =>
      _allocationSolid[assetClass] ?? fallback[0];

  static List<Color> goalCategory(String category) {
    switch (category.toLowerCase()) {
      case 'car':
        return const [Color(0xFF1d4ed8), Color(0xFF3b82f6)];
      case 'home':
        return cash;
      case 'vacation':
      case 'travel':
        return const [Color(0xFF0369a1), Color(0xFF38bdf8)];
      case 'education':
        return fallback;
      case 'emergency':
        return const [Color(0xFF991b1b), Color(0xFFf87171)];
      case 'health':
        return const [Color(0xFF9d174d), Color(0xFFf472b6)];
      default:
        return const [Color(0xFF78350f), Color(0xFFf59e0b)];
    }
  }
}
