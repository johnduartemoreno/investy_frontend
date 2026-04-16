import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About Investy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Material(
              elevation: 4,
              color: Colors.white,
              shape: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Icon(Icons.savings_outlined,
                    size: 56, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text('Investy',
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Version 1.0.0',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            Text(
              'Investy helps you track your investments, set financial goals, '
              'and grow your portfolio — all in one place.',
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _AboutTile(
              icon: Icons.shield_outlined,
              label: 'Privacy Policy',
              onTap: () {},
            ),
            const Divider(height: 1),
            _AboutTile(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              onTap: () {},
            ),
            const Divider(height: 1),
            _AboutTile(
              icon: Icons.email_outlined,
              label: 'Contact us — support@investy.app',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AboutTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
