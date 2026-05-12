import 'package:flutter/material.dart';
import '../../../core/presentation/widgets/custom_card.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final faqs = [
      (l10n.helpFaq1Q, l10n.helpFaq1A),
      (l10n.helpFaq2Q, l10n.helpFaq2A),
      (l10n.helpFaq3Q, l10n.helpFaq3A),
      (l10n.helpFaq4Q, l10n.helpFaq4A),
      (l10n.helpFaq5Q, l10n.helpFaq5A),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        children: [
          Text(l10n.helpFaq,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...faqs.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CustomCard(
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.spacingL, vertical: AppDimens.spacingXS),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(faq.$1,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  children: [
                    Text(faq.$2,
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.helpContact,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.email_outlined, color: colorScheme.primary),
            title: const Text('support@investy.app'),
            subtitle: Text(l10n.helpReplyTime,
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
