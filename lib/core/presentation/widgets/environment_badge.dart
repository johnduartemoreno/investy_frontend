import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Discreet dev/QA badge showing which backend the app is talking to and which
/// build it is (B53). A stale build against the wrong backend caused real UAT
/// confusion (2026-07-26); this makes it obvious at a glance.
///
/// Hidden in a real production build ([AppConfig.showBuildBadge]) so end users
/// never see it.
class EnvironmentBadge extends StatelessWidget {
  const EnvironmentBadge({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.showBuildBadge) return const SizedBox.shrink();

    final (label, color) = switch (AppConfig.environment) {
      AppEnvironment.local => ('LOCAL', AppTheme.brandPurple),
      AppEnvironment.staging => ('STAGING', AppTheme.signalAmber),
      AppEnvironment.prod => ('PROD', AppTheme.signalRed), // never rendered
    };
    final sha = AppConfig.gitSha;
    final text = sha.isEmpty ? label : '$label · $sha';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingS, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Wraps [child] with the [EnvironmentBadge] pinned near the top of the screen.
/// Non-interactive (taps pass through) and a no-op in production. Intended for
/// `MaterialApp.builder` so the badge shows on every screen.
class EnvironmentBadgeOverlay extends StatelessWidget {
  const EnvironmentBadgeOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.showBuildBadge) return child;

    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.paddingOf(context).top + 2,
          left: 0,
          right: 0,
          child: const IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: EnvironmentBadge(),
            ),
          ),
        ),
      ],
    );
  }
}
