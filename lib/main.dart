import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'core/debug/firebase_smoke.dart';
import 'core/presentation/widgets/environment_badge.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'l10n/app_localizations.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Run Firebase Smoke Test
  try {
    await firebaseAuthSmokeTest();
  } catch (e) {
    debugPrint('🔥 [FIREBASE SMOKE] Failed to run smoke test: $e');
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Pre-load SharedPreferences so LocaleNotifier + ThemeModeNotifier can read
  // their persisted values synchronously on the first frame.
  await initLocaleProvider();
  await initThemeModeProvider();

  runApp(const ProviderScope(child: InvestyApp()));
}

class InvestyApp extends ConsumerWidget {
  const InvestyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    // Keep number/currency formatting in sync with the in-app language (B51).
    // NumberFormat and the input formatters read Intl.getCurrentLocale(); this
    // single point covers both startup and runtime language changes, since the
    // app rebuilds when the locale provider changes.
    Intl.defaultLocale = locale.languageCode;

    // Initialise FCM once the user is authenticated and email-verified.
    ref.listen(authNotifierProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) {
        ref.read(notificationServiceProvider).init();
      }
    });

    // Show foreground FCM messages as a SnackBar.
    ref.listen(foregroundPushProvider, (_, push) {
      if (push == null) return;
      scaffoldMessengerKey.currentState
        ?..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(push.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (push.body.isNotEmpty) Text(push.body),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
    });

    return MaterialApp.router(
      title: 'Investy',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      // Dev/QA environment + build badge on every screen (B53); no-op in prod.
      builder: (context, child) =>
          EnvironmentBadgeOverlay(child: child ?? const SizedBox.shrink()),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
