import 'package:flutter/foundation.dart';

class AppConfig {
  /// Base URL for the Go REST backend.
  ///
  /// Debug builds point to the local mock server:
  ///   - Android emulator: 10.0.2.2 routes to the host machine's loopback.
  ///   - iOS simulator / macOS: 127.0.0.1 is the host loopback directly.
  /// Release builds point to the production API.
  static String get apiBaseUrl {
    if (kDebugMode || kProfileMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8080';
      }
      // iOS physical device: use Mac's LAN IP
      return 'http://192.168.100.232:8080';
    }
    return 'https://api.investy.com';
  }

  static const String appName = 'Investy';
}
