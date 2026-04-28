import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../l10n/app_localizations.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentMode = ref.watch(themeModeNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);

    final themeOptions = [
      (ThemeMode.system, Icons.brightness_auto_outlined, l10n.appearanceThemeSystem),
      (ThemeMode.light, Icons.light_mode_outlined, l10n.appearanceThemeLight),
      (ThemeMode.dark, Icons.dark_mode_outlined, l10n.appearanceThemeDark),
    ];

    final languageOptions = [
      ('en', Icons.language, l10n.languageEn),
      ('es', Icons.language, l10n.languageEs),
      ('pt', Icons.language, l10n.languagePt),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(context, l10n.appearanceTheme),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < themeOptions.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _optionTile(
                    context: context,
                    icon: themeOptions[i].$2,
                    label: themeOptions[i].$3,
                    selected: currentMode == themeOptions[i].$1,
                    onTap: () => ref
                        .read(themeModeNotifierProvider.notifier)
                        .setMode(themeOptions[i].$1),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, l10n.appearanceLanguage),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < languageOptions.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _optionTile(
                    context: context,
                    icon: languageOptions[i].$2,
                    label: languageOptions[i].$3,
                    selected: currentLocale.languageCode == languageOptions[i].$1,
                    onTap: () => ref
                        .read(localeNotifierProvider.notifier)
                        .setLanguage(languageOptions[i].$1),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _optionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant),
      title: Text(
        label,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : Icon(Icons.radio_button_unchecked, color: colorScheme.outline),
      onTap: onTap,
    );
  }
}
