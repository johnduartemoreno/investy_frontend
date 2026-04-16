import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_mode_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentMode = ref.watch(themeModeNotifierProvider);

    final options = [
      (ThemeMode.system, Icons.brightness_auto_outlined, 'System default'),
      (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final (mode, icon, label) = options[i];
          final selected = currentMode == mode;
          return ListTile(
            leading: Icon(icon,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant),
            title: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            trailing: selected
                ? Icon(Icons.check_circle,
                    color: colorScheme.primary)
                : Icon(Icons.radio_button_unchecked,
                    color: colorScheme.outline),
            onTap: () =>
                ref.read(themeModeNotifierProvider.notifier).setMode(mode),
          );
        },
      ),
    );
  }
}
