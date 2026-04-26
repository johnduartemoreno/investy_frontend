import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/responsive_center.dart';
import '../../../../core/utils/currency_formatter.dart';
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
        title: const Text('Financial Goals'),
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
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const CreateGoalSheet(),
          );
        },
        label: const Text('Add Goal'),
        icon: const Icon(Icons.add),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progress; // safe: clamp(0.0, 1.0), guard on targetAmountCents > 0

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _categoryIcon(goal.category),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    goal.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingM),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppDimens.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${CurrencyFormatter.formatWithCurrency(goal.currentAmount * fxRate, currency)} saved'),
              Text('Target: ${CurrencyFormatter.formatWithCurrency(goal.targetAmount * fxRate, currency)}'),
            ],
          ),
          const SizedBox(height: AppDimens.spacingS),
          Text(
            'Deadline: ${_formatDate(goal.deadlineDate)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
