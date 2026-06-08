import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/dashboard/data/models/goal_response_model.dart';
import 'package:investy/features/dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;
import 'package:investy/features/goals/presentation/goal_detail_screen.dart';
import 'package:investy/l10n/app_localizations.dart';

GoalResponseModel _goal({int cash = 100000, int invested = 85000}) {
  return GoalResponseModel(
    id: 'g1',
    name: 'Peru vacation',
    targetAmountCents: 1000000, // $10,000
    currentAmountCents: cash + invested,
    cashContributedCents: cash,
    investedValueCents: invested,
    deadline: '2027-12-31',
    category: 'travel',
    createdAt:
        DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
  );
}

void main() {
  Widget buildSubject(GoalResponseModel goal) {
    return ProviderScope(
      overrides: [
        displayCurrencyProvider.overrideWithValue('USD'),
        fxRateProvider.overrideWith((ref) async => 1.0),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GoalDetailScreen(goalId: goal.id, goal: goal),
      ),
    );
  }

  testWidgets('renders goal name and combined progress', (tester) async {
    await tester.pumpWidget(buildSubject(_goal()));
    await tester.pumpAndSettle();

    // Title appears (in the gradient app bar).
    expect(find.text('Peru vacation'), findsWidgets);
    // Combined current ($1,850.00) is shown.
    expect(find.text('\$1,850.00'), findsOneWidget);
    // Invested value ($850.00) shown when hasInvestments.
    expect(find.text('\$850.00'), findsOneWidget);
  });

  testWidgets('shows no-investments message when none assigned',
      (tester) async {
    await tester.pumpWidget(buildSubject(_goal(invested: 0)));
    await tester.pumpAndSettle();

    expect(find.text('No investments assigned to this goal yet.'),
        findsOneWidget);
  });
}
