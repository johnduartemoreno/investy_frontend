// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$portfolioHistoryHash() => r'7fb18243d2c9066816dde0e877d827f158e83fe4';

/// Portfolio daily-value series (Pattern B — reacts to the selected range).
///
/// Copied from [portfolioHistory].
@ProviderFor(portfolioHistory)
final portfolioHistoryProvider =
    AutoDisposeFutureProvider<PortfolioHistoryModel>.internal(
  portfolioHistory,
  name: r'portfolioHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$portfolioHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PortfolioHistoryRef
    = AutoDisposeFutureProviderRef<PortfolioHistoryModel>;
String _$portfolioHistoryRangeHash() =>
    r'0779937c843310c14d82ff2c4fc371a1863f80a9';

/// Selected range for the portfolio-value chart (Pattern D3 — sync state).
/// Tapping a range chip calls `set`, which reactively re-fetches the history.
///
/// Copied from [PortfolioHistoryRange].
@ProviderFor(PortfolioHistoryRange)
final portfolioHistoryRangeProvider =
    AutoDisposeNotifierProvider<PortfolioHistoryRange, String>.internal(
  PortfolioHistoryRange.new,
  name: r'portfolioHistoryRangeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$portfolioHistoryRangeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PortfolioHistoryRange = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
