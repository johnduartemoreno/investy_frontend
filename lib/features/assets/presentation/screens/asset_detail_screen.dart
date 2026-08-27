import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/investy_line_chart.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/asset_gradients.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/data/models/buy_asset_args.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;
import '../../../portfolio/data/models/portfolio_response_model.dart';
import '../../../dashboard/presentation/controllers/fit_score_controller.dart';
import '../../../dashboard/presentation/widgets/fit_score_card.dart';
import '../../../../core/providers/locale_provider.dart';
import '../providers/asset_history_provider.dart';

/// Asset detail: price chart (range selector) + your position + Buy/Sell/Alert.
/// Reached by tapping a holding in Portfolio (B43-F5).
class AssetDetailScreen extends ConsumerStatefulWidget {
  final PortfolioHoldingModel? holding;

  const AssetDetailScreen({super.key, required this.holding});

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  static const List<String> _ranges = ['1W', '1M', '3M', '1Y', 'ALL'];
  String _range = '1M';
  bool _showAvgCost = true;

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

  String _assetClassLabel(AppLocalizations l10n, String assetClass) {
    switch (assetClass) {
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
    final holding = widget.holding;

    if (holding == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.commonError)),
      );
    }

    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;
    final historyAsync =
        ref.watch(assetHistoryProvider(holding.symbol, _range));

    final isPositive = holding.returnPct >= 0;
    final returnColor = isPositive ? AppTheme.signalGreen : cs.error;
    final tickerLabel = holding.symbol.length > 4
        ? holding.symbol.substring(0, 4)
        : holding.symbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(holding.symbol.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_outlined),
            tooltip: l10n.alertsCreateButton,
            onPressed: () => context.push('/settings/price-alerts'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header: ticker + name + current price ──
              Row(
                children: [
                  GradientIconBox(
                    size: 48,
                    colors: AssetGradients.assetClass(holding.assetClass),
                    child: Text(tickerLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: AppDimens.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(holding.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(_assetClassLabel(l10n, holding.assetClass),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatWithCurrency(
                        holding.currentPrice * fxRate, currency),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.brandPurpleLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Price chart + range selector ──
              CustomCard(
                child: Column(
                  children: [
                    historyAsync.when(
                      loading: () => const SizedBox(
                        height: 200,
                        child:
                            Center(child: CircularProgressIndicator.adaptive()),
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
                              child: Text(l10n.chartNotEnoughData,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant)),
                            ),
                          );
                        }
                        final values = history.points
                            .map((p) => p.price * fxRate)
                            .toList();
                        return InvestyLineChart(
                          values: values,
                          tooltipFormat: (v) =>
                              CurrencyFormatter.formatWithCurrency(v, currency),
                          referenceValue:
                              _showAvgCost ? holding.avgCost * fxRate : null,
                          referenceColor: AppTheme.signalAmber,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimens.spacingM),
                    Row(
                      children: [
                        for (final r in _ranges)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: _RangeChip(
                                label: _rangeLabel(l10n, r),
                                active: r == _range,
                                onTap: () => setState(() => _range = r),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Toggle: overlay your average cost as a reference line.
                    InkWell(
                      onTap: () => setState(() => _showAvgCost = !_showAvgCost),
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusInput),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _showAvgCost,
                                onChanged: (v) =>
                                    setState(() => _showAvgCost = v ?? false),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: AppDimens.spacingS),
                            Container(
                              width: 14,
                              height: 2,
                              color: AppTheme.signalAmber,
                            ),
                            const SizedBox(width: 6),
                            Text(l10n.assetDetailShowAvgCost,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Your position ──
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.assetDetailPosition,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppDimens.spacingM),
                    _row(theme, l10n.portfolioShares,
                        holding.quantity.toString()),
                    _row(
                        theme,
                        l10n.portfolioAvgCost,
                        CurrencyFormatter.formatWithCurrency(
                            holding.avgCost * fxRate, currency)),
                    _row(
                        theme,
                        l10n.assetDetailMarketValue,
                        CurrencyFormatter.formatWithCurrency(
                            holding.marketValue * fxRate, currency)),
                    _row(
                      theme,
                      l10n.portfolioReturn,
                      '${isPositive ? '+' : ''}${holding.returnPct.toStringAsFixed(2)}%',
                      valueColor: returnColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Fit Score of what you already hold (S19-G7, absorbs B47) ──
              // The buy screen asks "how would this purchase fit"; here the
              // question is "how does what I already own fit", so the amount
              // sent is zero. That is a real question with a real answer, not a
              // hypothetical purchase invented to have something to score.
              _FitSection(symbol: holding.symbol),

              const SizedBox(height: AppDimens.spacingM),
            ],
          ),
        ),
      ),
      // Buy & Sell always visible above the tab bar (never cut off).
      bottomNavigationBar: Container(
        color: cs.surface,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(AppDimens.spacingL,
              AppDimens.spacingS, AppDimens.spacingL, AppDimens.spacingS),
          child: SizedBox(
            height: 56, // bound the height — PrimaryButton has no intrinsic one
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: l10n.dashboardBuy,
                    onPressed: () => context.push('/home/buy-asset',
                        extra: BuyAssetArgs(
                          symbol: holding.symbol,
                          name: holding.name,
                          priceCents: holding.currentPriceCents,
                        )),
                  ),
                ),
                const SizedBox(width: AppDimens.spacingM),
                Expanded(
                  child: PrimaryButton(
                    text: l10n.dashboardSell,
                    onPressed: () => context.push('/home/sell-asset'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value,
      {Color? valueColor}) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RangeChip(
      {required this.label, required this.active, required this.onTap});

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
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? cs.onPrimary : cs.primary)),
      ),
    );
  }
}

/// Fit Score for a position the user already holds.
///
/// A widget of its own so the fetch fires once when the section mounts rather
/// than on every rebuild of the detail screen — the chart's range selector
/// rebuilds it constantly, and each assessment costs a model call.
class _FitSection extends ConsumerStatefulWidget {
  const _FitSection({required this.symbol});

  final String symbol;

  @override
  ConsumerState<_FitSection> createState() => _FitSectionState();
}

class _FitSectionState extends ConsumerState<_FitSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetch();
    });
  }

  void _fetch() {
    ref.read(fitScoreControllerProvider('detail').notifier).fetch(
          symbol: widget.symbol,
          amountCents: 0, // assess the holding as it stands, not a purchase
          language: ref.read(localeNotifierProvider).languageCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    // The owl's prose is written by the backend in the language we asked for,
    // so unlike every other string on this screen it does not follow a locale
    // change on its own: the rest of the card is compiled translations that
    // rebuild for free, and the explanation just sits there in the previous
    // language. Found in UAT on a physical device, 2026-08-27 — the whole
    // screen turned Portuguese and the paragraph stayed in Spanish, word for
    // word.
    //
    // `listen`, not `watch`: this must fire on the transition, not on every
    // rebuild. Changing language is rare, so the extra request is too.
    ref.listen(localeNotifierProvider, (prev, next) {
      if (prev?.languageCode != next.languageCode) _fetch();
    });

    // Same guard as the buy screen: the controller is shared, so a stale answer
    // for another symbol must never render here — it shows the loading frame
    // instead, which is true (a fresh assessment is on its way) and does not
    // leave a hole in the layout.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingL),
      child: ref.watch(fitScoreControllerProvider('detail')).when(
            data: (fit) {
              if (fit == null) return const SizedBox.shrink();
              if (fit.symbol != widget.symbol) {
                return const FitScoreCardLoading();
              }
              return FitScoreCard(fit: fit);
            },
            loading: () => const FitScoreCardLoading(),
            error: (_, __) => const FitScoreCardUnavailable(),
          ),
    );
  }
}
