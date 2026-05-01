import 'package:flutter/foundation.dart';

const _useStaging = bool.fromEnvironment('USE_STAGING');
const _stagingUrl =
    'http://investy-backend-stg.eba-wqzwp2yc.us-east-1.elasticbeanstalk.com';

class AppConfig {
  /// Base URL for the Go REST backend.
  ///
  /// Debug builds point to the local backend by default.
  /// Pass --dart-define=USE_STAGING=true to hit the AWS staging environment.
  ///   - Android emulator: 10.0.2.2 routes to the host machine's loopback.
  ///   - iOS physical device: uses Mac's LAN IP.
  /// Release builds point to the production API.
  static String get apiBaseUrl {
    if (_useStaging) return _stagingUrl;
    if (kDebugMode || kProfileMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8080';
      }
      return 'http://192.168.100.232:8080';
    }
    return 'https://api.investy.com';
  }

  static const String appName = 'Investy';
}
