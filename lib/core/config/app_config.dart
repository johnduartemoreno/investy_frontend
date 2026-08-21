import 'package:flutter/foundation.dart';

const _useStaging = bool.fromEnvironment('USE_STAGING');
const _localIp = String.fromEnvironment('LOCAL_IP');
const _gitSha = String.fromEnvironment('GIT_SHA');
const _stagingUrl =
    'http://investy-backend-stg.eba-wqzwp2yc.us-east-1.elasticbeanstalk.com';

/// Which backend the app is talking to. Drives the dev/QA environment badge
/// (B53) so a stale build against the wrong backend is obvious at a glance.
enum AppEnvironment { local, staging, prod }

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
    return 'https://api.investyapp.com';
  }

  /// The resolved environment, mirroring [apiBaseUrl]'s priority: staging wins
  /// whenever `USE_STAGING` is set (even in a release build); a debug/profile
  /// build is local dev; a release build without staging is production.
  static AppEnvironment get environment {
    if (_useStaging) return AppEnvironment.staging;
    if (kDebugMode || kProfileMode) return AppEnvironment.local;
    return AppEnvironment.prod;
  }

  /// Short git SHA injected at build time via `--dart-define=GIT_SHA=$(git
  /// rev-parse --short HEAD)`. Empty when the build didn't provide it.
  static String get gitSha => _gitSha;

  /// Whether the dev/QA build badge should be shown. Shown for local and
  /// staging (and any debug/profile build); hidden only in a real production
  /// build so end users never see it.
  static bool get showBuildBadge => environment != AppEnvironment.prod;

  static const String appName = 'Investy';

  /// Support mailbox shown in Help and About. Lives here, not inline in the
  /// screens, because the address it replaced (`support@investy.app`) was a
  /// domain we do not own — the same mistake H07 fixed in [apiBaseUrl], which
  /// survived in the two screens that actually show it to the user because
  /// each held its own copy.
  static const String supportEmail = 'support@investyapp.com';
}
