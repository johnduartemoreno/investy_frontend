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
      'profile': _component(90, 'class_core'),
      'horizon': _component(80, 'horizon_comfortable'),
      'diversification': _component(75, 'fills_gap'),
      'concentration': _component(85, 'concentration_low'),
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

Widget _subject(FitScoreModel fit) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(body: SingleChildScrollView(child: FitScoreCard(fit: fit))),
    );

void main() {
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

  // Present on both branches of the card: the framing this sprint settled on is
  // that Investy describes a relationship, never what to do about it.
  testWidgets('el descargo legal aparece con y sin puntaje', (tester) async {
    const disclaimer =
        'Esto describe cómo se relaciona una compra con lo que nos contaste. No es asesoramiento financiero.';

    await tester.pumpWidget(_subject(_fit(score: null, showScore: false,
        confidencePct: 30, aboutYou: const ['no_profile'])));
    expect(find.text(disclaimer), findsOneWidget);

    await tester.pumpWidget(_subject(_fit()));
    await tester.tap(find.text('Ver por qué'));
    await tester.pumpAndSettle();
    expect(find.text(disclaimer), findsOneWidget);
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
}
