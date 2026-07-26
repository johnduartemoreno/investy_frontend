import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/asset_gradients.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/locale_number_input.dart';
import '../../../../core/utils/quantity_input_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../features/portfolio/data/models/portfolio_response_model.dart';
import '../../../../features/portfolio/presentation/providers/rest_portfolio_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../broker/presentation/widgets/broker_gate_banner.dart';
import '../../../kyc/presentation/widgets/kyc_gate_banner.dart';
import '../controllers/sell_asset_controller.dart';
import '../controllers/trading_quote_controller.dart';
import '../trading_error_localizer.dart';
import '../widgets/order_cost_breakdown.dart';
import 'dashboard_screen.dart';

// ═══════════════════════════════════════════════════════════════════
// SELL ASSET SCREEN — Full-screen vertical list of owned holdings
// ═══════════════════════════════════════════════════════════════════

class SellAssetScreen extends ConsumerWidget {
  const SellAssetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final portfolioAsync = ref.watch(restPortfolioProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).sellAssetTitle)),
      body: SafeArea(
        child: Column(
          children: [
            const KycGateBanner(),
            const BrokerGateBanner(),
            Expanded(
              child: portfolioAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error loading holdings: $error',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: colors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (portfolio) {
                  // B35: drop fully-liquidated positions. A holding at 0 shares is a
                  // row you cannot sell — the Portfolio screen has filtered these since
                  // S08.5 and this screen never caught up.
                  final sellable = portfolio.holdings
                      .where((h) => h.quantity > 0)
                      .toList(growable: false);
                  if (sellable.isEmpty) {
                    return _buildEmptyState(context, theme, colors);
                  }
                  return _buildHoldingsList(context, sellable);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).sellNoAssets,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).sellNoAssetsSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/home/buy-asset'),
              icon: const Icon(Icons.trending_up),
              label: Text(AppLocalizations.of(context).sellBuyFirstAsset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingsList(
    BuildContext context,
    List<PortfolioHoldingModel> holdings,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: holdings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final holding = holdings[index];
        return _HoldingListTile(
          holding: holding,
          onTap: () => _showSellSheet(context, holding),
        );
      },
    );
  }

  void _showSellSheet(BuildContext context, PortfolioHoldingModel holding) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusBottomSheet)),
      ),
      builder: (_) => _SellBottomSheet(holding: holding),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED — ticker gradient box (parity with portfolio_screen)
// ═══════════════════════════════════════════════════════════════════

