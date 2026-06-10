import 'package:flutter_test/flutter_test.dart';
import 'package:investy/features/dashboard/data/models/owl_session_model.dart';

void main() {
  const json = {
    'id': 'sess-1',
    'language': 'es',
    'createdAt': '2026-06-09T14:30:00Z',
    'recommendations': [
      {
        'ticker': 'VTI',
        'name': 'Vanguard Total Stock Market',
        'reason': 'Diversificación amplia.',
        'suggestedAmountCents': 50000,
        'strong': true,
      },
      {
        'ticker': 'BTC',
        'name': 'Bitcoin',
        'reason': 'Exposición moderada.',
        'suggestedAmountCents': 25000,
        'strong': false,
      },
    ],
    'contextSnapshot': {
      'portfolioValueCents': 1200000,
      'cashBalanceCents': 350000,
      'riskProfile': 'moderate',
      'holdingsCount': 4,
    },
  };

  group('OwlSessionModel', () {
    test('fromJson parses session with nested recommendations and snapshot',
        () {
      final session = OwlSessionModel.fromJson(json);

      expect(session.id, 'sess-1');
      expect(session.language, 'es');
      expect(session.createdAt, DateTime.parse('2026-06-09T14:30:00Z'));
      expect(session.recommendations, hasLength(2));
      expect(session.recommendations.first.ticker, 'VTI');
      expect(session.recommendations.first.strong, isTrue);
      expect(session.contextSnapshot.riskProfile, 'moderate');
      expect(session.contextSnapshot.holdingsCount, 4);
    });

    test('snapshot cents convert to double dollars for display', () {
      final session = OwlSessionModel.fromJson(json);

      // 1200000 cents = $12,000.00 — integer-cents precision pipeline (ADR-01)
      expect(session.contextSnapshot.portfolioValue, 12000.0);
      expect(session.contextSnapshot.cashBalance, 3500.0);
    });

    test('tickers getter projects recommendation symbols in order', () {
      final session = OwlSessionModel.fromJson(json);

      expect(session.tickers, ['VTI', 'BTC']);
    });
  });
}
