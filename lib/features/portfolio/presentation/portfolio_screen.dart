import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context).portfolioTitle),
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
    final l10n = AppLocalizations.of(context);
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
              l10n.portfolioNoHoldings,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.portfolioNoHoldings,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.search),
              label: Text(AppLocalizations.of(context).dashboardBuy),
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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.commonError,
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
              label: Text(l10n.commonRetry),
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

  List<Color> _assetGradient() {
    switch (holding.assetClass) {
      case 'crypto':
        return [const Color(0xFF78350f), const Color(0xFFf59e0b)];
      case 'etf':
        return [AppTheme.brandPurple, AppTheme.brandPurpleLight];
      default:
        return [const Color(0xFF1d4ed8), const Color(0xFF3b82f6)];
    }
  }

  String _assetClassLabel(AppLocalizations l10n) {
    switch (holding.assetClass) {
      case 'crypto':
        return l10n.portfolioAssetCrypto;
      case 'etf':
        return l10n.portfolioAssetEtf;
      default:
        return l10n.portfolioAssetStock;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isPositive = holding.returnPct >= 0;
    final returnColor = isPositive ? AppTheme.signalGreen : cs.error;
    final gradient = _assetGradient();
    final label = holding.symbol.length > 4
        ? holding.symbol.substring(0, 4)
        : holding.symbol;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  // Gradient icon — same pattern as Owl rec cards
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppDimens.radiusAssetIcon),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.spacingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(holding.symbol,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(_assetClassLabel(l10n),
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
                    // Return badge — colored pill like Owl signal badge
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: returnColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${holding.returnPct.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: returnColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                  label: AppLocalizations.of(context).portfolioCurrentPrice,
                  value: CurrencyFormatter.formatWithCurrency(
                      holding.currentPrice * fxRate, currency),
                ),
                _Stat(
                  label: AppLocalizations.of(context).portfolioAvgCost,
                  value: CurrencyFormatter.formatWithCurrency(
                      holding.avgCost * fxRate, currency),
                ),
                _Stat(
                  label: '${holding.quantity.toStringAsFixed(holding.assetClass == 'crypto' ? 4 : 2)} ${holding.assetClass == 'crypto' ? holding.symbol : l10n.portfolioShares}',
                  value: '',
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
