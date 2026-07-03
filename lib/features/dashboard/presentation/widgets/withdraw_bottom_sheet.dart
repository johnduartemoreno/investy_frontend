import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/transaction_request_model.dart';
import '../screens/dashboard_screen.dart';

class WithdrawBottomSheet extends ConsumerStatefulWidget {
  const WithdrawBottomSheet({super.key});

  @override
  ConsumerState<WithdrawBottomSheet> createState() =>
      _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends ConsumerState<WithdrawBottomSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  double _amount = 0.0;

  @override
  void initState() {
    super.initState();
    // Force fresh balance every time the sheet opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(restDashboardProvider);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(double value) {
    setState(() {
      _amount = value;
      final formatter = NumberFormat('#,##0.##', 'en_US');
      _amountController.text = formatter.format(value);
    });
  }

  // maxAvailableDisplay is in display currency (e.g. EUR).
  // _amount is also in display currency — convert to USD before sending.
  Future<void> _handleWithdraw(double maxAvailableDisplay) async {
    if (!_formKey.currentState!.validate()) return;
    if (_amount <= 0) return;
    if (_amount > maxAvailableDisplay) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final fxRate = ref.read(fxRateProvider).valueOrNull ?? 1.0;
      final amountUsd = fxRate > 0 ? _amount / fxRate : _amount;

      await ref.read(dashboardRemoteDataSourceProvider).createTransaction(
            userId,
            TransactionRequestModel.forCash(amountUsd, 'WITHDRAWAL'),
          );

      ref.invalidate(restDashboardProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).withdrawSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final availableCashAsync = ref.watch(restAvailableCashProvider);
    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;

    // maxAvailableUsd is raw USD dollars from the provider.
    // maxAvailableDisplay converts to user's display currency for UI use.
    final maxAvailableUsd = availableCashAsync.valueOrNull ?? 0.0;
    final maxAvailableDisplay = maxAvailableUsd * fxRate;
    final isLoadingData = availableCashAsync.isLoading;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusBottomSheet)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AppDimens.spacingXL,
          left: AppDimens.spacingXL,
          right: AppDimens.spacingXL,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).withdrawCash,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Available Balance
            Text(
              AppLocalizations.of(context).withdrawAvailableTo,
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            isLoadingData
                ? const Center(child: CircularProgressIndicator.adaptive())
                : Text(
                    CurrencyFormatter.formatWithCurrency(
                        maxAvailableDisplay, currency),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 32),

            // Input
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixText: '${CurrencyFormatter.symbolFor(currency)} ',
                  hintText: '0',
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.displayMedium?.copyWith(
                    color: cs.outline.withValues(alpha: 0.5),
                  ),
                ),
                inputFormatters: [
                  ThousandsSeparatorInputFormatter(),
                ],
                onChanged: (value) {
                  setState(() {
                    _amount = ThousandsSeparatorInputFormatter.parseFormatted(
                            value) ??
                        0.0;
                  });
                },
                validator: (value) {
                  final l10n = AppLocalizations.of(context);
                  if (value == null || value.isEmpty) {
                    return l10n.withdrawEnterAmount;
                  }
                  final val =
                      ThousandsSeparatorInputFormatter.parseFormatted(value);
                  if (val == null || val <= 0) {
                    return l10n.withdrawAmountPositive;
                  }
                  if (val > maxAvailableDisplay) {
                    return l10n.withdrawInsufficientFunds;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionChip(
                    label: '25%',
                    onTap: () => _updateAmount(maxAvailableDisplay * 0.25),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionChip(
                    label: '50%',
                    onTap: () => _updateAmount(maxAvailableDisplay * 0.50),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionChip(
                    label: 'MAX',
                    onTap: () => _updateAmount(maxAvailableDisplay),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Button
            PrimaryButton(
              text: AppLocalizations.of(context).withdrawConfirmButton,
              isLoading: _isLoading,
              onPressed: _isLoading
                  ? null
                  : () => _handleWithdraw(maxAvailableDisplay),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
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
    );
  }
}
