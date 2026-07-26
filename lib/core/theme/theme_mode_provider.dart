import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_mode_provider.g.dart';

const _kThemeModeKey = 'theme_mode';

// Loaded once in main() before runApp so build() can read synchronously — the
// same pattern as the locale provider, so the chosen theme is applied on the
// first frame with no light→dark flash.
SharedPreferences? _prefs;

Future<void> initThemeModeProvider() async {
  _prefs = await SharedPreferences.getInstance();
}

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // Previously this always returned ThemeMode.system, so a Dark choice was lost
    // on the next launch/login and the app fell back to the device theme (F6).
    return switch (_prefs?.getString(_kThemeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }
}
