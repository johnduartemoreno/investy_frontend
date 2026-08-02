import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';

part 'locale_provider.g.dart';

const _kLangKey = 'preferred_language';
const _supportedLocales = ['en', 'es', 'pt'];

// Loaded once in main() before runApp so build() can read synchronously.
SharedPreferences? _prefs;

Future<void> initLocaleProvider() async {
  _prefs = await SharedPreferences.getInstance();
}

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    final stored = _prefs?.getString(_kLangKey);
    if (stored != null && _supportedLocales.contains(stored)) {
      return Locale(stored);
    }
    return const Locale('en');
  }

  Future<void> setLanguage(String languageCode) async {
    if (!_supportedLocales.contains(languageCode)) return;
    state = Locale(languageCode);

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, languageCode);

    _syncToBackend(languageCode);
  }

  /// Pushes the language the app is actually running in to the backend.
  ///
  /// Called on sign-in, because the language lives in this device's
  /// SharedPreferences while the backend row is created by UpsertFromFirebase
  /// with a default of "en". Without this, a user reading the app in Spanish
  /// stayed "en" server-side forever, and every push notification — which is
  /// rendered server-side from users.preferred_language — arrived in English
  /// (B60 UAT). Syncing only inside setLanguage covered the user who changes
  /// the language, never the user who simply signs in.
  ///
  /// The device wins on purpose: it is the language the user is reading right
  /// now. Two devices in different languages will overwrite each other.
  void syncCurrentLanguage() => _syncToBackend(state.languageCode);

  void _syncToBackend(String languageCode) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final dio = ref.read(dioProvider);
      await dio.put(
        '/api/v1/users/$uid/language',
        data: {'language': languageCode},
        options: Options(sendTimeout: const Duration(seconds: 5)),
      );
    } catch (e) {
      // Not fatal — the language is already persisted locally. Logged because a
      // silent failure here is invisible until a notification shows up in the
      // wrong language, which is exactly what made B60 hard to see.
      debugPrint('[locale] failed to sync language to backend: $e');
    }
  }
}
