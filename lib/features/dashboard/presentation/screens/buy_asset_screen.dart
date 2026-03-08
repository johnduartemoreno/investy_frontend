import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controllers/buy_asset_controller.dart';
import '../../domain/entities/asset.dart';

// ==========================================
// Thousands-Separator Input Formatter
// ==========================================

/// Mirrors ThousandsSeparatorInputFormatter from top_up_screen.dart.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _numberFormat = NumberFormat('#,##0.##', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final raw = newValue.text.replaceAll(',', '');
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(raw)) return oldValue;

    if (raw.contains('.')) {
      final parts = raw.split('.');
      final formattedInt = parts[0].isEmpty
          ? ''
          : _numberFormat.format(int.parse(parts[0]));
      final formatted = '$formattedInt.${parts[1]}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    final number = int.tryParse(raw);
    if (number == null) return oldValue;
    final formatted = _numberFormat.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static double? parseFormatted(String text) =>
      double.tryParse(text.replaceAll(',', ''));
}

class BuyAssetScreen extends ConsumerStatefulWidget {
  const BuyAssetScreen({super.key});

  @override
  ConsumerState<BuyAssetScreen> createState() => _BuyAssetScreenState();
}

class _BuyAssetScreenState extends ConsumerState<BuyAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  // Focus Nodes
  final _searchFocusNode = FocusNode();

  // Local State
  Asset? _selectedAsset;
  List<Asset> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Listen to search input changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    // If selected asset exists but query changed, clear selection unless it matches
    if (_selectedAsset != null && query != _selectedAsset!.symbol) {
      setState(() {
        _selectedAsset = null;
        _priceController.clear();
      });
    }

    // Only search if we have a query and NO asset is selected
    if (query.isNotEmpty && _selectedAsset == null) {
      setState(() => _isSearching = true);

      // Debounce could be added here, but direct call for now
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

  void _selectAsset(Asset asset) {
    setState(() {
      _selectedAsset = asset;
      _searchController.text = asset.symbol;
      _priceController.text = asset.currentPrice.toString();
      _searchResults = []; // Hide list
    });

    // CRITICAL: Unfocus to dismiss keyboard
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedAsset = null;
      _priceController.clear();
      _searchResults = [];
    });
    // Optional: Request focus again if user wants to type immediately
    // _searchFocusNode.requestFocus();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAsset == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a valid asset from the list')),
        );
        return;
      }

      final quantity = double.parse(_quantityController.text.trim());
      final price = ThousandsSeparatorInputFormatter.parseFormatted(_priceController.text.trim()) ?? 0;

      ref.read(buyAssetControllerProvider.notifier).buyAsset(
            symbol: _selectedAsset!.symbol,
            quantity: quantity,
            price: price,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for submission state (loading/error/success)
    ref.listen(buyAssetControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      } else if (next is AsyncData) {
        if (next.isLoading) return;

        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      }
    });

    final state = ref.watch(buyAssetControllerProvider);
    final isSubmitting = state.isLoading;

    final showResults =
        _searchController.text.isNotEmpty && _selectedAsset == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Asset'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SEARCH FIELD ---
                TextFormField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Search Asset',
                    hintText: 'e.g. AAPL',
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : const Icon(Icons.search),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please search and select an asset';
                    }
                    return null;
                  },
                ),

                // --- RESULTS LIST (Overlay-like behavior in Column) ---
                if (showResults)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _searchResults.isEmpty && _isSearching
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ))
                        : _searchResults.isEmpty
                            ? const Center(
                                child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No assets found'),
                              ))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final asset = _searchResults[index];
                                  return ListTile(
                                    title: Text(asset.symbol),
                                    subtitle: Text(asset.name),
                                    trailing: Text('\$${asset.currentPrice}'),
                                    onTap: () => _selectAsset(asset),
                                  );
                                },
                              ),
                  ),

                // --- FORM FIELDS (Only show if asset selected or consistent with requirements) ---
                // Showing them always but disabled or just below search feel okay.
                // To keep layout stable, we show them.
                const SizedBox(height: 16),

                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  enabled:
                      _selectedAsset != null, // Enable only if asset selected
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter quantity';
                    }
                    final qty = double.tryParse(value);
                    if (qty == null || qty <= 0) {
                      return 'Must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price per Share',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    helperText: 'Auto-filled from market data',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(),
                  ],
                  enabled: _selectedAsset != null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    final price = ThousandsSeparatorInputFormatter.parseFormatted(value);
                    if (price == null || price <= 0) {
                      return 'Must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      (isSubmitting || _selectedAsset == null) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Confirm Purchase',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
