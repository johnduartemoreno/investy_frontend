import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/dashboard/data/models/fit_score_model.dart';
import 'package:investy/features/dashboard/presentation/widgets/fit_score_card.dart';
import 'package:investy/l10n/app_localizations.dart';

Map<String, dynamic> _component(int? score, String reason,
        {String caveat = ''}) =>
    {'score': score, 'reason': reason, if (caveat.isNotEmpty) 'caveat': caveat};

FitScoreModel _fit({
  int? score = 82,
  bool showScore = true,
  String cappedBy = '',
  String explanation = '',
  String goalName = '',
  double? volatilityPct,
  Map<String, dynamic>? volatility,
  int confidencePct = 100,
  List<String> aboutYou = const [],
  List<String> aboutOurData = const [],
  Map<String, dynamic>? profile,
  Map<String, dynamic>? diversification,
  Map<String, dynamic>? concentration,
}) {
  return FitScoreModel.fromJson({
    'symbol': 'AAPL',
    'assetName': 'Apple Inc.',
    'assetClass': 'stock',
    'goalName': goalName,
    'score': score,
    'showScore': showScore,
    'cappedBy': cappedBy,
    'explanation': explanation,
    'volatilityPct': volatilityPct,
    'components': {
      'profile': profile ?? _component(90, 'class_core'),
      'horizon': _component(80, 'horizon_comfortable'),
      'diversification': diversification ?? _component(75, 'fills_gap'),
      'concentration': concentration ?? _component(85, 'concentration_low'),
      'volatility': volatility ?? _component(70, 'vol_typical'),
    },
    'confidence': {
      'pct': confidencePct,
      'level': confidencePct >= 75
          ? 'confidence_high'
          : confidencePct >= 45
              ? 'confidence_medium'
              : 'confidence_low',
      'aboutYou': aboutYou,
      'aboutOurData': aboutOurData,
    },
  });
}

Widget _subject(FitScoreModel fit, {String lang = 'es'}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(lang),
      home: Scaffold(body: SingleChildScrollView(child: FitScoreCard(fit: fit))),
    );

