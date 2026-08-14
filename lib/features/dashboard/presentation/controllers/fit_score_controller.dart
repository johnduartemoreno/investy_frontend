import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
@riverpod
class FitScoreController extends _$FitScoreController {
  @override
  FutureOr<FitScoreModel?> build() => null;

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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || symbol.isEmpty || amountCents < 0) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(dashboardRemoteDataSourceProvider).getFitScore(
            userId,
            symbol: symbol,
            amountCents: amountCents,
            goalId: goalId,
            language: language,
          );
    });
  }

  /// Clears the assessment — when the user deselects the asset, or after a
  /// purchase, since the answer describes a portfolio that just changed.
  void clear() => state = const AsyncData(null);
}
