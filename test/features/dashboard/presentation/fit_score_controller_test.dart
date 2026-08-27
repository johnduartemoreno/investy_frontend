import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/core/providers/current_user_provider.dart';
import 'package:investy/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:investy/features/dashboard/data/models/fit_score_model.dart';
import 'package:investy/features/dashboard/presentation/controllers/fit_score_controller.dart';

/// Both defects these tests pin were found by the pre-merge audit on
/// 2026-08-26, and neither is cosmetic: each puts a verdict about someone's
/// money above a Buy button while describing a different purchase.
FitScoreModel _fit(String symbol, int score) => FitScoreModel.fromJson({
      'symbol': symbol,
      'assetName': symbol,
      'assetClass': 'crypto',
      'goalName': '',
      'score': score,
      'showScore': true,
      'cappedBy': '',
      'explanation': '',
      'volatilityPct': null,
      'components': {
        'profile': {'score': score, 'reason': 'class_core'},
        'horizon': {'score': null, 'reason': 'no_goal'},
        'diversification': {'score': null, 'reason': 'no_portfolio'},
        'concentration': {'score': null, 'reason': 'no_portfolio'},
        'volatility': {'score': null, 'reason': 'no_history'},
      },
      'confidence': {
        'pct': 100,
        'level': 'confidence_high',
        'aboutYou': <String>[],
        'aboutOurData': <String>[],
      },
    });

/// Answers each call with a future the test completes by hand, so "which reply
/// arrives first" becomes something the test decides rather than something it
/// hopes for.
class _ScriptedDataSource implements DashboardRemoteDataSource {
  final List<Completer<FitScoreModel>> pending = [];
  final List<int> amountsAsked = [];

  @override
  Future<FitScoreModel> getFitScore(
    String userId, {
    required String symbol,
    required int amountCents,
    String? goalId,
    String language = 'en',
  }) {
    amountsAsked.add(amountCents);
    final c = Completer<FitScoreModel>();
    pending.add(c);
    return c.future;
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used by this test');
}

void main() {
  late _ScriptedDataSource remote;
  late ProviderContainer container;

  setUp(() {
    remote = _ScriptedDataSource();
    container = ProviderContainer(overrides: [
      currentUserIdProvider.overrideWithValue('uid-1'),
      dashboardRemoteDataSourceProvider.overrideWithValue(remote),
    ]);
    addTearDown(container.dispose);
    // Without a listener autoDispose tears the notifier down between reads —
    // which would also reset the sequence counter these tests are about.
    for (final scope in ['buy', 'detail']) {
      container.listen(fitScoreControllerProvider(scope), (_, __) {},
          fireImmediately: true);
    }
  });

  // Lets every queued microtask and timer run, so "the reply landed" is a fact
  // rather than a hope.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  test('una respuesta tardía no pisa a la más nueva', () async {
    final ctrl = container.read(fitScoreControllerProvider('buy').notifier);

    // The user types 10, pauses, then types 1000: two requests in flight.
    unawaited(ctrl.fetch(symbol: 'BTC', amountCents: 1000));
    unawaited(ctrl.fetch(symbol: 'BTC', amountCents: 100000));
    expect(remote.amountsAsked, [1000, 100000]);

    // The newer one answers first, then the slower older one lands.
    remote.pending[1].complete(_fit('BTC', 90));
    await settle();
    remote.pending[0].complete(_fit('BTC', 10));
    await settle();

    // Without the sequence token the card would end up showing the verdict for
    // $10 while the field reads $1000 — and the amount is nowhere on the card,
    // so nothing would look wrong.
    final shown = container.read(fitScoreControllerProvider('buy')).value;
    expect(shown!.score, 90);
  });

  test('cada pantalla tiene su propia instancia', () async {
    final buy = container.read(fitScoreControllerProvider('buy').notifier);
    final detail =
        container.read(fitScoreControllerProvider('detail').notifier);
    expect(identical(buy, detail), isFalse);

    // Asset detail asks about the holding (amount 0); the buy screen then asks
    // about a purchase of the SAME symbol — which is why a guard on the symbol
    // alone cannot tell them apart.
    unawaited(detail.fetch(symbol: 'BTC', amountCents: 0));
    remote.pending[0].complete(_fit('BTC', 25));
    await settle();

    unawaited(buy.fetch(symbol: 'BTC', amountCents: 500000));
    remote.pending[1].complete(_fit('BTC', 80));
    await settle();

    // The detail screen stays mounted under the pushed buy screen. Its verdict
    // must still be the one about the holding.
    expect(container.read(fitScoreControllerProvider('detail')).value!.score, 25);
    expect(container.read(fitScoreControllerProvider('buy')).value!.score, 80);
  });

  test('clear() cancela lo que está en vuelo', () async {
    final ctrl = container.read(fitScoreControllerProvider('buy').notifier);
    unawaited(ctrl.fetch(symbol: 'BTC', amountCents: 1000));
    ctrl.clear();

    remote.pending[0].complete(_fit('BTC', 90));
    await settle();

    // A purchase that was cleared must not repaint a verdict afterwards.
    expect(container.read(fitScoreControllerProvider('buy')).value, isNull);
  });
}
