import 'package:flutter_test/flutter_test.dart';
import 'package:investy/features/dashboard/data/models/goal_response_model.dart';

GoalResponseModel _goal({
  int target = 1000000, // $10,000
  int current = 0,
  int cash = 0,
  int invested = 0,
  String? createdAt,
}) {
  return GoalResponseModel(
    id: 'g1',
    name: 'Peru vacation',
    targetAmountCents: target,
    currentAmountCents: current,
    cashContributedCents: cash,
    investedValueCents: invested,
    deadline: '2027-12-31',
    category: 'travel',
    createdAt: createdAt ?? DateTime.now().toIso8601String(),
  );
}

void main() {
  group('GoalResponseModel — S18 progress', () {
    test('progress is combined currentAmount over target, clamped', () {
      final g = _goal(target: 1000000, current: 500000);
      expect(g.progress, 0.5);
    });

    test('progress clamps to 1.0 when over target', () {
      final g = _goal(target: 1000000, current: 1500000);
      expect(g.progress, 1.0);
    });

    test('hasInvestments reflects investedValueCents', () {
      expect(_goal(invested: 0).hasInvestments, isFalse);
      expect(_goal(invested: 1).hasInvestments, isTrue);
    });

    test('cash and invested convert cents to dollars', () {
      final g = _goal(cash: 100000, invested: 85000);
      expect(g.cashContributed, 1000.0);
      expect(g.investedValue, 850.0);
    });
  });

  group('GoalResponseModel — projectedCompletionDate', () {
    test('null when no progress yet', () {
      expect(_goal(current: 0).projectedCompletionDate, isNull);
    });

    test('null when already reached', () {
      expect(
          _goal(target: 1000, current: 1000).projectedCompletionDate, isNull);
    });

    test('null when created less than a day ago (rate not meaningful)', () {
      final g =
          _goal(current: 500000, createdAt: DateTime.now().toIso8601String());
      expect(g.projectedCompletionDate, isNull);
    });

    test('null when projection exceeds ~100 years (tiny rate vs huge target)',
        () {
      // €160 saved over 100 days toward a €10M target → projection ~ year 12000.
      final created = DateTime.now().subtract(const Duration(days: 100));
      final g = _goal(
        target: 1040000000, // €10.4M
        current: 16031, // €160.31
        createdAt: created.toIso8601String(),
      );
      expect(g.projectedCompletionDate, isNull);
    });

    test('projects a future date at the current saving rate', () {
      // Created 100 days ago, saved half → ~100 more days to finish.
      final created = DateTime.now().subtract(const Duration(days: 100));
      final g = _goal(
        target: 1000000,
        current: 500000,
        createdAt: created.toIso8601String(),
      );
      final projection = g.projectedCompletionDate;
      expect(projection, isNotNull);
      expect(projection!.isAfter(DateTime.now()), isTrue);
    });
  });
}
