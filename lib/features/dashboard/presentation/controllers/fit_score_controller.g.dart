// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fit_score_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fitScoreControllerHash() =>
    r'fd90f5c109b594379492b9e5f8bf006b349a6050';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$FitScoreController
    extends BuildlessAutoDisposeAsyncNotifier<FitScoreModel?> {
  late final String scope;

  FutureOr<FitScoreModel?> build(
    String scope,
  );
}

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
/// [scope] gives each screen its own instance. Two screens ask this question at
/// once — asset detail (`amountCents: 0`, "how does what I hold fit me?") and
/// buy (a purchase being composed) — and `push` keeps detail mounted and
/// listening underneath. With one shared instance the buy screen's answer
/// repainted the detail screen's card, and the guard both screens carry
/// compares only `fit.symbol`, which is precisely the field that matches: you
/// reach buy from detail with the same asset. Found by the pre-merge audit,
/// 2026-08-26.
///
/// Copied from [FitScoreController].
@ProviderFor(FitScoreController)
const fitScoreControllerProvider = FitScoreControllerFamily();

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
/// [scope] gives each screen its own instance. Two screens ask this question at
/// once — asset detail (`amountCents: 0`, "how does what I hold fit me?") and
/// buy (a purchase being composed) — and `push` keeps detail mounted and
/// listening underneath. With one shared instance the buy screen's answer
/// repainted the detail screen's card, and the guard both screens carry
/// compares only `fit.symbol`, which is precisely the field that matches: you
/// reach buy from detail with the same asset. Found by the pre-merge audit,
/// 2026-08-26.
///
/// Copied from [FitScoreController].
class FitScoreControllerFamily extends Family<AsyncValue<FitScoreModel?>> {
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
  /// [scope] gives each screen its own instance. Two screens ask this question at
  /// once — asset detail (`amountCents: 0`, "how does what I hold fit me?") and
  /// buy (a purchase being composed) — and `push` keeps detail mounted and
  /// listening underneath. With one shared instance the buy screen's answer
  /// repainted the detail screen's card, and the guard both screens carry
  /// compares only `fit.symbol`, which is precisely the field that matches: you
  /// reach buy from detail with the same asset. Found by the pre-merge audit,
  /// 2026-08-26.
  ///
  /// Copied from [FitScoreController].
  const FitScoreControllerFamily();

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
  /// [scope] gives each screen its own instance. Two screens ask this question at
  /// once — asset detail (`amountCents: 0`, "how does what I hold fit me?") and
  /// buy (a purchase being composed) — and `push` keeps detail mounted and
  /// listening underneath. With one shared instance the buy screen's answer
  /// repainted the detail screen's card, and the guard both screens carry
  /// compares only `fit.symbol`, which is precisely the field that matches: you
  /// reach buy from detail with the same asset. Found by the pre-merge audit,
  /// 2026-08-26.
  ///
  /// Copied from [FitScoreController].
  FitScoreControllerProvider call(
    String scope,
  ) {
    return FitScoreControllerProvider(
      scope,
    );
  }

  @override
  FitScoreControllerProvider getProviderOverride(
    covariant FitScoreControllerProvider provider,
  ) {
    return call(
      provider.scope,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fitScoreControllerProvider';
}

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
/// [scope] gives each screen its own instance. Two screens ask this question at
/// once — asset detail (`amountCents: 0`, "how does what I hold fit me?") and
/// buy (a purchase being composed) — and `push` keeps detail mounted and
/// listening underneath. With one shared instance the buy screen's answer
/// repainted the detail screen's card, and the guard both screens carry
/// compares only `fit.symbol`, which is precisely the field that matches: you
/// reach buy from detail with the same asset. Found by the pre-merge audit,
/// 2026-08-26.
///
/// Copied from [FitScoreController].
class FitScoreControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    FitScoreController, FitScoreModel?> {
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
  /// [scope] gives each screen its own instance. Two screens ask this question at
  /// once — asset detail (`amountCents: 0`, "how does what I hold fit me?") and
  /// buy (a purchase being composed) — and `push` keeps detail mounted and
  /// listening underneath. With one shared instance the buy screen's answer
  /// repainted the detail screen's card, and the guard both screens carry
  /// compares only `fit.symbol`, which is precisely the field that matches: you
  /// reach buy from detail with the same asset. Found by the pre-merge audit,
  /// 2026-08-26.
  ///
  /// Copied from [FitScoreController].
  FitScoreControllerProvider(
    String scope,
  ) : this._internal(
          () => FitScoreController()..scope = scope,
          from: fitScoreControllerProvider,
          name: r'fitScoreControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fitScoreControllerHash,
          dependencies: FitScoreControllerFamily._dependencies,
          allTransitiveDependencies:
              FitScoreControllerFamily._allTransitiveDependencies,
          scope: scope,
        );

  FitScoreControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final String scope;

  @override
  FutureOr<FitScoreModel?> runNotifierBuild(
    covariant FitScoreController notifier,
  ) {
    return notifier.build(
      scope,
    );
  }

  @override
  Override overrideWith(FitScoreController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FitScoreControllerProvider._internal(
        () => create()..scope = scope,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<FitScoreController, FitScoreModel?>
      createElement() {
    return _FitScoreControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FitScoreControllerProvider && other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FitScoreControllerRef
    on AutoDisposeAsyncNotifierProviderRef<FitScoreModel?> {
  /// The parameter `scope` of this provider.
  String get scope;
}

class _FitScoreControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<FitScoreController,
        FitScoreModel?> with FitScoreControllerRef {
  _FitScoreControllerProviderElement(super.provider);

  @override
  String get scope => (origin as FitScoreControllerProvider).scope;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
