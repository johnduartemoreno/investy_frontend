import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:investy/features/alerts/presentation/screens/price_alerts_screen.dart';
import 'package:investy/l10n/app_localizations.dart';

/// B122 — the numeric keyboard could not be dismissed anywhere in the app.
///
/// On iOS `TextInputType.numberWithOptions(decimal: true)` renders a keypad with
/// no return key, so the keyboard itself offers no way out. None of the six money
/// screens declared `onTapOutside`, and their scroll views were left on the
/// default `manual` dismiss behaviour — so the bottom ~45% of the screen stayed
/// covered, permanently, on the screens where money is spent.
///
/// Two tests: the first proves the behaviour on one screen, the second guards the
/// whole family — the bug was never one screen forgetting, it was all six.
void main() {
  group('B122 — keyboard dismissal', () {
    testWidgets('tapping outside a money field drops focus', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [alertsProvider.overrideWith((ref) async => [])],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PriceAlertsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the create sheet, which holds the target-price field.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final priceField = find.byType(EditableText).last;
      await tester.tap(priceField);
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(priceField).focusNode.hasFocus, isTrue,
          reason: 'the field should be focused after tapping it');

      // Tap just above the field, on its own label: outside the field but well
      // inside the sheet. Tapping the top-left corner instead would land on the
      // modal barrier and close the sheet, which proves nothing about focus.
      final rect = tester.getRect(priceField);
      await tester.tapAt(Offset(rect.center.dx, rect.top - 30));
      await tester.pumpAndSettle();

      expect(tester.widget<EditableText>(priceField).focusNode.hasFocus, isFalse,
          reason: 'B122: tapping outside must dismiss the keyboard');
    });

    /// Source-level guard. The behavioural test above covers one screen; this one
    /// covers the family, because B122 was six screens missing the same thing and
    /// the seventh screen someone adds would miss it too.
    test('every money screen declares onTapOutside on its text fields', () {
      const screens = [
        'lib/features/dashboard/presentation/screens/buy_asset_screen.dart',
        'lib/features/dashboard/presentation/screens/sell_asset_screen.dart',
        'lib/features/transactions/presentation/screens/top_up_screen.dart',
        'lib/features/dashboard/presentation/widgets/withdraw_bottom_sheet.dart',
        'lib/features/goals/presentation/widgets/create_goal_sheet.dart',
        'lib/features/alerts/presentation/screens/price_alerts_screen.dart',
      ];

      final offenders = <String>[];
      for (final path in screens) {
        final lines = File(path).readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final opensField = lines[i].trimRight().endsWith('TextFormField(');
          final opensScroll =
              lines[i].trimRight().endsWith('SingleChildScrollView(');
          if (!opensField && !opensScroll) continue;

          final next = i + 1 < lines.length ? lines[i + 1] : '';
          final expected =
              opensField ? 'onTapOutside:' : 'keyboardDismissBehavior:';
          if (!next.contains(expected)) {
            offenders.add('$path:${i + 1} — missing $expected');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'B122: a money screen lost its keyboard escape hatch');
    });
  });
}
