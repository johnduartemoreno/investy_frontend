import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../kyc/presentation/providers/kyc_provider.dart';
import '../providers/broker_provider.dart';

/// Shows a banner when KYC is approved but the broker account is not yet active.
/// Returns an invisible widget when broker account is active or data is loading.
/// Place below KycGateBanner in BuyAssetScreen / SellAssetScreen.
class BrokerGateBanner extends ConsumerWidget {
  const BrokerGateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycAsync = ref.watch(kycStatusProvider);
    final brokerAsync = ref.watch(brokerAccountProvider);

    final kycApproved = kycAsync.valueOrNull?.isApproved ?? false;
    if (!kycApproved) return const SizedBox.shrink();

    return brokerAsync.when(
      data: (account) {
        if (account == null || !account.isActive) {
          return _banner(context, account?.isPending ?? false);
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _banner(BuildContext context, bool isPending) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPending
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPending ? Icons.hourglass_top : Icons.account_balance_outlined,
            color: isPending
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isPending
                  ? l10n.brokerBannerPending
                  : l10n.brokerBannerNotActive,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPending
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
