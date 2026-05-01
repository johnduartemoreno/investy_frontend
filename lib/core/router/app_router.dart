import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/goals/presentation/goals_screen.dart';
import '../../features/portfolio/presentation/portfolio_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/appearance_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/help_screen.dart';
import '../../features/settings/presentation/notifications_screen.dart';
import '../../features/settings/presentation/security_screen.dart';
import '../../features/kyc/presentation/screens/kyc_screen.dart';
import '../../features/risk_profile/presentation/screens/risk_questionnaire_screen.dart';
import '../../features/risk_profile/presentation/screens/risk_result_screen.dart';
import '../../features/transactions/presentation/screens/top_up_screen.dart';
import '../../features/dashboard/presentation/screens/buy_asset_screen.dart';
import '../../features/dashboard/presentation/screens/sell_asset_screen.dart';
import '../presentation/main_shell_screen.dart';
import 'go_router_refresh_stream.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorGoalsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellGoals');
final _shellNavigatorPortfolioKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellPortfolio');
final _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

@riverpod
GoRouter goRouter(Ref ref) {
  // Create a notifier that rebuilds GoRouter when auth state changes
  final authStateStream = FirebaseAuth.instance.authStateChanges();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authStateStream),
    redirect: (context, state) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isAuthenticated = currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';
      final isVerifyEmailRoute = state.matchedLocation == '/verify-email';

      debugPrint(
          '🔒 [Router] Redirect check - authenticated: $isAuthenticated, verified: ${currentUser?.emailVerified}, route: ${state.matchedLocation}');

      // STATE 1: Not authenticated → login/signup only
      if (!isAuthenticated && !isAuthRoute) {
        debugPrint('🔒 [Router] Redirecting to login - user not authenticated');
        return '/login';
      }

      // STATE 2: Authenticated but email not verified → verify-email screen only
      if (isAuthenticated &&
          !currentUser.emailVerified &&
          !isVerifyEmailRoute &&
          !isAuthRoute) {
        debugPrint(
            '🔒 [Router] Redirecting to verify-email - email not verified');
        return '/verify-email';
      }

      // STATE 3: Authenticated and verified → block access to auth/verify screens
      if (isAuthenticated && currentUser.emailVerified) {
        if (isAuthRoute || isVerifyEmailRoute) {
          debugPrint('🔒 [Router] Redirecting to home - user already verified');
          return '/home';
        }
      }

      // Allow navigation to signup/login when not authenticated
      // Allow navigation to verify-email when authenticated but not verified
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // 1. Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'top-up',
                    builder: (context, state) => const TopUpScreen(),
                  ),
                  GoRoute(
                    path: 'buy-asset',
                    builder: (context, state) => const BuyAssetScreen(),
                  ),
                  GoRoute(
                    path: 'sell-asset',
                    builder: (context, state) => const SellAssetScreen(),
                  ),
                ],
              ),
            ],
          ),
          // 2. Goals
          StatefulShellBranch(
            navigatorKey: _shellNavigatorGoalsKey,
            routes: [
              GoRoute(
                path: '/goals',
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
          // 3. Portfolio
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPortfolioKey,
            routes: [
              GoRoute(
                path: '/portfolio',
                builder: (context, state) => const PortfolioScreen(),
              ),
            ],
          ),
          // 4. Settings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'appearance',
                    builder: (context, state) => const AppearanceScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'security',
                    builder: (context, state) => const SecurityScreen(),
                  ),
                  GoRoute(
                    path: 'kyc',
                    builder: (context, state) => const KycScreen(),
                  ),
                  GoRoute(
                    path: 'risk-profile',
                    builder: (context, state) =>
                        const RiskQuestionnaireScreen(),
                    routes: [
                      GoRoute(
                        path: 'result',
                        builder: (context, state) => const RiskResultScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
