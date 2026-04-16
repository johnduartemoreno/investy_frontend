import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';

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
    final settings =
        await FirebaseMessaging.instance.getNotificationSettings();
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
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: SwitchListTile(
                    value: _enabled,
                    onChanged: _toggle,
                    title: Text('Push notifications',
                        style: textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      'Receive alerts for transactions and goal deadlines.',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    secondary:
                        Icon(Icons.notifications_outlined, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You will be notified when:\n'
                  '• A deposit or withdrawal is processed\n'
                  '• A buy or sell order is confirmed\n'
                  '• A financial goal deadline is approaching (30 days)',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
    );
  }
}
