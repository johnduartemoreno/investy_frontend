import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/data/repositories/dashboard_repository_impl.dart';

// ==========================================
// Thousands-Separator Input Formatter
// ==========================================

/// A [TextInputFormatter] that adds thousands separators in real-time.
///
/// As the user types "258855" the field displays "258,855".
/// Supports up to 2 decimal places. The raw numeric value can be
/// extracted via [parseFormatted].
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _numberFormat = NumberFormat('#,##0.##', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty field
    if (newValue.text.isEmpty) return newValue;

    final raw = newValue.text.replaceAll(',', '');

    // Validate: only digits and at most one dot with up to 2 decimal places
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(raw)) {
      return oldValue;
    }

    // If the user is typing after a decimal point, preserve trailing zeros/dot
    if (raw.contains('.')) {
      final parts = raw.split('.');
      final integerPart = parts[0];
      final decimalPart = parts[1];

      // Format only the integer portion
      final formattedInt = integerPart.isEmpty
          ? ''
          : _numberFormat.format(int.parse(integerPart));
      final formatted = '$formattedInt.$decimalPart';

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Integer-only: format with commas
    final number = int.tryParse(raw);
    if (number == null) return oldValue;

    final formatted = _numberFormat.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Strips commas from a formatted string and parses to [double].
  /// Returns `null` if the string is not a valid number.
  static double? parseFormatted(String text) {
    final raw = text.replaceAll(',', '');
    return double.tryParse(raw);
  }
}

// ==========================================
// Form State Provider
// ==========================================

/// State for the top-up form submission
enum TopUpStatus { initial, loading, success, error }

class TopUpState {
  final double? amount;
  final TopUpStatus status;
  final String? errorMessage;

  const TopUpState({
    this.amount,
    this.status = TopUpStatus.initial,
    this.errorMessage,
  });

  TopUpState copyWith({
    double? amount,
    TopUpStatus? status,
    String? errorMessage,
  }) {
    return TopUpState(
      amount: amount ?? this.amount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TopUpNotifier extends StateNotifier<TopUpState> {
  final Ref _ref;

  TopUpNotifier(this._ref) : super(const TopUpState());

  void setAmount(double? amount) {
    state = state.copyWith(amount: amount, status: TopUpStatus.initial);
  }

  Future<bool> submit() async {
    if (state.amount == null || state.amount! <= 0) {
      state = state.copyWith(
        status: TopUpStatus.error,
        errorMessage: 'Please enter a valid amount',
      );
      return false;
    }

    state = state.copyWith(status: TopUpStatus.loading);

    try {
      final repository = _ref.read(dashboardRepositoryProvider);
      await repository.addContribution(
        amount: state.amount!,
        type: 'deposit',
        date: DateTime.now(),
      );
      state = state.copyWith(status: TopUpStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: TopUpStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const TopUpState();
  }
}

final topUpProvider =
    StateNotifierProvider.autoDispose<TopUpNotifier, TopUpState>(
  (ref) => TopUpNotifier(ref),
);

// ==========================================
// Top Up Screen
// ==========================================

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(double value) {
    setState(() {
      _amount = value;
      final formatter = NumberFormat('#,##0.##', 'en_US');
      _amountController.text = formatter.format(value);
    });
    ref.read(topUpProvider.notifier).setAmount(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(topUpProvider.notifier).submit();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Successfully deposited ${CurrencyFormatter.format(_amount)}'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topUpState = ref.watch(topUpProvider);

    // Listen for errors
    ref.listen<TopUpState>(topUpProvider, (previous, next) {
      if (next.status == TopUpStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // ── Section Label ──
                Text(
                  'Enter Amount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // ── Large Currency Input ──
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    hintText: '0',
                    border: InputBorder.none,
                    hintStyle: theme.textTheme.displayMedium?.copyWith(
                      color: colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(),
                  ],
                  onChanged: (value) {
                    final parsed =
                        ThousandsSeparatorInputFormatter.parseFormatted(value);
                    setState(() => _amount = parsed ?? 0.0);
                    ref.read(topUpProvider.notifier).setAmount(parsed);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final parsed =
                        ThousandsSeparatorInputFormatter.parseFormatted(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── Quick-Select Amount Chips ──
                Row(
                  children: [
                    _QuickAmountChip(
                      label: '\$100',
                      onTap: () => _setAmount(100),
                    ),
                    const SizedBox(width: 8),
                    _QuickAmountChip(
                      label: '\$500',
                      onTap: () => _setAmount(500),
                    ),
                    const SizedBox(width: 8),
                    _QuickAmountChip(
                      label: '\$1,000',
                      onTap: () => _setAmount(1000),
                    ),
                    const SizedBox(width: 8),
                    _QuickAmountChip(
                      label: '\$5,000',
                      onTap: () => _setAmount(5000),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Funding Source (Mock) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.account_balance,
                            color: colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chase Checking',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '...8899',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Confirm Button ──
                FilledButton(
                  onPressed:
                      (_amount > 0 && topUpState.status != TopUpStatus.loading)
                          ? _submit
                          : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: topUpState.status == TopUpStatus.loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Confirm Deposit',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Quick Amount Chip
// ==========================================

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
