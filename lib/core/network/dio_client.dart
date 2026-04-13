import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';

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

  // Firebase Auth interceptor — attaches the current user's ID token as Bearer.
  // The token is refreshed automatically by the Firebase SDK when expired.
  // Routes called without an authenticated user will have no Authorization header.
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
          // Token fetch failed or timed out — proceed without auth.
          // The backend will return 401 which surfaces as AsyncError in the UI.
        }
        return handler.next(options);
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
