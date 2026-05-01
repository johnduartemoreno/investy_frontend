import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../features/portfolio/data/models/portfolio_response_model.dart';
import '../../../../features/portfolio/presentation/providers/rest_portfolio_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../broker/presentation/widgets/broker_gate_banner.dart';
import '../../../kyc/presentation/widgets/kyc_gate_banner.dart';
import '../controllers/sell_asset_controller.dart';

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
                style: theme.textTheme.bodyLarge?.copyWith(color: colors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (portfolio) {
            if (portfolio.holdings.isEmpty) {
              return _buildEmptyState(context, theme, colors);
            }
            return _buildHoldingsList(context, portfolio.holdings);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SellBottomSheet(holding: holding),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HOLDING LIST TILE
// ═══════════════════════════════════════════════════════════════════

class _HoldingListTile extends StatelessWidget {
  final PortfolioHoldingModel holding;
  final VoidCallback onTap;

  const _HoldingListTile({required this.holding, required this.onTap});

  IconData _assetIcon(String assetClass) {
    switch (assetClass.toLowerCase()) {
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'etf':
        return Icons.pie_chart_outline;
      case 'bond':
        return Icons.account_balance;
      default:
        return Icons.show_chart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  _assetIcon(holding.assetClass),
                  size: 20,
                  color: colors.primary,
                ),
              ),
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
                      '${holding.quantity} ${AppLocalizations.of(context).portfolioShares} · Avg ${CurrencyFormatter.format(holding.avgCost)}',
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
                    CurrencyFormatter.format(holding.marketValue),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${holding.returnPct >= 0 ? '+' : ''}${holding.returnPct.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: holding.returnPct >= 0
                          ? colors.tertiary
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
  double _quantity = 0.0;
  double _pricePerUnit = 0.0;

  PortfolioHoldingModel get _holding => widget.holding;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current market price
    _pricePerUnit = _holding.currentPrice;
    _priceController.text = _holding.currentPrice.toStringAsFixed(2);
    _priceController.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    final parsed =
        ThousandsSeparatorInputFormatter.parseFormatted(_priceController.text);
    setState(() => _pricePerUnit = parsed ?? 0.0);
  }

  double get _estimatedValue => _quantity * _pricePerUnit;

  void _onChipTapped(int index) {
    final percentages = [0.25, 0.50, 1.0];
    final qty = _holding.quantity * percentages[index];
    final rounded = double.parse(qty.toStringAsFixed(6));
    final text = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toString();

    setState(() {
      _activeChipIndex = index;
      _quantity = rounded;
      _quantityController.text = text;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(sellAssetControllerProvider.notifier).sellAsset(
          symbol: _holding.symbol,
          quantity: _quantity,
          pricePerUnit: _pricePerUnit,
        );
  }

  IconData _assetIcon(String assetClass) {
    switch (assetClass.toLowerCase()) {
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'etf':
        return Icons.pie_chart_outline;
      case 'bond':
        return Icons.account_balance;
      default:
        return Icons.show_chart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    ref.listen(sellAssetControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: colors.error,
          ),
        );
      } else if (next is AsyncData && !next.isLoading) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).sellSuccess),
            backgroundColor: colors.tertiary,
          ),
        );
        if (context.canPop()) context.pop();
        else context.go('/home');
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
                  CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      _assetIcon(_holding.assetClass),
                      size: 20,
                      color: colors.primary,
                    ),
                  ),
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
                        AppLocalizations.of(context).sellSharesOwned(_holding.quantity.toString()),
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
                  hintStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.outline.withValues(alpha: 0.4)),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                onChanged: (v) {
                  final parsed =
                      ThousandsSeparatorInputFormatter.parseFormatted(v);
                  setState(() => _quantity = parsed ?? 0.0);
                },
                validator: (v) {
                  final l10n = AppLocalizations.of(context);
                  if (v == null || v.isEmpty) return l10n.sellEnterQuantity;
                  final qty =
                      ThousandsSeparatorInputFormatter.parseFormatted(v);
                  if (qty == null || qty <= 0) return l10n.sellQuantityPositive;
                  if (qty > _holding.quantity) {
                    return l10n.sellQuantityExceeds(_holding.quantity.toString());
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
                            color: isActive
                                ? colors.onPrimary
                                : colors.primary,
                          ),
                        ),
                        backgroundColor: isActive
                            ? colors.primary
                            : colors.primaryContainer
                                .withValues(alpha: 0.4),
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
                  hintStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.outline.withValues(alpha: 0.4)),
                  prefixText: '\$ ',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                  helperText: AppLocalizations.of(context).sellPricePerShare,
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (v) {
                  final l10n = AppLocalizations.of(context);
                  if (v == null || v.trim().isEmpty) return l10n.sellEnterPrice;
                  final price =
                      ThousandsSeparatorInputFormatter.parseFormatted(v);
                  if (price == null || price <= 0) return l10n.sellQuantityPositive;
                  return null;
                },
              ),
              const SizedBox(height: AppDimens.spacingL),

              // ── Estimated Value ──
              if (_quantity > 0 && _pricePerUnit > 0) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.spacingL),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).sellEstimatedValue,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      Text(
                        CurrencyFormatter.format(_estimatedValue),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spacingL),
              ],

              // ── Confirm Sale Button ──
              PrimaryButton(
                text: AppLocalizations.of(context).sellConfirm,
                isLoading: isSubmitting,
                onPressed: (_quantity > 0 && _pricePerUnit > 0)
                    ? _submit
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
