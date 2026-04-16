import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../providers/session_provider.dart';

part 'dio_client.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Firebase Auth interceptor — attaches a fresh ID token as Bearer.
  // onRequest: attaches token (5s timeout, fails silently → backend returns 401).
  // onError: on 401, force-refreshes token and retries once. On second 401,
  //          the session is revoked — signs out so the router redirects to login.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user
                .getIdToken()
                .timeout(const Duration(seconds: 5));
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // Token fetch failed or timed out — proceed without auth header.
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }
        // Guard: only retry once — the retry request sets _retried=true in extras.
        if (error.requestOptions.extra['_retried'] == true) {
          // Second 401 — session is revoked. Sign out; router redirects to login.
          await FirebaseAuth.instance.signOut();
          ref.read(sessionTerminatedProvider.notifier).terminate();
          return handler.next(error);
        }

        // First 401 — force-refresh token and retry once.
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return handler.next(error);

        try {
          final freshToken = await user
              .getIdToken(true) // forceRefresh: true
              .timeout(const Duration(seconds: 5));

          final retryOptions = error.requestOptions
            ..headers['Authorization'] = 'Bearer $freshToken'
            ..extra['_retried'] = true;

          final retryResponse = await dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh failed (network, timeout) — propagate original error.
          return handler.next(error);
        }
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ),
  );

  return dio;
}
