// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fit_score_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fitScoreControllerHash() =>
    r'c91d816d2c908b98daadf063dafb2b0c8cc38f0b';

/// Holds the Fit Score for the purchase currently being composed (S19-G7).
///
/// Imperative (Pattern D) rather than a family read, for the same reason as
/// [TradingQuoteController]: the inputs — amount, goal — change while the user
/// types, and a family keyed on the amount would spin up a provider per
/// keystroke. The screen debounces and calls [fetch].
///
/// State meanings:
///  - `AsyncData(null)` — idle: no asset chosen, or no amount entered yet
///  - `AsyncData(fit)`  — assessed; show the verdict and, behind it, the breakdown
///  - `AsyncLoading`    — in flight
///  - `AsyncError`      — the assessment failed; show nothing rather than a
///    partial verdict, because a fit score built from an error is a claim about
///    someone's money made from nothing
///
/// Copied from [FitScoreController].
@ProviderFor(FitScoreController)
final fitScoreControllerProvider = AutoDisposeAsyncNotifierProvider<
    FitScoreController, FitScoreModel?>.internal(
  FitScoreController.new,
  name: r'fitScoreControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fitScoreControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FitScoreController = AutoDisposeAsyncNotifier<FitScoreModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
