import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../data/models/asset_search_result_model.dart';
import '../controllers/buy_asset_controller.dart';

class BuyAssetScreen extends ConsumerStatefulWidget {
  const BuyAssetScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
        if (mounted) setState(() {
          _searchResults = results;
          _isSearching = false;
        });
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
        );
  }

  double get _estimatedTotal =>
      _quantity * (_selectedAsset?.currentPrice ?? 0.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    ref.listen(buyAssetControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      } else if (next is AsyncData && !next.isLoading) {
        if (context.canPop()) context.pop();
        else context.go('/home');
      }
    });

    final isSubmitting = ref.watch(buyAssetControllerProvider).isLoading;
    final showResults =
        _searchController.text.isNotEmpty && _selectedAsset == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Buy Asset')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search field
                TextFormField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Search asset (e.g. AAPL)',
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
                      _selectedAsset == null ? 'Select an asset' : null,
                ),

                // Search results
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
                                child: Text('No assets found',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant)),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (_, i) {
                                  final a = _searchResults[i];
                                  return ListTile(
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

                // Selected asset info
                if (_selectedAsset != null) ...[
                  const SizedBox(height: AppDimens.spacingL),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.spacingL),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedAsset!.symbol,
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(_selectedAsset!.name,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(
                                  _selectedAsset!.currentPrice),
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('per share',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimens.spacingL),

                // Quantity input
                Text('Quantity',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: cs.onSurfaceVariant)),
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
                    if (v == null || v.isEmpty) return 'Enter quantity';
                    final qty =
                        ThousandsSeparatorInputFormatter.parseFormatted(v);
                    if (qty == null || qty <= 0) return 'Must be greater than zero';
                    return null;
                  },
                ),

                // Estimated total
                if (_selectedAsset != null && _quantity > 0) ...[
                  const SizedBox(height: AppDimens.spacingL),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.spacingL),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated Total',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(
                          CurrencyFormatter.format(_estimatedTotal),
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimens.spacingXL),

                PrimaryButton(
                  text: 'Confirm Purchase',
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
