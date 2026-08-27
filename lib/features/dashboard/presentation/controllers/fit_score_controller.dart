import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/current_user_provider.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/fit_score_model.dart';

part 'fit_score_controller.g.dart';

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
@riverpod
class FitScoreController extends _$FitScoreController {
  @override
  FutureOr<FitScoreModel?> build(String scope) => null;

  /// Monotonic request counter. `AsyncValue.guard` assigns whatever finishes,
  /// not whatever was asked last, and the backend calls Claude synchronously
  /// with a 30s timeout — so typing `10`, pausing, then `1000` can land the
  /// slower first answer on top of the newer one. The amount is nowhere on the
  /// card, so nothing would look wrong. Anything but the newest reply is
  /// dropped.
  int _seq = 0;

  /// Assesses the purchase. Returns to idle when there is nothing to assess.
  ///
  /// [language] comes from the caller rather than being read here so the screen
  /// stays the single place that decides what locale the user is in.
  Future<void> fetch({
    required String symbol,
    required int amountCents,
    String? goalId,
    String language = 'en',
  }) async {
    // Zero is a legitimate amount and a different question — "how does what I
    // already hold fit me?", which is what the asset detail screen asks. This
    // guard read `<= 0` and silently returned to idle, so that card never
    // rendered at all: the backend accepted zero, the client refused to ask.
    // Found by the S19 audit, 2026-08-12.
    // Through the provider, not FirebaseAuth directly: that is what the rest
    // of the app does, and it is what lets a test drive this without
    // bootstrapping Firebase — including the ordering rule below, which is the
    // half of the fix a user could never see going wrong.
    final userId = ref.read(currentUserIdProvider);
    if (userId == null || symbol.isEmpty || amountCents < 0) {
      state = const AsyncData(null);
      return;
    }

    final mine = ++_seq;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return ref.read(dashboardRemoteDataSourceProvider).getFitScore(
            userId,
            symbol: symbol,
            amountCents: amountCents,
            goalId: goalId,
            language: language,
          );
    });
    // A reply that is no longer the one we are waiting for describes a purchase
    // the user has already moved on from.
    if (mine != _seq) return;
    state = result;
  }

  /// Clears the assessment — when the user deselects the asset, or after a
  /// purchase, since the answer describes a portfolio that just changed.
  void clear() {
    _seq++; // also cancels anything in flight
    state = const AsyncData(null);
  }
}