/// Gradient ticker square matching the portfolio list — single visual
/// language for a holding everywhere (list tile + sell sheet header).
Widget _tickerBox(PortfolioHoldingModel holding) {
  final label = holding.symbol.length > 4
      ? holding.symbol.substring(0, 4)
      : holding.symbol;
  return GradientIconBox(
    colors: AssetGradients.assetClass(holding.assetClass),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// HOLDING LIST TILE
// ═══════════════════════════════════════════════════════════════════

class _HoldingListTile extends StatelessWidget {
  final PortfolioHoldingModel holding;
  final VoidCallback onTap;

  const _HoldingListTile({required this.holding, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _tickerBox(holding),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.symbol.toUpperCase(),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${holding.quantity} ${AppLocalizations.of(context).portfolioShares} · Avg ${CurrencyFormatter.formatUsd(holding.avgCost)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatUsd(holding.marketValue),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${holding.returnPct >= 0 ? '+' : ''}${holding.returnPct.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: holding.returnPct >= 0
                          ? AppTheme.signalGreen
                          : colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SELL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _SellBottomSheet extends ConsumerStatefulWidget {
  final PortfolioHoldingModel holding;

  const _SellBottomSheet({required this.holding});

  @override
  ConsumerState<_SellBottomSheet> createState() => _SellBottomSheetState();
}

class _SellBottomSheetState extends ConsumerState<_SellBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  int? _activeChipIndex;
  Timer? _quoteDebounce;
  double _quantity = 0.0;
  double _pricePerUnit = 0.0;

  PortfolioHoldingModel get _holding => widget.holding;

  bool get _isCrypto => _holding.assetClass == 'crypto';

  @override
  void initState() {
    super.initState();
    // Pre-fill with current market price. Locale-aware: a bare toStringAsFixed
    // would write a dot-decimal that a comma-decimal locale then re-parses as a
    // thousands separator (B51).
    _pricePerUnit = _holding.currentPrice;
    _priceController.text =
        LocaleNumberInput.forField(_holding.currentPrice, maxDecimals: 2);
    _priceController.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _quoteDebounce?.cancel();
    _priceController.removeListener(_onPriceChanged);
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    final parsed =
        ThousandsSeparatorInputFormatter.parseFormatted(_priceController.text);
    setState(() => _pricePerUnit = parsed ?? 0.0);
    _refreshQuote();
  }

  double get _estimatedValue => _quantity * _pricePerUnit;

  /// Debounced so a quote is requested when the user pauses, not per keystroke.
  void _refreshQuote() {
    _quoteDebounce?.cancel();
    if (_quantity <= 0 || _pricePerUnit <= 0) {
      ref.read(tradingQuoteControllerProvider.notifier).clear();
      return;
    }
    _quoteDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      ref.read(tradingQuoteControllerProvider.notifier).fetch(
            symbol: _holding.symbol,
            side: 'sell',
            quantity: _quantity,
            priceCents: (_pricePerUnit * 100).round(),
          );
    });
  }

  /// Proceeds section. Until a quote lands we show the gross value labelled as such —
  /// never a "you receive" number that quietly ignores the fees.
  Widget _buildProceeds(ThemeData theme, ColorScheme colors) {
    final l10n = AppLocalizations.of(context);
    final quoteAsync = ref.watch(tradingQuoteControllerProvider);

    final displayCurrency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;

    return quoteAsync.when(
      data: (quote) {
        if (quote == null) return _grossOnlyRow(theme, colors, l10n);
        return OrderCostBreakdown(
          quote: quote,
          isBuy: false,
          fxRate: fxRate,
          displayCurrency: displayCurrency,
        );
      },
      loading: () => _grossOnlyRow(theme, colors, l10n, showSpinner: true),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _grossOnlyRow(theme, colors, l10n),
          const SizedBox(height: AppDimens.spacingS),
          Text(
            l10n.tradingQuoteUnavailable,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
          ),
        ],
      ),
    );
  }

  Widget _grossOnlyRow(
      ThemeData theme, ColorScheme colors, AppLocalizations l10n,
      {bool showSpinner = false}) {
    final displayCurrency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;
    final equivalent = CurrencyFormatter.equivalentOf(
        _estimatedValue, fxRate, displayCurrency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.tradingSubtotal,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showSpinner) ...[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppDimens.spacingS),
                ],
                Text(
                  CurrencyFormatter.formatUsd(_estimatedValue),
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        if (equivalent != null)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.spacingXS),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                equivalent,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }

  void _onChipTapped(int index) {
    final percentages = [0.25, 0.50, 1.0];
    final qty = _holding.quantity * percentages[index];
    final rounded = double.parse(qty.toStringAsFixed(6));
    // Locale-aware field text so a comma-decimal locale doesn't re-parse the
    // fractional quantity as thousands (B51).
    final text = LocaleNumberInput.forField(rounded,
        maxDecimals: _isCrypto
            ? QuantityInputFormatter.cryptoDecimals
            : QuantityInputFormatter.defaultDecimals);

    setState(() {
      _activeChipIndex = index;
      _quantity = rounded;
      _quantityController.text = text;
    });
    _refreshQuote();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(sellAssetControllerProvider.notifier).sellAsset(
          symbol: _holding.symbol,
          quantity: _quantity,
          pricePerUnit: _pricePerUnit,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    ref.listen(sellAssetControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // isSell matters: ERR_ORDER_TOO_SMALL on a sell is not "under the $1
            // minimum" (sells have none) — it means the fees would swallow the
            // proceeds, which is a different thing to tell the user.
            content: Text(localizeTradingError(
                AppLocalizations.of(context), next.error,
                isSell: true)),
            backgroundColor: colors.error,
          ),
        );
      } else if (next is AsyncData && !next.isLoading) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).sellSuccess),
            backgroundColor: AppTheme.signalGreen,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    });

    final isSubmitting = ref.watch(sellAssetControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag Handle ──
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Asset Header ──
              Row(
                children: [
                  _tickerBox(_holding),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _holding.symbol.toUpperCase(),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .sellSharesOwned(_holding.quantity.toString()),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Quantity Input ──
              TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: theme.textTheme.headlineMedium
                      ?.copyWith(color: colors.outline.withValues(alpha: 0.4)),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                // A quantity is not money: 2 decimals is the wrong cap for an asset.
                inputFormatters: [
                  QuantityInputFormatter(isCrypto: _isCrypto),
                ],
                onChanged: (v) {
                  final parsed = QuantityInputFormatter.parseFormatted(v);
                  setState(() => _quantity = parsed ?? 0.0);
                  _refreshQuote();
                },
                validator: (v) {
                  final l10n = AppLocalizations.of(context);
                  if (v == null || v.isEmpty) return l10n.sellEnterQuantity;
                  final qty = QuantityInputFormatter.parseFormatted(v);
                  if (qty == null || qty <= 0) return l10n.sellQuantityPositive;
                  if (qty > _holding.quantity) {
                    return l10n
                        .sellQuantityExceeds(_holding.quantity.toString());
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimens.spacingS),

              // ── Quick-Action Chips ──
              Row(
                children: List.generate(3, (index) {
                  final labels = ['25%', '50%', 'MAX'];
                  final isActive = _activeChipIndex == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == 2 ? 0 : 4,
                      ),
                      child: ActionChip(
                        label: Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? colors.onPrimary : colors.primary,
                          ),
                        ),
                        backgroundColor: isActive
                            ? colors.primary
                            : colors.primaryContainer.withValues(alpha: 0.4),
                        side: BorderSide.none,
                        onPressed: () => _onChipTapped(index),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Sell Price Input ──
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: theme.textTheme.headlineMedium
                      ?.copyWith(color: colors.outline.withValues(alpha: 0.4)),
                  prefixText: '\$ ',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  helperText: AppLocalizations.of(context).sellPricePerShare,
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (v) {
                  final l10n = AppLocalizations.of(context);
                  if (v == null || v.trim().isEmpty) return l10n.sellEnterPrice;
                  final price =
                      ThousandsSeparatorInputFormatter.parseFormatted(v);
                  if (price == null || price <= 0) {
                    return l10n.sellQuantityPositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── What you actually walk away with ──
              // A sell's fees come OUT of the proceeds, so showing gross value alone
              // overstates what lands in the wallet. The quote is authoritative.
              if (_quantity > 0 && _pricePerUnit > 0) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.spacingL),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                  ),
                  child: _buildProceeds(theme, colors),
                ),
                const SizedBox(height: AppDimens.spacingL),
              ],

              // ── Confirm Sale Button ──
              PrimaryButton(
                text: AppLocalizations.of(context).sellConfirm,
                isLoading: isSubmitting,
                onPressed:
                    (_quantity > 0 && _pricePerUnit > 0) ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
