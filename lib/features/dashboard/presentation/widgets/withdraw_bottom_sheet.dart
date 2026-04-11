import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

  Future<void> _handleWithdraw(double maxAvailable) async {
    if (!_formKey.currentState!.validate()) return;
    if (_amount <= 0) return;
    if (_amount > maxAvailable)
      return; // Should be caught by validator but double check

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await ref.read(dashboardRemoteDataSourceProvider).createTransaction(
            userId,
            TransactionRequestModel.fromDomain(_amount, 'WITHDRAWAL'),
          );

      ref.invalidate(restDashboardProvider);

      if (mounted) {
        context.pop(); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully withdrew ${NumberFormat.simpleCurrency().format(_amount)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final availableCashAsync = ref.watch(restAvailableCashProvider);
    final currencyFmt = NumberFormat.simpleCurrency();

    // Default to 0 if loading/error, but UI handles loading state
    final maxAvailable = availableCashAsync.valueOrNull ?? 0.0;
    final isLoadingData = availableCashAsync.isLoading;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                'Withdraw Cash',
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
            'Available to Withdraw',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : Text(
                  currencyFmt.format(maxAvailable),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
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
                prefixText: '\$ ',
                hintText: '0',
                border: InputBorder.none,
                hintStyle: theme.textTheme.displayMedium?.copyWith(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
              onChanged: (value) {
                setState(() {
                  _amount = ThousandsSeparatorInputFormatter.parseFormatted(value) ?? 0.0;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter an amount';
                final val = ThousandsSeparatorInputFormatter.parseFormatted(value);
                if (val == null || val <= 0) return 'Amount must be positive';
                if (val > maxAvailable) return 'Insufficient funds';
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
                  onTap: () => _updateAmount(maxAvailable * 0.25),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionChip(
                  label: '50%',
                  onTap: () => _updateAmount(maxAvailable * 0.50),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionChip(
                  label: 'MAX',
                  onTap: () => _updateAmount(maxAvailable),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bank Info (Static)
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
                  child:
                      Icon(Icons.account_balance, color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Column(
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
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Button
          FilledButton(
            onPressed: (_amount > 0 && _amount <= maxAvailable && !_isLoading)
                ? () => _handleWithdraw(maxAvailable)
                : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text('Confirm Withdrawal'),
          ),
        ],
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
