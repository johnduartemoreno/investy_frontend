import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/kyc_provider.dart';

/// Displays a banner when the user's KYC is not yet approved.
/// Place at the top of BuyAssetScreen / SellAssetScreen.
/// Returns null widget (invisible) when KYC is approved or status is loading.
class KycGateBanner extends ConsumerWidget {
  const KycGateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycAsync = ref.watch(kycStatusProvider);
    return kycAsync.when(
      data: (kyc) {
        if (kyc.isApproved) return const SizedBox.shrink();
        return _banner(context, kyc.status);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _banner(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPending = status == 'submitted';

    return GestureDetector(
      onTap: isPending ? null : () => context.push('/settings/kyc'),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPending
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isPending ? Icons.hourglass_top : Icons.warning_amber_rounded,
              color: isPending
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isPending ? l10n.kycBannerPending : l10n.kycBannerRequired,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPending
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!isPending)
              Icon(Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.onErrorContainer),
          ],
        ),
      ),
    );
  }
}
