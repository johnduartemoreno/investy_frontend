import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/investy_line_chart.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;
import '../providers/portfolio_history_provider.dart';

/// Portfolio-value chart: current value + range selector + line/area chart.
/// Values come as USD cents from the history endpoint; converted to the display
/// currency at render (ADR-03).
class PortfolioChartCard extends ConsumerWidget {
  /// Compact = no title and no big value line (the caller already shows the
  /// value, e.g. the Home balance card). Just chart + range chips.
  final bool compact;

  const PortfolioChartCard({super.key, this.compact = false});

  static const List<String> _ranges = ['1W', '1M', '3M', '1Y', 'ALL'];

  String _rangeLabel(AppLocalizations l10n, String r) {
    switch (r) {
      case '1W':
        return l10n.chartRange1W;
      case '3M':
        return l10n.chartRange3M;
      case '1Y':
        return l10n.chartRange1Y;
      case 'ALL':
        return l10n.chartRangeAll;
      default:
        return l10n.chartRange1M;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;
    final selectedRange = ref.watch(portfolioHistoryRangeProvider);
    final historyAsync = ref.watch(portfolioHistoryProvider);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Text(
              l10n.chartPortfolioValue,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimens.spacingM),
          ],
          historyAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            error: (_, __) => SizedBox(
              height: 200,
              child: Center(child: Text(l10n.commonError)),
            ),
            data: (history) {
              if (history.points.length < 2) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      l10n.chartNotEnoughData,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final values =
                  history.points.map((p) => p.totalAmount * fxRate).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact) ...[
                    Text(
                      CurrencyFormatter.formatWithCurrency(
                          values.last, currency),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandPurpleLight,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spacingM),
                  ],
                  InvestyLineChart(
                    values: values,
                    tooltipFormat: (v) =>
                        CurrencyFormatter.formatWithCurrency(v, currency),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimens.spacingM),
          Row(
            children: [
              for (final r in _ranges)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _RangeChip(
                      label: _rangeLabel(l10n, r),
                      active: r == selectedRange,
                      onTap: () => ref
                          .read(portfolioHistoryRangeProvider.notifier)
                          .set(r),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              active ? cs.primary : cs.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? cs.onPrimary : cs.primary,
          ),
        ),
      ),
    );
  }
}
