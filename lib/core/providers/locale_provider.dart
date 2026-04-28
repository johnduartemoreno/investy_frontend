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
    } catch (_) {
      // Network failure is acceptable — language is already persisted locally.
    }
  }
}
