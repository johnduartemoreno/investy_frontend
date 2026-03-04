import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/debug/firebase_smoke.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/user_profile_sync_provider.dart';

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
  // TODO: Register Hive Adapters here

  runApp(const ProviderScope(child: InvesstyApp()));
}

class InvesstyApp extends ConsumerWidget {
  const InvesstyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Activate UserProfileSync to listen for auth changes
    ref.watch(userProfileSyncProvider);

    return MaterialApp.router(
      title: 'Invessty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
    );
  }
}
