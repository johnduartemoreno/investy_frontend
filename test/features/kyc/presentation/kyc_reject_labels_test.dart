import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/kyc/presentation/kyc_reject_labels.dart';
import 'package:investy/l10n/app_localizations.dart';

/// Resolves a real AppLocalizations for [locale] so the assertions run against
/// the shipped .arb copy rather than a stand-in.
Future<AppLocalizations> _l10n(WidgetTester tester, Locale locale) async {
  late AppLocalizations captured;
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (context) {
      captured = AppLocalizations.of(context);
      return const SizedBox.shrink();
    }),
  ));
  await tester.pump();
  return captured;
}

void main() {
  testWidgets('known labels become actionable copy', (tester) async {
    final l10n = await _l10n(tester, const Locale('es'));

    final out = KycRejectLabels.describe(['UNSATISFACTORY_PHOTOS'], l10n);

    expect(out, [l10n.kycRejectLabelBadPhoto]);
    // The Sumsub code itself must never reach the user.
    expect(out.first.contains('UNSATISFACTORY'), isFalse);
  });

  testWidgets('labels are matched case-insensitively', (tester) async {
    final l10n = await _l10n(tester, const Locale('en'));

    expect(
      KycRejectLabels.describe(['screenshots'], l10n),
      [l10n.kycRejectLabelScreenshot],
    );
  });

  // Several Sumsub codes map to the same advice; repeating that advice would
  // read as a broken list.
  testWidgets('duplicate advice is collapsed', (tester) async {
    final l10n = await _l10n(tester, const Locale('en'));

    final out = KycRejectLabels.describe(
        ['UNSATISFACTORY_PHOTOS', 'BAD_PHOTO_QUALITY', 'LOW_QUALITY'], l10n);

    expect(out, hasLength(1));
  });

  // The label set belongs to Sumsub and grows without notice. An unknown code
  // must still tell the user something, and must not surface as a raw code.
  testWidgets('an unknown label falls back to generic copy', (tester) async {
    final l10n = await _l10n(tester, const Locale('en'));

    final out = KycRejectLabels.describe(['SOME_NEW_SUMSUB_CODE'], l10n);

    expect(out, [l10n.kycRejectLabelGeneric]);
  });

  // When something specific IS known, the generic line adds nothing and would
  // dilute the advice that matters.
  testWidgets('generic copy is omitted when a specific reason exists',
      (tester) async {
    final l10n = await _l10n(tester, const Locale('en'));

    final out = KycRejectLabels.describe(
        ['SOME_NEW_SUMSUB_CODE', 'EXPIRATION_DATE'], l10n);

    expect(out, [l10n.kycRejectLabelExpired]);
  });

  // No labels at all is a real case (a rejection Sumsub did not itemize). The
  // caller uses the empty list to drop the whole section.
  testWidgets('no labels yields no lines', (tester) async {
    final l10n = await _l10n(tester, const Locale('en'));

    expect(KycRejectLabels.describe(const [], l10n), isEmpty);
  });

  testWidgets('copy is translated per locale', (tester) async {
    final es = await _l10n(tester, const Locale('es'));
    final esOut = KycRejectLabels.describe(['EXPIRATION_DATE'], es);

    final pt = await _l10n(tester, const Locale('pt'));
    final ptOut = KycRejectLabels.describe(['EXPIRATION_DATE'], pt);

    expect(esOut.first, isNot(equals(ptOut.first)));
  });
}
