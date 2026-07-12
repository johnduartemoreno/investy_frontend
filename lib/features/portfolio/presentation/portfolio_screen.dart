import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/asset_gradients.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/gradient_pill_button.dart';
import '../../../../core/presentation/widgets/left_accent_box.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/models/portfolio_response_model.dart';
import 'providers/rest_portfolio_provider.dart';
import 'widgets/allocation_card.dart';
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
          final active =
              portfolio.holdings.where((h) => h.quantityUnits > 0).toList();
          if (active.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.spacingL),
            itemCount: active.length + 1, // +1 = allocation donut header
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.spacingM),
            itemBuilder: (context, index) {
              if (index == 0) {
                return AllocationCard(
                  holdings: active,
                  currency: currency,
                  fxRate: fxRate,
                );
              }
              return _HoldingCard(
                holding: active[index - 1],
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
        padding: const EdgeInsets.all(AppDimens.spacingL),
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
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

  List<Color> _assetGradient() => AssetGradients.assetClass(holding.assetClass);

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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIconBox(
                colors: gradient,
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(holding.symbol,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(_assetClassLabel(l10n),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              SignalBadge(
                label:
                    '${isPositive ? '+' : ''}${holding.returnPct.toStringAsFixed(2)}%',
                color: returnColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LeftAccentBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                  label: l10n.portfolioCurrentPrice,
                  value: CurrencyFormatter.formatWithCurrency(
                      holding.currentPrice * fxRate, currency),
                ),
                _Stat(
                  label: l10n.portfolioAvgCost,
                  value: CurrencyFormatter.formatWithCurrency(
                      holding.avgCost * fxRate, currency),
                ),
                _Stat(
                  label: l10n.portfolioShares,
                  value: holding.quantity
                      .toStringAsFixed(holding.assetClass == 'crypto' ? 4 : 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                  children: [
                    TextSpan(text: '${l10n.portfolioReturn}: '),
                    TextSpan(
                      text:
                          '${holding.unrealizedGainLoss >= 0 ? '+' : ''}${CurrencyFormatter.formatWithCurrency(holding.unrealizedGainLoss * fxRate, currency)}',
                      style: TextStyle(
                          color: returnColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              GradientPillButton(
                label: l10n.dashboardSell,
                onTap: () => context.push('/home/sell-asset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

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
          ),
        ),
      ],
    );
  }
}
