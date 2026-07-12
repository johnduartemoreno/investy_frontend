import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/left_accent_box.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/asset_gradients.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../dashboard/data/models/buy_asset_args.dart';
import '../../dashboard/data/models/goal_response_model.dart';
import '../../dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;
import 'providers/rest_goals_provider.dart';

/// Goal detail screen (S18 / F6).
/// Shows combined progress (cash + invested), a linear completion projection,
/// and a CTA to invest toward this goal with the goal pre-selected.
class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  /// Passed via `extra` when navigating from the goals list (avoids a refetch).
  /// Null on deep-link / refresh — resolved from [restGoalsProvider] by id.
  final GoalResponseModel? goal;

  const GoalDetailScreen({super.key, required this.goalId, this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (goal != null) {
      return _GoalDetailBody(goal: goal!);
    }

    // Deep-link fallback: resolve the goal from the list provider by id.
    final goalsAsync = ref.watch(restGoalsProvider);
    return goalsAsync.when(
      data: (goals) {
        final match = goals.where((g) => g.id == goalId).toList();
        if (match.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.commonError)),
          );
        }
        return _GoalDetailBody(goal: match.first);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.commonError)),
      ),
    );
  }
}

class _GoalDetailBody extends ConsumerWidget {
  final GoalResponseModel goal;

  const _GoalDetailBody({required this.goal});

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'vacation':
      case 'travel':
        return Icons.flight;
      case 'education':
        return Icons.school;
      case 'emergency':
        return Icons.shield;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.flag;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;

    final progress = goal.progress;
    final projection = goal.projectedCompletionDate;

    String money(double dollars) =>
        CurrencyFormatter.formatWithCurrency(dollars * fxRate, currency);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          goal.name,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimens.spacingS),
              // ── Progress hero ─────────────────────────────────────────
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GradientIconBox(
                          colors: const [
                            AppTheme.brandPurple,
                            AppTheme.brandPurpleLight
                          ],
                          circle: true,
                          size: 44,
                          child: Icon(_categoryIcon(goal.category),
                              size: 22, color: Colors.white),
                        ),
                        const SizedBox(width: AppDimens.spacingM),
                        Expanded(
                          child: Text(
                            goal.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        SignalBadge(
                          label: '${(progress * 100).toStringAsFixed(1)}%',
                          color: cs.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.spacingL),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: cs.surfaceContainerHighest,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: AppDimens.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(money(goal.currentAmount),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${l10n.goalTarget}: ${money(goal.targetAmount)}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.spacingS),
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          '${l10n.goalDeadline}: ${_formatDate(goal.deadlineDate)}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Cash saved ────────────────────────────────────────────
              CustomCard(
                child: Row(
                  children: [
                    const GradientIconBox(
                      colors: AssetGradients.cash,
                      circle: true,
                      child: Icon(Icons.savings, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: AppDimens.spacingM),
                    Expanded(
                      child: Text(l10n.goalDetailCashTitle,
                          style: theme.textTheme.titleSmall),
                    ),
                    Text(money(goal.cashContributed),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Investments toward this goal ──────────────────────────
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.goalDetailInvestmentsTitle,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: AppDimens.spacingM),
                    if (goal.hasInvestments)
                      Row(
                        children: [
                          const GradientIconBox(
                            colors: [
                              AppTheme.brandPurple,
                              AppTheme.brandPurpleLight
                            ],
                            circle: true,
                            child: Icon(Icons.trending_up,
                                size: 20, color: Colors.white),
                          ),
                          const SizedBox(width: AppDimens.spacingM),
                          Expanded(
                            child: Text(l10n.goalInvested,
                                style: theme.textTheme.titleSmall),
                          ),
                          Text(money(goal.investedValue),
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.brandPurpleLight)),
                        ],
                      )
                    else
                      Text(l10n.goalDetailNoInvestments,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Projection ────────────────────────────────────────────
              LeftAccentBox(
                child: Text(
                  projection != null
                      ? l10n.goalDetailProjection(_formatDate(projection))
                      : l10n.goalDetailProjectionUnknown,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppDimens.spacingXL),

              // ── Invest toward this goal ───────────────────────────────
              PrimaryButton(
                text: l10n.goalInvestButton,
                onPressed: () => context.push(
                  '/home/buy-asset',
                  extra: BuyAssetArgs(goalId: goal.id, goalName: goal.name),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
