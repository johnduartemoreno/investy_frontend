import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/asset_gradients.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity_input_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../broker/presentation/widgets/broker_gate_banner.dart';
import '../../../kyc/presentation/widgets/kyc_gate_banner.dart';
import '../../data/models/asset_search_result_model.dart';
import '../../data/models/buy_asset_args.dart';
import '../controllers/buy_asset_controller.dart';
import '../controllers/trading_quote_controller.dart';
import '../trading_error_localizer.dart';
import '../widgets/order_cost_breakdown.dart';
import '../../../goals/presentation/providers/rest_goals_provider.dart';

class BuyAssetScreen extends ConsumerStatefulWidget {
  final BuyAssetArgs? args;

  const BuyAssetScreen({super.key, this.args});

  @override
  ConsumerState<BuyAssetScreen> createState() => _BuyAssetScreenState();
}

class _BuyAssetScreenState extends ConsumerState<BuyAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();

  AssetSearchResultModel? _selectedAsset;
  Timer? _quoteDebounce;
  List<AssetSearchResultModel> _searchResults = [];
  bool _isSearching = false;
  double _quantity = 0.0;
  String? _selectedGoalId; // optional goal assignment (S18)

  /// Server order floor in dollars, refreshed from build(). Cached because the
  /// validator is a callback: ref.watch is only legal inside build.
  /// Null until /trading/config answers — then the pre-check simply sits out and
  /// the server does the rejecting, which it does anyway.
  double? _minBuyNotional;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _selectedGoalId =
        widget.args?.goalId; // pre-assign goal when coming from goal detail

    final preselect = widget.args?.symbol;
    if (preselect != null && preselect.isNotEmpty) {
      _searchController.text = preselect;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _autoSelect(preselect));
    }
  }

  Future<void> _autoSelect(String symbol) async {
    setState(() => _isSearching = true);
    final results = await ref
        .read(buyAssetControllerProvider.notifier)
        .searchAssets(symbol);
    if (!mounted) return;
    if (results.isNotEmpty) {
      _selectAsset(results.first);
    } else {
      setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _quoteDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (_selectedAsset != null && query != _selectedAsset!.symbol) {
      setState(() {
        _selectedAsset = null;
        _quantity = 0.0;
      });
    }

    if (query.isNotEmpty && _selectedAsset == null) {
      setState(() => _isSearching = true);
      ref
          .read(buyAssetControllerProvider.notifier)
          .searchAssets(query)
          .then((results) {
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      });
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectAsset(AssetSearchResultModel asset) {
    setState(() {
      _selectedAsset = asset;
      _searchController.text = asset.symbol;
      _searchResults = [];
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();
    // The asset changed, so the fee may have too (rules can key off asset class).
    _refreshQuote();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAsset == null) return;

    ref.read(buyAssetControllerProvider.notifier).buyAsset(
          symbol: _selectedAsset!.symbol,
          quantity: _quantity,
          pricePerUnit: _selectedAsset!.currentPrice,
          goalId: _selectedGoalId,
        );
  }

  double get _estimatedTotal =>
      _quantity * (_selectedAsset?.currentPrice ?? 0.0);

  bool get _isCrypto => _selectedAsset?.assetClass == 'crypto';

  /// True once the order is big enough to be worth pricing. Below the floor the
  /// server will refuse it, so quoting it — and drawing a tidy cost breakdown for
  /// it — would just be theatre.
  bool get _meetsMinimum {
    final minDollars = _minBuyNotional;
    // Config not in yet: block nothing and let the server answer.
    if (minDollars == null) return true;
    return (_estimatedTotal * 100).round() >= (minDollars * 100).round();
  }

  /// Debounced so a quote is requested when the user pauses, not per keystroke.
  void _refreshQuote() {
    _quoteDebounce?.cancel();
    final asset = _selectedAsset;
    if (asset == null || _quantity <= 0 || !_meetsMinimum) {
      ref.read(tradingQuoteControllerProvider.notifier).clear();
      return;
    }
    _quoteDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      ref.read(tradingQuoteControllerProvider.notifier).fetch(
            symbol: asset.symbol,
            side: 'buy',
            quantity: _quantity,
            priceCents: (asset.currentPrice * 100).round(),
          );
    });
  }

  /// The cost section. While a quote is in flight or failed we show the subtotal
  /// only — never a total that omits fees, which would understate the cost.
  Widget _buildCostSection(
      ThemeData theme, ColorScheme cs, AppLocalizations l10n) {
    final quoteAsync = ref.watch(tradingQuoteControllerProvider);

    return quoteAsync.when(
      data: (quote) {
        if (quote == null) return _subtotalOnlyRow(theme, cs, l10n);
        return OrderCostBreakdown(quote: quote, isBuy: true);
      },
      loading: () => _subtotalOnlyRow(theme, cs, l10n, showSpinner: true),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _subtotalOnlyRow(theme, cs, l10n),
          const SizedBox(height: AppDimens.spacingS),
          Text(
            l10n.tradingQuoteUnavailable,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
          ),
        ],
      ),
    );
  }

  Widget _subtotalOnlyRow(
      ThemeData theme, ColorScheme cs, AppLocalizations l10n,
      {bool showSpinner = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.tradingSubtotal,
          style:
              theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
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
              CurrencyFormatter.format(_estimatedTotal),
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandPurpleLight),
            ),
          ],
        ),
      ],
    );
  }

  List<Color> _colorsForTicker(String ticker) => AssetGradients.ticker(ticker);

  Widget _assetIcon(String ticker) {
    final label = ticker.length > 4 ? ticker.substring(0, 4) : ticker;
    return GradientIconBox(
      colors: _colorsForTicker(ticker),
      size: 44,
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  /// Optional goal selector (S18). Lets the user assign this BUY to a goal.
  /// "No goal" is always available and selected by default.
  Widget _buildGoalSelector(
      ThemeData theme, ColorScheme cs, AppLocalizations l10n) {
    final goalsAsync = ref.watch(restGoalsProvider);
    return goalsAsync.maybeWhen(
      data: (goals) {
        if (goals.isEmpty) return const SizedBox.shrink();
        return CustomCard(
          padding: const EdgeInsets.all(AppDimens.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.buyAssignGoalLabel,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppDimens.spacingM),
              Wrap(
                spacing: AppDimens.spacingS,
                runSpacing: AppDimens.spacingS,
                children: [
                  ChoiceChip(
                    label: Text(l10n.buyNoGoalOption),
                    selected: _selectedGoalId == null,
                    onSelected: (_) => setState(() => _selectedGoalId = null),
                  ),
                  for (final g in goals)
                    ChoiceChip(
                      label: Text(g.name),
                      selected: _selectedGoalId == g.id,
                      onSelected: (_) => setState(() => _selectedGoalId = g.id),
                    ),
                ],
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final minCentsAsync = ref.watch(tradingConfigProvider).valueOrNull;
    _minBuyNotional = minCentsAsync == null
        ? null
        : minCentsAsync.minBuyNotionalCents / 100.0;

    ref.listen(buyAssetControllerProvider, (_, next) {
      if (next is AsyncError) {
        // The backend speaks error codes; the copy lives here. Falling back to the
        // real floor from /trading/config keeps the message honest if the server
        // ever moves it (a $1 minimum is policy, not a constant).
        final minCents =
            ref.read(tradingConfigProvider).valueOrNull?.minBuyNotionalCents ??
                100;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizeTradingError(l10n, next.error,
                minBuyNotionalCents: minCents)),
          ),
        );
      } else if (next is AsyncData && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.buySuccess),
            duration: const Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!context.mounted) return;
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        });
      }
    });

    final isSubmitting = ref.watch(buyAssetControllerProvider).isLoading;
    final showResults =
        _searchController.text.isNotEmpty && _selectedAsset == null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.buyAssetTitle,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimens.spacingS),
                const KycGateBanner(),
                const BrokerGateBanner(),

                // ── Search field ──────────────────────────────────────────
                TextFormField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: l10n.assetSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _selectedAsset = null;
                                _searchResults = [];
                                _quantity = 0.0;
                              });
                            },
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusInput),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (_) =>
                      _selectedAsset == null ? l10n.buySelectAsset : null,
                ),

                // ── Search results ────────────────────────────────────────
                if (showResults) ...[
                  const SizedBox(height: AppDimens.spacingS),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusInput),
                    ),
                    child: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(AppDimens.spacingL),
                            child: Center(
                                child: CircularProgressIndicator.adaptive()),
                          )
                        : _searchResults.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.all(AppDimens.spacingL),
                                child: Text(l10n.assetSearchEmpty,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: cs.onSurfaceVariant)),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (_, i) {
                                  final a = _searchResults[i];
                                  return ListTile(
                                    leading: _assetIcon(a.symbol),
                                    title: Text(a.symbol,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                    subtitle: Text(a.name,
                                        style: theme.textTheme.bodySmall),
                                    trailing: Text(
                                      CurrencyFormatter.format(a.currentPrice),
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(color: cs.primary),
                                    ),
                                    onTap: () => _selectAsset(a),
                                  );
                                },
                              ),
                  ),
                ],

                // ── Auto-selecting spinner ────────────────────────────────
                if (_isSearching && _selectedAsset == null && !showResults) ...[
                  const SizedBox(height: AppDimens.spacingL),
                  const Center(child: CircularProgressIndicator.adaptive()),
                ],

                // ── Selected asset card ───────────────────────────────────
                if (_selectedAsset != null) ...[
                  const SizedBox(height: AppDimens.spacingL),
                  CustomCard(
                    child: Row(
                      children: [
                        _assetIcon(_selectedAsset!.symbol),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAsset!.symbol,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                _selectedAsset!.name,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(
                                  _selectedAsset!.currentPrice),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.brandPurpleLight),
                            ),
                            Text(
                              l10n.buyPerShare,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Signal badge — only when navigated from a rec card
                  if (widget.args?.signalLabel != null) ...[
                    const SizedBox(height: AppDimens.spacingS),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SignalBadge(
                        label: widget.args!.signalLabel!,
                        color: widget.args!.signalColor ?? AppTheme.signalGreen,
                      ),
                    ),
                  ],
                ],

                // ── Quantity + summary card ───────────────────────────────
                const SizedBox(height: AppDimens.spacingL),
                CustomCard(
                  padding: const EdgeInsets.all(AppDimens.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.buyQuantityLabel,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppDimens.spacingS),
                      TextFormField(
                        controller: _quantityController,
                        enabled: _selectedAsset != null,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: theme.textTheme.headlineMedium?.copyWith(
                              color: cs.outline.withValues(alpha: 0.4)),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusInput),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        // A quantity is not money: 2 decimals is the wrong cap for an
                        // asset — it made 0.001 BTC untypeable.
                        inputFormatters: [
                          QuantityInputFormatter(isCrypto: _isCrypto),
                        ],
                        onChanged: (v) {
                          final parsed =
                              QuantityInputFormatter.parseFormatted(v);
                          setState(() => _quantity = parsed ?? 0.0);
                          _refreshQuote();
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.buyEnterQuantity;
                          }
                          final qty = QuantityInputFormatter.parseFormatted(v);
                          if (qty == null || qty <= 0) {
                            return l10n.buyQuantityPositive;
                          }
                          // Mirror of the server floor, for instant feedback as the
                          // user types — the alternative is drawing a full cost
                          // breakdown and an enabled button for an order that is
                          // certain to be rejected. NOT the authority: the server
                          // re-checks every order and wins any disagreement.
                          //
                          // Compared in whole cents, rounded. The server floors the
                          // notional (integer division), so rounding here makes this
                          // check marginally LOOSER than the real one — deliberately.
                          // The failure directions are not symmetric: blocking an
                          // order the server would accept traps the user in a field
                          // error they cannot clear, while letting a borderline one
                          // through just earns a snackbar from the authority.
                          final minDollars = _minBuyNotional;
                          if (minDollars != null &&
                              _selectedAsset != null &&
                              (_estimatedTotal * 100).round() <
                                  (minDollars * 100).round()) {
                            return l10n.tradingOrderTooSmall(
                                CurrencyFormatter.format(minDollars));
                          }
                          return null;
                        },
                      ),
                      // No breakdown for an order the server will refuse — the
                      // validator already says why.
                      if (_selectedAsset != null &&
                          _quantity > 0 &&
                          _meetsMinimum) ...[
                        const Divider(height: AppDimens.spacingXL),
                        _buildCostSection(theme, cs, l10n),
                      ],
                    ],
                  ),
                ),

                // ── Optional goal assignment (S18) ────────────────────────
                if (_selectedAsset != null) ...[
                  const SizedBox(height: AppDimens.spacingL),
                  _buildGoalSelector(theme, cs, l10n),
                ],

                const SizedBox(height: AppDimens.spacingXL),

                PrimaryButton(
                  text: l10n.buyConfirmButton,
                  isLoading: isSubmitting,
                  onPressed: (_selectedAsset != null && _quantity > 0)
                      ? _submit
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
