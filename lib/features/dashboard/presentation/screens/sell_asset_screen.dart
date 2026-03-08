import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/holding.dart';
import '../controllers/sell_asset_controller.dart';
import '../screens/dashboard_screen.dart'; // for holdingsStreamProvider

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

// ═══════════════════════════════════════════════════════════════════
// SELL ASSET SCREEN — Full-screen vertical list of owned holdings
// ═══════════════════════════════════════════════════════════════════

class SellAssetScreen extends ConsumerWidget {
  const SellAssetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final holdingsAsync = ref.watch(holdingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sell Asset')),
      body: SafeArea(
        child: holdingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
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
          data: (holdings) {
            if (holdings.isEmpty) {
              return _buildEmptyState(context, theme, colors);
            }
            return _buildHoldingsList(
              context,
              theme,
              colors,
              holdings,
            );
          },
        ),
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────

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
              "You don't own any assets yet",
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Buy your first asset to start building your portfolio.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/home/buy-asset'),
              icon: const Icon(Icons.trending_up),
              label: const Text('Buy Your First Asset'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Full-Screen Vertical List ─────────────────────────────────

  Widget _buildHoldingsList(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    List<Holding> holdings,
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

  // ─── Bottom Sheet Trigger ──────────────────────────────────────

  void _showSellSheet(BuildContext context, Holding holding) {
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
// HOLDING LIST TILE — Vertical row for each owned asset
// ═══════════════════════════════════════════════════════════════════

class _HoldingListTile extends StatelessWidget {
  final Holding holding;
  final VoidCallback onTap;

  const _HoldingListTile({
    required this.holding,
    required this.onTap,
  });

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
              // Leading icon
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  _assetIcon(holding.assetClass),
                  size: 20,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 14),

              // Ticker + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.symbol.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${holding.quantity} shares · Avg \$${holding.avgCost.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing — total position value
              Text(
                CurrencyFormatter.format(holding.costBasis),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SELL BOTTOM SHEET — Scoped form for selling the selected asset
// ═══════════════════════════════════════════════════════════════════

class _SellBottomSheet extends ConsumerStatefulWidget {
  final Holding holding;

  const _SellBottomSheet({required this.holding});

  @override
  ConsumerState<_SellBottomSheet> createState() => _SellBottomSheetState();
}

class _SellBottomSheetState extends ConsumerState<_SellBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  int? _activeChipIndex;

  Holding get _holding => widget.holding;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onInputChanged);
    _priceController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onInputChanged);
    _priceController.removeListener(_onInputChanged);
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  double get _estimatedValue {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = ThousandsSeparatorInputFormatter.parseFormatted(_priceController.text) ?? 0;
    return qty * price;
  }

  void _onChipTapped(int index) {
    final percentages = [0.25, 0.50, 1.0];
    final qty = _holding.quantity * percentages[index];
    final rounded = double.parse(qty.toStringAsFixed(6));

    setState(() {
      _activeChipIndex = index;
      _quantityController.text = rounded == rounded.roundToDouble()
          ? rounded.toInt().toString()
          : rounded.toString();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text.trim());
    final price = ThousandsSeparatorInputFormatter.parseFormatted(_priceController.text.trim()) ?? 0;

    ref.read(sellAssetControllerProvider.notifier).sellAsset(
          symbol: _holding.symbol,
          currentPrice: price,
          quantity: quantity,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currencyFmt = CurrencyFormatter.instance;

    // Listen for submission state changes
    ref.listen(sellAssetControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: colors.error,
          ),
        );
      } else if (next is AsyncData && !next.isLoading) {
        // Success — pop the bottom sheet
        Navigator.of(context).pop();

        // Show success snackbar & navigate back to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sale completed successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );

        // Pop the sell screen back to dashboard
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    });

    final controllerState = ref.watch(sellAssetControllerProvider);
    final isSubmitting = controllerState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_holding.quantity} shares owned',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Quantity Input ──
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Sell',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quantity';
                  }
                  final qty = double.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Must be a positive number';
                  }
                  if (qty > _holding.quantity) {
                    return 'You only own ${_holding.quantity} shares';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 20),

              // ── Sell Price Input ──
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Sell Price per Share',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  helperText: 'Enter the execution price for this sale',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  ThousandsSeparatorInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the sell price';
                  }
                  final price = ThousandsSeparatorInputFormatter.parseFormatted(value);
                  if (price == null || price <= 0) {
                    return 'Must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Estimated Value ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Value',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      currencyFmt.format(_estimatedValue),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _estimatedValue > 0
                            ? Colors.green.shade700
                            : colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Confirm Sale Button ──
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Sale',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
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
}
