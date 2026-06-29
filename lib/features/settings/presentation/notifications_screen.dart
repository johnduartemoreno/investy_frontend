import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/custom_card.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/services/notification_service.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (mounted) {
      setState(() {
        _enabled =
            settings.authorizationStatus == AuthorizationStatus.authorized;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _loading = true);
    final svc = ref.read(notificationServiceProvider);
    if (value) {
      await svc.init();
      // Re-read OS status in case user denied permission in system dialog.
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      setState(() {
        _enabled = granted;
        _loading = false;
      });
    } else {
      await svc.deleteToken();
      // Token deleted — treat as disabled regardless of OS permission level.
      setState(() {
        _enabled = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).notificationsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              children: [
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    value: _enabled,
                    onChanged: _toggle,
                    title: Text(AppLocalizations.of(context).notificationsPush,
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      AppLocalizations.of(context).notificationsPushSubtitle,
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    secondary: Icon(Icons.notifications_outlined,
                        color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: AppDimens.spacingL),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.spacingXS),
                  child: Text(
                    AppLocalizations.of(context).notificationsDescription,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
    );
  }
}
