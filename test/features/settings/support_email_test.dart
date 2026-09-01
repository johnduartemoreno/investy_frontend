import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/core/config/app_config.dart';
import 'package:investy/features/settings/presentation/about_screen.dart';
import 'package:investy/features/settings/presentation/help_screen.dart';
import 'package:investy/l10n/app_localizations.dart';

/// H12 / B108. The support mailbox the app publishes must be on a domain we
/// own. `support@investy.app` — the address these two screens used to hardcode,
/// each with its own copy — belongs to someone else, so a user writing to it
/// reached nobody, with no visible error anywhere.
///
/// These tests assert the rendered text, not the constant: reading
/// [AppConfig.supportEmail] back would pass even if a screen went on showing
/// its own literal, which is exactly the failure that happened.
Widget _wrap(Widget screen) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  );
}

void main() {
  group('the published support mailbox is on a domain we own', () {
    testWidgets('Help shows support@investyapp.com and not the foreign domain',
        (tester) async {
      await tester.pumpWidget(_wrap(const HelpScreen()));
      await tester.pumpAndSettle();

      expect(find.text('support@investyapp.com'), findsOneWidget);
      expect(find.text('support@investy.app'), findsNothing);
    });

    testWidgets('About shows support@investyapp.com and not the foreign domain',
        (tester) async {
      await tester.pumpWidget(_wrap(const AboutScreen()));
      await tester.pumpAndSettle();

      expect(find.text('support@investyapp.com'), findsOneWidget);
      expect(find.text('support@investy.app'), findsNothing);
    });
  });

  test('the constant itself is on our domain', () {
    // Guards the other direction: a future edit that points the single source
    // at another foreign domain would keep both screens consistent and still
    // be wrong.
    expect(AppConfig.supportEmail, endsWith('@investyapp.com'));
  });
}
