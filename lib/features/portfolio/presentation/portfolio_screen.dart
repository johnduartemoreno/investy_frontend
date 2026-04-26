import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../data/models/portfolio_response_model.dart';
import 'providers/rest_portfolio_provider.dart';
import '../../dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(restPortfolioProvider);
    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
      ),
      body: portfolioAsync.when(
        data: (portfolio) {
          final active = portfolio.holdings
              .where((h) => h.quantityUnits > 0)
              .toList();
          if (active.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.spacingL),
            itemCount: active.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.spacingM),
            itemBuilder: (context, index) {
              return _HoldingCard(
                holding: active[index],
                currency: currency,
                fxRate: fxRate,
              );
            },
          );
        },
        loading: () => _buildLoadingState(context),
        error: (err, stack) => _buildErrorState(context, ref, err),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up_rounded,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Your portfolio is empty',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start investing today to see your holdings appear here.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.search),
              label: const Text('Explore Assets'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spacingM),
      itemBuilder: (context, index) => _buildShimmerCard(context),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4))),
                  ]),
                ]),
                Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(4))),
              ],
            ),
            const SizedBox(height: 24),
            Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Unable to load portfolio',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => ref.refresh(restPortfolioProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final PortfolioHoldingModel holding;
  final String currency;
  final double fxRate;

  const _HoldingCard({
    required this.holding,
    required this.currency,
    required this.fxRate,
  });

  Color _assetColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (holding.assetClass) {
      case 'crypto':
        return cs.tertiary;
      case 'etf':
        return cs.secondary;
      default:
        return cs.primary;
    }
  }

  String _assetClassLabel() {
    switch (holding.assetClass) {
      case 'crypto':
        return 'Crypto';
      case 'etf':
        return 'ETF';
      default:
        return 'Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _assetColor(context);
    final isPositive = holding.returnPct >= 0;
    final returnColor = isPositive ? cs.tertiary : cs.error;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            // Header row: symbol + market value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Text(
                      holding.symbol.isNotEmpty ? holding.symbol[0] : '?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  const SizedBox(width: AppDimens.spacingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(holding.symbol,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(_assetClassLabel(),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatWithCurrency(
                          holding.marketValue * fxRate, currency),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${holding.quantity.toStringAsFixed(holding.assetClass == 'crypto' ? 6 : 2)} ${holding.assetClass == 'crypto' ? holding.symbol : 'shares'}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // Stats row: current price / avg cost / return
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                  label: 'Price',
                  value: CurrencyFormatter.formatWithCurrency(
                      holding.currentPrice * fxRate, currency),
                ),
                _Stat(
                  label: 'Avg Cost',
                  value: CurrencyFormatter.formatWithCurrency(
                      holding.avgCost * fxRate, currency),
                ),
                _Stat(
                  label: 'Return',
                  value:
                      '${isPositive ? '+' : ''}${holding.returnPct.toStringAsFixed(2)}%',
                  valueColor: returnColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Stat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
