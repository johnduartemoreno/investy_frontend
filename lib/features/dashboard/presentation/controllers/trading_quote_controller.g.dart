// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_quote_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tradingQuoteControllerHash() =>
    r'5dbbd31f87d501618ae24a74eb59472e3a1a057c';

/// Holds the priced quote for the order currently being composed.
///
/// Imperative (Pattern D) rather than a family read: the inputs change on every
/// keystroke, and a family keyed on quantity would spin up a provider per character.
/// The screen debounces and calls [fetch].
///
/// State meanings:
///  - `AsyncData(null)` — idle, nothing to quote yet (no asset or no quantity)
///  - `AsyncData(quote)` — priced; show the cost breakdown
///  - `AsyncLoading` — in flight
///  - `AsyncError` — quote failed; show no fee rather than a wrong fee
///
/// Copied from [TradingQuoteController].
@ProviderFor(TradingQuoteController)
final tradingQuoteControllerProvider = AutoDisposeAsyncNotifierProvider<
    TradingQuoteController, TradingQuoteModel?>.internal(
  TradingQuoteController.new,
  name: r'tradingQuoteControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tradingQuoteControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TradingQuoteController = AutoDisposeAsyncNotifier<TradingQuoteModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