void main() {
  // The gap this pair of widgets closes, found in UAT on 2026-08-13: changing
  // the goal re-fetches, and the card used to render only on `data` — so it
  // vanished for the length of the round trip and came back. Nothing was
  // broken, but a block of the screen disappearing under your finger reads as a
  // bug, and a user who thinks the screen broke stops trusting the number when
  // it returns.
  testWidgets('el estado de carga mantiene el marco, sin veredicto viejo',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: Scaffold(body: FitScoreCardLoading()),
    ));

    expect(find.text('Qué tan bien encaja con vos'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Ningún veredicto: el anterior se calculó para otra meta.
    expect(find.text('Ver por qué'), findsNothing);
    expect(find.text('Buen encaje'), findsNothing);
  });

  testWidgets('si falla lo dice en una línea, no deja un hueco',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: Scaffold(body: FitScoreCardUnavailable()),
    ));

    expect(find.text('No pudimos evaluar esta compra ahora.'), findsOneWidget);
  });

  // The hybrid presentation decided on 2026-08-11: colour and sentences in
  // front, the number behind "ver por qué". If the score leaked to the front of
  // the card, the screen would be making the stronger claim the decision was
  // taken to avoid.
  testWidgets('el número no se muestra hasta abrir "ver por qué"',
      (tester) async {
    await tester.pumpWidget(_subject(_fit(score: 82)));

    expect(find.text('82 de 100'), findsNothing);
    expect(find.text('Buen encaje'), findsOneWidget);
    expect(find.text('Ver por qué'), findsOneWidget);

    await tester.tap(find.text('Ver por qué'));
    await tester.pumpAndSettle();

    expect(find.text('82 de 100'), findsOneWidget);
    expect(find.text('Confianza: 100%'), findsOneWidget);
  });

  // A component with no data must read "sin medir", never 0. A zero says the
  // fit is bad; the two are different statements and this is the last place the
  // distinction can be lost before it reaches a person.
  testWidgets('un componente sin datos dice "sin medir", no 0', (tester) async {
    await tester.pumpWidget(_subject(_fit(
      volatility: _component(null, 'no_history'),
      confidencePct: 80,
      aboutOurData: const ['no_history'],
    )));

    await tester.tap(find.text('Ver por qué'));
    await tester.pumpAndSettle();

    expect(find.text('Sin medir'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(
        find.text('Todavía no tenemos suficiente historial de precios para medir esto.'),
        findsWidgets);
  });

  // Below the confidence threshold the backend withholds the number entirely.
  // The card must then ask for what is missing instead of showing a hedged
  // score — and must not phrase our own data gap as the user's homework.
  testWidgets('con confianza baja muestra qué falta y ningún puntaje',
      (tester) async {
    await tester.pumpWidget(_subject(_fit(
      score: null,
      showScore: false,
      confidencePct: 40,
      aboutYou: const ['no_profile', 'no_goal'],
      aboutOurData: const ['no_history'],
    )));

    expect(find.text('Todavía no podemos evaluar esto'), findsOneWidget);
    expect(find.text('Ver por qué'), findsNothing);
    expect(find.text('Qué ayudaría'), findsOneWidget);
    expect(find.text('Todavía no respondiste el cuestionario de riesgo.'),
        findsOneWidget);
    // Our gap is under its own heading, apart from the user's.
    expect(find.text('De nuestro lado'), findsOneWidget);
  });

  // The prudence floor is only useful if the user is told it applied —
  // otherwise the number contradicts the breakdown they are looking at.
  testWidgets('dice cuándo el piso de prudencia bajó el puntaje',
      (tester) async {
    await tester.pumpWidget(_subject(_fit(score: 25, cappedBy: 'concentration')));

    expect(
        find.textContaining('aplica sea cual sea tu perfil de riesgo'),
        findsOneWidget);
  });

  // The owl's prose is an enhancement. When it is absent — model down, or
  // rejected by the number guard — the card still has to say something true.
  testWidgets('sin prosa del búho el card sigue explicando', (tester) async {
    await tester.pumpWidget(_subject(_fit(explanation: '')));

    expect(find.text('Es el tipo de activo en el que más se apoya tu perfil.'),
        findsOneWidget);
  });

  testWidgets('con prosa del búho la muestra al frente', (tester) async {
    const prose = 'Esta compra encaja con tu perfil y con el plazo de tu meta.';
    await tester.pumpWidget(_subject(_fit(explanation: prose)));

    expect(find.text(prose), findsOneWidget);
  });

  // Present on both branches, and — the part the original test got wrong —
  // visible WITHOUT expanding. The disclaimer used to live inside the breakdown,
  // so the one case where it matters (a verdict about a purchase, right above
  // the buy button) was the only case where it was hidden. The old test tapped
  // "Ver por qué" before asserting, so it promised more than it checked.
  // Found by the S19 audit, 2026-08-12.
  testWidgets('el descargo legal se ve sin abrir "ver por qué"',
      (tester) async {
    // Neutral on purpose: the same card renders on the buy screen and on asset
    // detail, where there is no purchase at all — it is the position you already
    // hold. Calling that "una compra" was the last text on the card still doing
    // it, after the owl's prose had been fixed (UAT, 2026-08-27).
    const disclaimer =
        'Esto describe cómo se relaciona con lo que nos contaste. No es asesoramiento financiero.';

    // Con puntaje, vista por defecto: sin tocar nada.
    await tester.pumpWidget(_subject(_fit()));
    expect(find.text(disclaimer), findsOneWidget);

    // Y al abrir el desglose sigue habiendo exactamente uno, no dos.
    await tester.tap(find.text('Ver por qué'));
    await tester.pumpAndSettle();
    expect(find.text(disclaimer), findsOneWidget);

    // Sin puntaje también.
    await tester.pumpWidget(_subject(_fit(
        score: null,
        showScore: false,
        confidencePct: 30,
        aboutYou: const ['no_profile'])));
    expect(find.text(disclaimer), findsOneWidget);
  });

  // A reason key the app does not know yet renders as nothing — but an empty
  // Text still takes its padding, which is a visible gap where a sentence
  // should have been.
  testWidgets('una reason key desconocida no deja un hueco', (tester) async {
    await tester.pumpWidget(_subject(FitScoreModel.fromJson({
      'symbol': 'AAPL',
      'assetName': 'Apple Inc.',
      'assetClass': 'stock',
      'score': 70,
      'showScore': true,
      'components': {
        'profile': _component(70, 'reason_del_futuro'),
        'horizon': _component(70, 'reason_del_futuro'),
        'diversification': _component(70, 'reason_del_futuro'),
        'concentration': _component(70, 'reason_del_futuro'),
        'volatility': _component(70, 'reason_del_futuro'),
      },
      'confidence': {
        'pct': 100,
        'level': 'confidence_high',
        'aboutYou': const [],
        'aboutOurData': const [],
      },
    })));

    // Ni la key cruda en pantalla, ni un LeftAccentBox vacío ocupando lugar.
    expect(find.text('reason_del_futuro'), findsNothing);
    expect(find.text(''), findsNothing);
  });

  // The observed figure means more than its score: "moved 45% a year, we expect
  // about 28% from a stock" is a better sentence than a bare number.
  testWidgets('muestra la volatilidad observada junto a su componente',
      (tester) async {
    await tester.pumpWidget(_subject(_fit(volatilityPct: 38.4)));

    await tester.tap(find.text('Ver por qué'));
    await tester.pumpAndSettle();

    expect(find.text('Se movió 38% al año'), findsOneWidget);
  });

  // Today every measured asset carries the short-window caveat, so if this
  // stopped rendering the whole honesty mechanism would go quiet at once.
  testWidgets('muestra la salvedad que declara el componente', (tester) async {
    await tester.pumpWidget(_subject(_fit(
      volatility: _component(70, 'vol_typical', caveat: 'short_window'),
    )));

    await tester.tap(find.text('Ver por qué'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ventana corta'), findsOneWidget);
  });

  // Both defects below were found in the S19 UAT on 2026-08-25, one after the
  // other: the second only came to light because the first had already been
  // fixed. A reason key that more than one component can emit needs one sentence
  // per component, and there are two such keys. These tests exist so the next
  // shared key is not shipped sharing a sentence.
  group('una clave de razón compartida no puede compartir la oración', () {
    Future<List<String>> reasonsOf(WidgetTester tester, FitScoreModel fit,
        List<String> labels) async {
      await tester.pumpWidget(_subject(fit));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Ver por qué'));
      await tester.pumpAndSettle();

      // Row order in _componentRow is label, then score (or "sin medir"), then
      // the sentence — so the reason is two Texts after the label, not one.
      final texts = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data ?? '')
          .toList();
      return labels.map((label) {
        final i = texts.indexWhere((t) => t.contains(label));
        expect(i, isNot(-1), reason: 'no se encontró la fila "$label"');
        return texts[i + 2];
      }).toList();
    }

    testWidgets('class_not_in_plan: perfil y mezcla lo dicen distinto',
        (tester) async {
      final fit = _fit(
        profile: _component(0, 'class_not_in_plan'),
        diversification: _component(0, 'class_not_in_plan'),
      );
      final r = await reasonsOf(tester, fit, ['Encaja con tu perfil', 'Efecto en tu mezcla']);

      expect(r[0], isNotEmpty);
      expect(r[1], isNotEmpty);
      expect(r[0], isNot(equals(r[1])),
          reason: 'las dos filas mostraban la misma oración (UAT 2026-08-25)');
      // The mix row must answer the mix question, not repeat the profile one.
      expect(r[1].toLowerCase(), contains('mezcla'));
    });

    testWidgets('no_portfolio: mezcla y peso lo dicen distinto', (tester) async {
      final fit = _fit(
        diversification: _component(null, 'no_portfolio'),
        concentration: _component(null, 'no_portfolio'),
      );
      final r = await reasonsOf(tester, fit, ['Efecto en tu mezcla', 'Peso en tu cartera']);

      expect(r[0], isNot(equals(r[1])),
          reason: 'las dos filas mostraban la misma oración (UAT 2026-08-25)');
      // "no mix to compare against" under "weight in your portfolio" is not just
      // repetitive, it is wrong: concentration does not measure the mix.
      expect(r[1].toLowerCase(), isNot(contains('mezcla')));
    });
  });

  // The physical-device pass is what would normally catch a translation that
  // overflows its row, and it is the pass this sprint has not had. These run the
  // card in all three languages at a narrow width so a long string fails here
  // instead of on someone's phone.
  group('el card se dibuja entero en los tres idiomas', () {
    for (final lang in ['es', 'en', 'pt']) {
      testWidgets('$lang: sin desbordes con el desglose abierto',
          (tester) async {
        tester.view.physicalSize = const Size(320 * 3, 900 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        final fit = _fit(
          cappedBy: 'class_not_in_plan',
          profile: _component(0, 'class_not_in_plan'),
          diversification: _component(0, 'class_not_in_plan'),
          concentration: _component(null, 'no_portfolio'),
          volatilityPct: 41.2,
          volatility: _component(100, 'vol_calm', caveat: 'short_window'),
          aboutOurData: const ['no_history'],
        );

        await tester.pumpWidget(_subject(fit, lang: lang));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'desborde de layout en "$lang" con el desglose abierto');
      });
    }
  });
}
