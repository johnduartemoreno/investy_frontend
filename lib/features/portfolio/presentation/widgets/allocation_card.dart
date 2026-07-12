import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/investy_donut_chart.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/asset_gradients.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart'
    show restAvailableCashProvider;
import '../../data/models/portfolio_response_model.dart';

/// Portfolio allocation donut: market value by asset class + a cash slice.
/// Values are FX-invariant proportions; the center total and legend amounts
/// are converted to the display currency at render only (ADR-03).
class AllocationCard extends ConsumerWidget {
  final List<PortfolioHoldingModel> holdings;
  final String currency;
  final double fxRate;

  const AllocationCard({
    super.key,
    required this.holdings,
    required this.currency,
    required this.fxRate,
  });

  // Fixed categorical order — color follows the entity, never its rank.
  static const List<String> _order = ['stock', 'crypto', 'etf', 'cash'];

  String _label(AppLocalizations l10n, String assetClass) {
    switch (assetClass) {
      case 'crypto':
        return l10n.portfolioAssetCrypto;
      case 'etf':
        return l10n.portfolioAssetEtf;
      case 'cash':
        return l10n.portfolioAssetCash;
      default:
        return l10n.portfolioAssetStock;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final byClass = <String, double>{};
    for (final h in holdings) {
      byClass[h.assetClass] = (byClass[h.assetClass] ?? 0) + h.marketValue;
    }
    final cash = ref.watch(restAvailableCashProvider).valueOrNull ?? 0.0;
    if (cash > 0) byClass['cash'] = cash;

    final total = byClass.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return const SizedBox.shrink();

    // Known classes in fixed order first, then any unexpected class appended.
    final keys = [
      ..._order.where(byClass.containsKey),
      ...byClass.keys.where((k) => !_order.contains(k)),
    ];
    final segments = [
      for (final k in keys)
        DonutSegment(
          label: _label(l10n, k),
          value: byClass[k]!,
          color: AssetGradients.allocationColor(k),
        ),
    ];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.portfolioAllocationTitle,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.spacingL),
          Row(
            children: [
              InvestyDonutChart(
                size: 140,
                segments: segments,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.portfolioTotalLabel,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    Text(
                      CurrencyFormatter.formatWithCurrency(
                          total * fxRate, currency),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in segments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: AppDimens.spacingS),
                            Expanded(
                              child: Text(
                                s.label,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${(s.value / total * 100).toStringAsFixed(1)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
