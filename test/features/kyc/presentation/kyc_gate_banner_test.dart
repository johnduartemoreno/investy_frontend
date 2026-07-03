import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/kyc/data/models/kyc_status_model.dart';
import 'package:investy/features/kyc/presentation/providers/kyc_provider.dart';
import 'package:investy/features/kyc/presentation/widgets/kyc_gate_banner.dart';
import 'package:investy/l10n/app_localizations.dart';

Widget _wrap(Widget child, Override override) {
  return ProviderScope(
    overrides: [override],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('KycGateBanner is invisible when KYC is approved',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const KycGateBanner(),
      kycStatusProvider.overrideWith(
        (_) async => const KycStatusModel(status: 'approved'),
      ),
    ));
    await tester.pump();
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('KycGateBanner shows required banner when not_started',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const KycGateBanner(),
      kycStatusProvider.overrideWith(
        (_) async => const KycStatusModel(status: 'not_started'),
      ),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('KycGateBanner shows pending banner when submitted',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const KycGateBanner(),
      kycStatusProvider.overrideWith(
        (_) async => const KycStatusModel(status: 'submitted'),
      ),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
  });
}
