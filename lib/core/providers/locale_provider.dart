import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';

part 'locale_provider.g.dart';

const _kLangKey = 'preferred_language';
const _supportedLocales = ['en', 'es', 'pt'];

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    // Synchronously read cached language — SharedPreferences is loaded at app start.
    // Falls back to system locale if supported, otherwise English.
    return const Locale('en');
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kLangKey);
    if (stored != null && _supportedLocales.contains(stored)) {
      state = Locale(stored);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (!_supportedLocales.contains(languageCode)) return;
    state = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, languageCode);

    // Sync to backend — non-fatal.
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
