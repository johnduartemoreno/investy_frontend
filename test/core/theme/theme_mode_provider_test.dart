import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investy/core/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads the persisted theme on build (F6 — no reset to system)', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    await initThemeModeProvider();

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
  });

  test('defaults to system when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    await initThemeModeProvider();

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.system);
  });

  test('setMode persists the choice', () async {
    SharedPreferences.setMockInitialValues({});
    await initThemeModeProvider();

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(themeModeNotifierProvider.notifier)
        .setMode(ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
    expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
  });
}
