import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/gradient_pill_button.dart';
import '../../../../core/presentation/widgets/left_accent_box.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/presentation/widgets/responsive_center.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../dashboard/data/models/goal_response_model.dart';
import '../../dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;
import 'providers/rest_goals_provider.dart';
import 'widgets/create_goal_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(restGoalsProvider);
    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).goalsTitle),
      ),
      body: goalsAsync.when(
        data: (goals) => ResponsiveCenter(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimens.spacingL),
            itemCount: goals.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimens.spacingM),
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalCard(goal: goal, currency: currency, fxRate: fxRate);
            },
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text(AppLocalizations.of(context).commonError)),
      ),
      floatingActionButton: GradientPillButton(
        label: AppLocalizations.of(context).goalsAddButton,
        leading: const Icon(Icons.add, color: Colors.white, size: 18),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const CreateGoalSheet(),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalResponseModel goal;
  final String currency;
  final double fxRate;

  const _GoalCard({
    required this.goal,
    required this.currency,
    required this.fxRate,
  });

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'vacation':
      case 'travel': return Icons.flight;
      case 'education': return Icons.school;
      case 'emergency': return Icons.shield;
      case 'health': return Icons.favorite;
      default: return Icons.flag;
    }
  }

  List<Color> _categoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'car': return [const Color(0xFF1d4ed8), const Color(0xFF3b82f6)];
      case 'home': return [const Color(0xFF065f46), const Color(0xFF10b981)];
      case 'vacation':
      case 'travel': return [const Color(0xFF0369a1), const Color(0xFF38bdf8)];
      case 'education': return [AppTheme.brandPurple, AppTheme.brandPurpleLight];
      case 'emergency': return [const Color(0xFF991b1b), const Color(0xFFf87171)];
      case 'health': return [const Color(0xFF9d174d), const Color(0xFFf472b6)];
      default: return [const Color(0xFF78350f), const Color(0xFFf59e0b)];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progress;
    final gradient = _categoryGradient(goal.category);

    final l10n = AppLocalizations.of(context);
    final cs = theme.colorScheme;

    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — icon + name + progress badge
          Row(
            children: [
              GradientIconBox(
                colors: gradient,
                circle: true,
                child: Icon(_categoryIcon(goal.category),
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  goal.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SignalBadge(
                label: '${(progress * 100).toStringAsFixed(1)}%',
                color: cs.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar + amounts with left accent
          LeftAccentBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: cs.surfaceContainerHighest,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AmountLabel(
                      label: l10n.goalSaved,
                      value: CurrencyFormatter.formatWithCurrency(
                          goal.currentAmount * fxRate, currency),
                      theme: theme,
                    ),
                    _AmountLabel(
                      label: l10n.goalTarget,
                      value: CurrencyFormatter.formatWithCurrency(
                          goal.targetAmount * fxRate, currency),
                      theme: theme,
                      alignEnd: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.goalDeadline}: ${_formatDate(goal.deadlineDate)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool alignEnd;

  const _AmountLabel({
    required this.label,
    required this.value,
    required this.theme,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value,
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
