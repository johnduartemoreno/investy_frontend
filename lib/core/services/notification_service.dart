import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';

part 'notification_service.g.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // System notification is shown automatically by FCM on Android/iOS.
}

/// Initialises Firebase Messaging, requests permission, obtains the FCM token,
/// and registers it with the backend. Also sets up foreground message handling.
class NotificationService {
  final Dio _dio;
  NotificationService(this._dio);

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS asks; Android 13+ asks via system dialog).
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] permission denied');
      return;
    }

    // Register token with backend.
    await _registerToken(messaging);

    // Refresh token when FCM rotates it.
    FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToBackend);

    // Foreground messages — show a simple SnackBar via overlay.
    // Background/terminated messages are handled by the OS automatically.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] foreground message: ${message.notification?.title}');
      // Foreground display is handled by the in-app SnackBar shown via the
      // NotificationOverlay widget mounted in main.dart.
    });
  }

  Future<void> _registerToken(FirebaseMessaging messaging) async {
    try {
      final token = await messaging.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] _registerToken error: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final idToken = await user.getIdToken();
      await _dio.put(
        '${AppConfig.apiBaseUrl}/api/v1/users/${user.uid}/fcm-token',
        data: jsonEncode({'token': token}),
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      debugPrint('[FCM] token registered');
    } catch (e) {
      debugPrint('[FCM] _sendTokenToBackend error: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final idToken = await user.getIdToken();
      await FirebaseMessaging.instance.deleteToken();
      await _dio.delete(
        '${AppConfig.apiBaseUrl}/api/v1/users/${user.uid}/fcm-token',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      debugPrint('[FCM] token deleted');
    } catch (e) {
      debugPrint('[FCM] deleteToken error: $e');
    }
  }
}

@riverpod
NotificationService notificationService(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  return NotificationService(dio);
}
