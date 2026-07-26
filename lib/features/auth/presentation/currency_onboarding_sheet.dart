import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/primary_button.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/presentation/screens/dashboard_screen.dart';
import 'currency_options.dart';
import 'providers/auth_provider.dart';

// Guard so the sheet is never stacked twice if the auth listener fires again
// while it is already open.
bool _onboardingSheetShowing = false;

/// Shows the blocking currency-selection sheet for a brand-new Google user (F5),
/// on the root navigator so it survives the redirect to Home. No-op if already
/// showing or if there is no root context yet.
Future<void> promptGoogleCurrencyOnboarding() async {
  if (_onboardingSheetShowing) return;
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;

  _onboardingSheetShowing = true;
  try {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: false, // required step — the user must choose a currency
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CurrencyOnboardingSheet(),
    );
  } finally {
    _onboardingSheetShowing = false;
  }
}

class _CurrencyOnboardingSheet extends ConsumerStatefulWidget {
  const _CurrencyOnboardingSheet();

  @override
  ConsumerState<_CurrencyOnboardingSheet> createState() =>
      _CurrencyOnboardingSheetState();
}

class _CurrencyOnboardingSheetState
    extends ConsumerState<_CurrencyOnboardingSheet> {
  String _selected = 'USD';
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .onboardGoogleCurrency(_selected);
      // Home may have already loaded with the USD default — refresh it so the
      // chosen currency shows immediately.
      ref.invalidate(restDashboardProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).commonError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false, // block the Android back button — currency is required
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusBottomSheet)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.spacingXL,
          top: AppDimens.spacingL,
          left: AppDimens.spacingL,
          right: AppDimens.spacingL,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.spacingL),
              Text(l10n.onboardCurrencyTitle,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppDimens.spacingS),
              Text(l10n.onboardCurrencyBody,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: AppDimens.spacingL),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final code in kCurrencyCodes)
                        ListTile(
                          title: Text('$code — ${currencyLabel(l10n, code)}'),
                          trailing: _selected == code
                              ? Icon(Icons.check, color: cs.primary)
                              : null,
                          onTap: _isSubmitting
                              ? null
                              : () => setState(() => _selected = code),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.spacingL),
              PrimaryButton(
                text: l10n.commonConfirm,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
