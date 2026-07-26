import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investy/core/config/app_config.dart';
import 'package:investy/core/presentation/widgets/environment_badge.dart';

void main() {
  // `flutter test` runs in debug mode with no --dart-define, so the resolved
  // environment is local and the badge is shown.
  group('AppConfig environment', () {
    test('a debug build with no staging flag resolves to local', () {
      expect(AppConfig.environment, AppEnvironment.local);
      expect(AppConfig.showBuildBadge, isTrue);
    });
  });

  group('EnvironmentBadge', () {
    testWidgets('renders the LOCAL label in a local build', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EnvironmentBadge())),
      );
      // No GIT_SHA is injected in tests, so only the environment label shows.
      expect(find.text('LOCAL'), findsOneWidget);
    });

    testWidgets('overlay pins the badge without blocking taps', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnvironmentBadgeOverlay(
              child: Center(
                child: GestureDetector(
                  onTap: () => tapped = true,
                  child: const Text('body'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('LOCAL'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      // The badge is IgnorePointer, so taps still reach the body underneath.
      await tester.tap(find.text('body'));
      expect(tapped, isTrue);
    });
  });
}
