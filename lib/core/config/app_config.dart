import 'package:flutter/foundation.dart';

const _useStaging = bool.fromEnvironment('USE_STAGING');
const _localIp = String.fromEnvironment('LOCAL_IP');
const _stagingUrl =
    'http://investy-backend-stg.eba-wqzwp2yc.us-east-1.elasticbeanstalk.com';

class AppConfig {
  /// Base URL for the Go REST backend.
  ///
  /// Priority (debug/profile builds):
  ///   1. --dart-define=USE_STAGING=true  → AWS staging
  ///   2. --dart-define=LOCAL_IP=192.168.x.x → physical device on LAN
  ///   3. Android emulator → 10.0.2.2 (host loopback)
  ///   4. iOS simulator   → localhost
  /// Release builds → production API.
  static String get apiBaseUrl {
    if (_useStaging) return _stagingUrl;
    if (kDebugMode || kProfileMode) {
      if (_localIp.isNotEmpty) return 'http://$_localIp:8080';
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8080';
      }
      return 'http://localhost:8080';
    }
    return 'https://api.investy.com';
  }

  static const String appName = 'Investy';
}
