import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../broker/presentation/widgets/broker_gate_banner.dart';
import '../../../kyc/presentation/widgets/kyc_gate_banner.dart';
import '../../data/models/asset_search_result_model.dart';
import '../../data/models/buy_asset_args.dart';
import '../controllers/buy_asset_controller.dart';
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
  List<AssetSearchResultModel> _searchResults = [];
  bool _isSearching = false;
  double _quantity = 0.0;
  String? _selectedGoalId; // optional goal assignment (S18)

  static const _tickerColors = {
    'AAPL': [Color(0xFF1d4ed8), Color(0xFF3b82f6)],
    'VTI':  [Color(0xFF065f46), Color(0xFF10b981)],
    'BTC':  [Color(0xFF78350f), Color(0xFFf59e0b)],
    'MSFT': [Color(0xFF4c1d95), Color(0xFF8b5cf6)],
    'IAU':  [Color(0xFF881337), Color(0xFFf43f5e)],
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _selectedGoalId = widget.args?.goalId; // pre-assign goal when coming from goal detail

    final preselect = widget.args?.symbol;
    if (preselect != null && preselect.isNotEmpty) {
      _searchController.text = preselect;
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoSelect(preselect));
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

  List<Color> _colorsForTicker(String ticker) {
    return _tickerColors[ticker] ??
        [AppTheme.brandPurple, AppTheme.brandPurpleLight];
  }

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
  Widget _buildGoalSelector(ThemeData theme, ColorScheme cs, AppLocalizations l10n) {
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
                      onSelected: (_) =>
                          setState(() => _selectedGoalId = g.id),
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

    ref.listen(buyAssetControllerProvider, (_, next) {
      if (next is AsyncError) {
        final err = next.error;
        final isInsufficientFunds = err is DioException &&
            err.response?.data is Map &&
            (err.response?.data as Map)['code'] == 'ERR_INSUFFICIENT_FUNDS';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isInsufficientFunds
                ? l10n.buyInsufficientFunds
                : l10n.commonError),
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
          style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white, fontWeight: FontWeight.w700),
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
                      borderRadius: BorderRadius.circular(12),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator.adaptive()),
                          )
                        : _searchResults.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(l10n.assetSearchEmpty,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant)),
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800),
                              ),
                              Text(
                                _selectedAsset!.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant),
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant),
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
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
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
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        onChanged: (v) {
                          final parsed =
                              ThousandsSeparatorInputFormatter.parseFormatted(v);
                          setState(() => _quantity = parsed ?? 0.0);
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.buyEnterQuantity;
                          final qty =
                              ThousandsSeparatorInputFormatter.parseFormatted(v);
                          if (qty == null || qty <= 0) return l10n.buyQuantityPositive;
                          return null;
                        },
                      ),
                      if (_selectedAsset != null && _quantity > 0) ...[
                        const Divider(height: AppDimens.spacingXL),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.buyEstimatedTotal,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            Text(
                              CurrencyFormatter.format(_estimatedTotal),
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.brandPurpleLight),
                            ),
                          ],
                        ),
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
