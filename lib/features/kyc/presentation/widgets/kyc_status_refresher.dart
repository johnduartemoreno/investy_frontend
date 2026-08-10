import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/kyc_provider.dart';

/// Re-reads the KYC status whenever the app comes back to the foreground.
///
/// Mounted above the router so it covers every screen, not just the KYC one:
/// the broker and KYC gate banners are shown on trading screens, and a stale
/// "under review" there blocks the user just as effectively (B80).
///
/// This is also what makes tapping a KYC push do something useful — the tap
/// resumes the app, and the resume is what refreshes.
class KycStatusRefresher extends ConsumerStatefulWidget {
  final Widget child;

  const KycStatusRefresher({super.key, required this.child});

  @override
  ConsumerState<KycStatusRefresher> createState() => _KycStatusRefresherState();
}

class _KycStatusRefresherState extends ConsumerState<KycStatusRefresher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    // Approved and rejected are the only states nothing can move out of.
    // Skipping them keeps every already-verified user from paying for a
    // network round trip on every single app resume — the same rule the
    // backend's own reconciliation uses.
    final current = ref.read(kycStatusProvider).valueOrNull;
    if (current != null && !current.isPendingDecision) return;

    ref.invalidate(kycStatusProvider);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
