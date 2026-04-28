import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      'How do I add money to my account?',
      'Tap "Top-up" on the home screen and enter the amount you want to deposit. '
          'The funds will be credited to your available cash balance.',
    ),
    (
      'How do I buy an asset?',
      'Tap "Buy" on the home screen, search for the asset by name or ticker symbol, '
          'enter the quantity and confirm the purchase.',
    ),
    (
      'How do I set a financial goal?',
      'Navigate to the Goals tab and tap the "+" button. Enter a name, target amount, '
          'category, and deadline. Your contributions will automatically count toward your goals.',
    ),
    (
      'Can I withdraw my funds at any time?',
      'Yes. Tap "Withdraw" on the home screen and enter the amount. '
          'Withdrawals are processed from your available cash balance.',
    ),
    (
      'What happens if I forget my password?',
      'On the login screen, tap "Forgot password?" and enter your email. '
          'We will send you a reset link within a few minutes.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).helpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppLocalizations.of(context).helpFaq,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._faqs.map(
            (faq) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(faq.$1,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500)),
                children: [
                  Text(faq.$2,
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context).helpContact,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.email_outlined, color: colorScheme.primary),
            title: const Text('support@investy.app'),
            subtitle: Text('We reply within 24 hours',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
