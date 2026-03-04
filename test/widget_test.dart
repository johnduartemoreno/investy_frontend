import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:investy/main.dart';

void main() {
  testWidgets('Investy app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: InvestyApp()));
    await tester.pumpAndSettle();

    // Verify the app renders without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
