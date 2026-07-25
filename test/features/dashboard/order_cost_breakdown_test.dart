import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investy/features/dashboard/data/models/trading_quote_model.dart';
import 'package:investy/features/dashboard/presentation/widgets/order_cost_breakdown.dart';
import 'package:investy/l10n/app_localizations.dart';

Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  // The exact numbers the engine produces for 1 AMZN @ $100: 0.25% = 25c.
  const buyQuote = TradingQuoteModel(
    totalBeforeFeesCents: 10000,
    feeCents: 25,
    totalCents: 10025,
    components: [
      TradingQuoteComponent(chargeType: 'investy_commission', feeCents: 25),
    ],
  );

  // 1 TSLA @ $50: fee 12.5c -> 13c, and the seller NETS 4987 — fee subtracted.
  const sellQuote = TradingQuoteModel(
    totalBeforeFeesCents: 5000,
    feeCents: 13,
    totalCents: 4987,
    components: [
      TradingQuoteComponent(chargeType: 'investy_commission', feeCents: 13),
    ],
  );

  testWidgets('a buy shows subtotal, the commission and what you pay',
      (tester) async {
    await tester.pumpWidget(wrap(
      const OrderCostBreakdown(quote: buyQuote, isBuy: true),
    ));

    expect(find.text('\$100.00'), findsOneWidget); // subtotal
    expect(find.text('\$0.25'),
        findsOneWidget); // commission — visible, not hidden
    expect(find.text('\$100.25'), findsOneWidget); // total to pay
    expect(find.text('Total to pay'), findsOneWidget);
  });

  testWidgets('a sell says "You receive" and shows the fee taken out',
      (tester) async {
    await tester.pumpWidget(wrap(
      const OrderCostBreakdown(quote: sellQuote, isBuy: false),
    ));

    expect(find.text('\$50.00'), findsOneWidget); // gross
    expect(find.text('\$0.13'), findsOneWidget); // fee
    // The point of the whole exercise: proceeds are NET, not gross.
    expect(find.text('\$49.87'), findsOneWidget);
    expect(find.text('You receive'), findsOneWidget);
    expect(find.text('Total to pay'), findsNothing);
  });

  testWidgets('every charge is itemized, not merged into one number',
      (tester) async {
    // The S16 shape: our commission plus the regulatory pass-throughs.
    const multi = TradingQuoteModel(
      totalBeforeFeesCents: 100000,
      feeCents: 271,
      totalCents: 99729,
      components: [
        TradingQuoteComponent(chargeType: 'investy_commission', feeCents: 250),
        TradingQuoteComponent(chargeType: 'sec_31', feeCents: 21),
        TradingQuoteComponent(chargeType: 'finra_taf', feeCents: 2),
      ],
    );

    await tester.pumpWidget(wrap(
      const OrderCostBreakdown(quote: multi, isBuy: false),
    ));

    expect(find.text('Investy commission'), findsOneWidget);
    expect(find.text('SEC fee'), findsOneWidget);
    expect(find.text('FINRA activity fee'), findsOneWidget);
  });

  testWidgets('an unknown charge type is still shown, never silently dropped',
      (tester) async {
    const unknown = TradingQuoteModel(
      totalBeforeFeesCents: 10000,
      feeCents: 5,
      totalCents: 10005,
      components: [
        TradingQuoteComponent(chargeType: 'some_future_levy', feeCents: 5),
      ],
    );

    await tester.pumpWidget(wrap(
      const OrderCostBreakdown(quote: unknown, isBuy: true),
    ));

    // A fee the client has no label for must still appear — hiding it would
    // understate the cost.
    expect(find.text('some_future_levy'), findsOneWidget);
    expect(find.text('\$0.05'), findsOneWidget);
  });

  testWidgets('labels are localized', (tester) async {
    await tester.pumpWidget(wrap(
      const OrderCostBreakdown(quote: sellQuote, isBuy: false),
      locale: const Locale('es'),
    ));

    expect(find.text('Comisión Investy'), findsOneWidget);
    expect(find.text('Recibís'), findsOneWidget);
  });
}
