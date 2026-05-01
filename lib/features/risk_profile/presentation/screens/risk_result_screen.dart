import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/risk_profile_model.dart';
import '../providers/risk_provider.dart';

class RiskResultScreen extends ConsumerWidget {
  const RiskResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(riskProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.riskProfileTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, __) => Center(
          child: Text(l10n.riskProfileLoadError),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(l10n.riskProfileLoadError));
          }
          return _ProfileContent(profile: profile, l10n: l10n);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final RiskProfileModel profile;
  final AppLocalizations l10n;

  const _ProfileContent({required this.profile, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (label, desc, icon, color) = switch (profile.profile) {
      'moderate' => (
          l10n.riskProfileModerate,
          l10n.riskProfileModerateDesc,
          Icons.balance_outlined,
          Colors.orange,
        ),
      'aggressive' => (
          l10n.riskProfileAggressive,
          l10n.riskProfileAggressiveDesc,
          Icons.trending_up,
          Colors.green,
        ),
      _ => (
          l10n.riskProfileConservative,
          l10n.riskProfileConservativeDesc,
          Icons.shield_outlined,
          Colors.blue,
        ),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimens.spacingXL),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: color),
            ),
          ),
          const SizedBox(height: AppDimens.spacingXL),
          Text(
            label,
            style: theme.textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.w700, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spacingL),
          Text(
            desc,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spacingXL),
          _ScoreChip(score: profile.score, color: color),
          const SizedBox(height: AppDimens.spacingXL * 2),
          PrimaryButton(
            text: l10n.commonDone,
            onPressed: () => context.go('/settings'),
          ),
          const SizedBox(height: AppDimens.spacingM),
          TextButton(
            onPressed: () => context.pushReplacement('/settings/risk-profile'),
            child: Text(l10n.riskProfileRetake),
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreChip({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingL, vertical: AppDimens.spacingS),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(
          'Score: $score / 20',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
