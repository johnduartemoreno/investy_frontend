import 'package:flutter_test/flutter_test.dart';
import 'package:investy/features/dashboard/data/models/activity_item_model.dart';

void main() {
  group('ActivityItemModel — a receipt must not understate what was charged',
      () {
    // The exact payload of the B41 UAT purchase: 0.001 BTC @ $64,540.06.
    // Notional 6454c, commission 17c (16.135 ceil'd), wallet debited 6471c.
    final buyJson = {
      'id': '88ad0a78-8fb8-4fb8-a1d4-3cb34f10b258',
      'amount': 6471,
      'totalBeforeFeesCents': 6454,
      'feeCents': 17,
      'type': 'BUY',
      'timestamp': '2026-07-15T03:46:46Z',
      'symbol': 'BTC',
      'quantityUnits': 100000,
      'priceCents': 6454006,
    };

    test('the receipt total is what MOVED, not the notional', () {
      final tx = ActivityItemModel.fromJson(buyJson).toTransaction();

      // The bug: this showed 64.54 — the notional — hiding the commission.
      expect(tx.total, 64.71);
      expect(tx.totalBeforeFees, 64.54);
      expect(tx.feeCents, 17);
      // Total must equal subtotal + commission, or the receipt does not add up.
      expect(
          tx.total, closeTo(tx.totalBeforeFees + tx.feeCents / 100.0, 0.001));
    });

    test('0.001 BTC survives the round-trip at full precision', () {
      final tx = ActivityItemModel.fromJson(buyJson).toTransaction();
      expect(tx.quantity, 0.001);
      expect(tx.price, 64540.06);
    });

    test('a pre-B41 receipt (no fee, no breakdown) still reads correctly', () {
      // Old rows carry neither totalBeforeFeesCents nor feeCents. They genuinely
      // paid no commission, so the moved amount IS the notional — it must not
      // collapse to zero.
      final tx = ActivityItemModel.fromJson({
        'id': 'old',
        'amount': 63468,
        'type': 'BUY',
        'timestamp': '2026-07-13T22:44:35Z',
        'symbol': 'AAPL',
        'quantityUnits': 200000000,
        'priceCents': 31734,
      }).toTransaction();

      expect(tx.feeCents, 0);
      expect(tx.totalBeforeFees, 634.68);
      expect(tx.total, 634.68);
    });

    test('a sell credits the notional MINUS the fee', () {
      final tx = ActivityItemModel.fromJson({
        'id': 'sell-1',
        'amount': 4987,
        'totalBeforeFeesCents': 5000,
        'feeCents': 13,
        'type': 'SELL',
        'timestamp': '2026-07-14T10:00:00Z',
        'symbol': 'TSLA',
        'quantityUnits': 100000000,
        'priceCents': 5000,
      }).toTransaction();

      expect(tx.totalBeforeFees, 50.00);
      // What lands in the wallet is less than the gross — the whole point.
      expect(tx.total, 49.87);
    });
  });
}
