import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/locale_number_input.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/top_up_controller.dart';

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
      // Locale-aware field text (B51): a static en_US format would write a
      // dot-decimal that a comma-decimal locale re-parses as thousands.
      _amountController.text =
          LocaleNumberInput.forField(value, maxDecimals: 2);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(topUpControllerProvider.notifier).deposit(_amount);

    if (!mounted) return;
    if (ref.read(topUpControllerProvider) is AsyncData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).topUpSuccess),
          backgroundColor: AppTheme.signalGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topUpAsync = ref.watch(topUpControllerProvider);
    final displayCurrency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;
    final showEquivalent = displayCurrency != 'USD' && _amount > 0;

    // Listen for errors
    ref.listen(topUpControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).topUpTitle),
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
                  AppLocalizations.of(context).topUpEnterAmount,
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
                    prefixText: 'USD \$ ',
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
                  },
                  validator: (value) {
                    final l10n = AppLocalizations.of(context);
                    if (value == null || value.isEmpty) {
                      return l10n.topUpAmountRequired;
                    }
                    final parsed =
                        ThousandsSeparatorInputFormatter.parseFormatted(value);
                    if (parsed == null || parsed <= 0) {
                      return l10n.topUpAmountInvalid;
                    }
                    return null;
                  },
                ),
                if (showEquivalent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '≈ ${CurrencyFormatter.formatWithCurrency(_amount * fxRate, displayCurrency)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                  padding: const EdgeInsets.all(AppDimens.spacingL),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppDimens.radiusInput),
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
                      Icon(Icons.chevron_right,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Confirm Button ──
                PrimaryButton(
                  text: AppLocalizations.of(context).topUpConfirmButton,
                  isLoading: topUpAsync.isLoading,
                  onPressed:
                      (_amount > 0 && !topUpAsync.isLoading) ? _submit : null,
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
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
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
