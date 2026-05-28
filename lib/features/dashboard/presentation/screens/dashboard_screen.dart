import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/gradient_pill_button.dart';
import '../../../../core/presentation/widgets/left_accent_box.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/owl_ai_widget.dart';
import '../../../../l10n/app_localizations.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/buy_asset_args.dart';
import '../../data/models/dashboard_response_model.dart';
import '../../data/models/recommendation_model.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/withdraw_bottom_sheet.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/transaction.dart';

// ==========================================
// UNIFIED ACTIVITY ITEM (Sealed Class)
// ==========================================

/// A unified wrapper for items in the Recent Activity feed.
/// Allows pattern matching over transactions and contributions.
sealed class ActivityItem {
  DateTime get date;
}

class ActivityItemTransaction extends ActivityItem {
  final Transaction transaction;
  ActivityItemTransaction(this.transaction);

  @override
  DateTime get date => transaction.createdAt;
}

class ActivityItemContribution extends ActivityItem {
  final Contribution contribution;
  ActivityItemContribution(this.contribution);

  @override
  DateTime get date => contribution.createdAt;
}

// ==========================================
// REST PROVIDERS (Go Backend)
// ==========================================

/// Fetches the full dashboard payload from the Go REST backend.
/// Emits AsyncLoading → AsyncData<DashboardResponseModel> → AsyncError.
final restDashboardProvider =
    FutureProvider.autoDispose<DashboardResponseModel>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  return ref.watch(dashboardRemoteDataSourceProvider).getDashboard(userId);
});

/// Derived: Available Cash from the REST backend.
/// Maps DashboardResponseModel.totalBalance (int cents) → double dollars.
final restAvailableCashProvider =
    Provider.autoDispose<AsyncValue<double>>((ref) {
  return ref
      .watch(restDashboardProvider)
      .whenData((dash) => dash.toDomainWallet().availableCash);
});

/// Derived: Authenticated user's display name from the REST backend (Postgres).
final restUserNameProvider = Provider.autoDispose<AsyncValue<String>>((ref) {
  return ref.watch(restDashboardProvider).whenData((dash) => dash.userName);
});

/// Derived: Invested portfolio value from the REST backend.
/// Maps DashboardResponseModel.investedValue (int cents) → double dollars.
final restInvestedValueProvider =
    Provider.autoDispose<AsyncValue<double>>((ref) {
  return ref
      .watch(restDashboardProvider)
      .whenData((dash) => dash.investedValue / 100.0);
});

/// Derived: ISO 4217 display currency from the REST backend (e.g. "EUR", "USD").
final restCurrencyProvider = Provider.autoDispose<AsyncValue<String>>((ref) {
  return ref.watch(restDashboardProvider).whenData((dash) => dash.currency);
});

/// Resolved currency string — "USD" until dashboard loads.
final displayCurrencyProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(restCurrencyProvider).valueOrNull ?? 'USD';
});

/// FX rate from USD → user's display currency, cached by Riverpod.
/// Falls back to 1.0 on any error — never throws.
final fxRateProvider = FutureProvider.autoDispose<double>((ref) async {
  final currency = ref.watch(displayCurrencyProvider);
  if (currency == 'USD') return 1.0;
  final dio = ref.watch(dioProvider);
  try {
    final resp = await dio.get<Map<String, dynamic>>(
      '/api/v1/fx/rates',
      queryParameters: {'base': 'USD', 'target': currency},
    );
    return (resp.data!['rate'] as num).toDouble();
  } catch (_) {
    return 1.0;
  }
});

/// Derived: Recent Activity feed from the REST backend.
/// BUY/SELL → ActivityItemTransaction; DEPOSIT/WITHDRAWAL → ActivityItemContribution.
final restRecentActivityProvider =
    Provider.autoDispose<AsyncValue<List<ActivityItem>>>((ref) {
  return ref.watch(restDashboardProvider).whenData(
        (dash) => dash.recentActivity.map((m) {
          final t = m.type.toUpperCase();
          if (t == 'BUY' || t == 'SELL') {
            return ActivityItemTransaction(m.toTransaction());
          }
          return ActivityItemContribution(m.toDomain());
        }).toList(),
      );
});

// ==========================================
// 3. CONTRIBUTION UI HELPERS
// ==========================================

IconData _getContributionIcon(String type) {
  switch (type.toLowerCase()) {
    case 'deposit':
      return Icons.arrow_downward;
    case 'withdrawal':
      return Icons.arrow_upward;
    case 'buy':
      return Icons.trending_up;
    case 'sell':
      return Icons.trending_down;
    default:
      return Icons.swap_horiz;
  }
}

Color _getContributionColor(ColorScheme cs, String type) {
  switch (type.toLowerCase()) {
    case 'deposit':
    case 'sell':
      return AppTheme.signalGreen;
    case 'withdrawal':
    case 'buy':
      return cs.error;
    default:
      return cs.onSurfaceVariant;
  }
}

// ==========================================
// 2. DASHBOARD SCREEN (Main UI)
// ==========================================

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _getContributionTitle(AppLocalizations l10n, String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return l10n.dashboardBuy;
      case 'sell':
        return l10n.dashboardSell;
      case 'deposit':
        return l10n.activityDeposit;
      case 'withdrawal':
        return l10n.activityWithdrawal;
      default:
        return type.isEmpty ? l10n.activityUnknown : (type[0].toUpperCase() + type.substring(1));
    }
  }

  String _formatContributionDate(AppLocalizations l10n, DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(local.year, local.month, local.day);

    if (dateOnly == today) {
      return '${l10n.commonToday}, ${DateFormat.jm().format(local)}';
    } else if (dateOnly == yesterday) {
      return '${l10n.commonYesterday}, ${DateFormat.jm().format(local)}';
    } else {
      return DateFormat.yMMMd().format(local);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // REST providers — Go backend
    final userNameAsync = ref.watch(restUserNameProvider);
    final netWorthAsync = ref.watch(restInvestedValueProvider);
    final availableCashAsync = ref.watch(restAvailableCashProvider);
    final recentActivityAsync = ref.watch(restRecentActivityProvider);
    final currencyAsync = ref.watch(restCurrencyProvider);
    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, l10n, userNameAsync),
              const SizedBox(height: 20),
              _buildBalanceCard(theme, l10n, netWorthAsync, availableCashAsync,
                  currencyAsync.valueOrNull ?? 'USD', fxRate),
              const SizedBox(height: 16),
              _buildOwlAdvisorCard(theme, l10n),
              const SizedBox(height: 24),
              _buildQuickActions(theme, l10n),
              const SizedBox(height: 28),
              _buildRecentActivitySection(
                  theme, l10n, recentActivityAsync, currency, fxRate),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --- Internal Widgets ---

  Widget _buildHeader(
      ThemeData theme, AppLocalizations l10n, AsyncValue<String> userNameAsync) {
    final rawName = userNameAsync.valueOrNull ?? '';
    final firstName = _firstName(rawName);
    final greeting = _greeting(l10n);
    final photoURL = FirebaseAuth.instance.currentUser?.photoURL;
    final initial =
        rawName.isNotEmpty ? rawName.trim()[0].toUpperCase() : '?';

    return Row(
      children: [
        _UserAvatar(photoURL: photoURL, initial: initial),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              rawName.isEmpty
                  ? const SizedBox(height: 28)
                  : Text(
                      firstName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brandPurple.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 20),
        ),
      ],
    );
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  // Extracts and capitalizes first name (e.g. "johnduartemoreno" → "John")
  String _firstName(String name) {
    if (name.isEmpty) return '';
    // If name has spaces, take first word; otherwise capitalize whole string
    final part = name.split(' ').first;
    return part[0].toUpperCase() + part.substring(1).toLowerCase();
  }

  Widget _buildBalanceCard(
      ThemeData theme,
      AppLocalizations l10n,
      AsyncValue<double> netWorthAsync,
      AsyncValue<double> availableCashAsync,
      String currency,
      double fxRate) {
    final investedVal = netWorthAsync.valueOrNull;
    final cashVal = availableCashAsync.valueOrNull;
    final totalVal = (investedVal != null && cashVal != null)
        ? (investedVal + cashVal) * fxRate
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandPurple.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardTotalBalance,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          totalVal != null
              ? Text(
                  CurrencyFormatter.formatWithCurrency(totalVal, currency),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                )
              : (netWorthAsync.isLoading || availableCashAsync.isLoading)
                  ? _shimmer(width: 140, height: 36)
                  : Text('--',
                      style: theme.textTheme.displaySmall
                          ?.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardInvestedValue,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  investedVal != null
                      ? Text(
                          CurrencyFormatter.formatWithCurrency(
                              investedVal * fxRate, currency),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : netWorthAsync.isLoading
                          ? _shimmer(width: 70, height: 20)
                          : const Text('--',
                              style: TextStyle(color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.dashboardCashToInvest,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  cashVal != null
                      ? Text(
                          CurrencyFormatter.formatWithCurrency(
                              cashVal * fxRate, currency),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : availableCashAsync.isLoading
                          ? _shimmer(width: 70, height: 20)
                          : const Text('--',
                              style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ade80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.portfolioActive,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwlAdvisorCard(ThemeData theme, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _openOwlSheet(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceContainerHigh,
          border: Border.all(
            color: AppTheme.brandPurple.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandPurple.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const OwlAiWidget(size: 52, state: OwlState.idle),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.owlAiName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.owlAiTagline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 13),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openOwlSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _OwlAdvisorSheet(),
    );
  }

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, AppLocalizations l10n) {
    const buyColor = Color(0xFF4ade80);
    const sellColor = Color(0xFFf87171);
    const topUpColor = AppTheme.brandPurpleLight;
    const withdrawColor = Color(0xFFfbbf24);

    final actions = [
      (
        icon: Icons.trending_up_rounded,
        label: l10n.dashboardBuy,
        color: buyColor,
        bg: buyColor.withValues(alpha: 0.14),
        onTap: () => context.go('/home/buy-asset'),
      ),
      (
        icon: Icons.trending_down_rounded,
        label: l10n.dashboardSell,
        color: sellColor,
        bg: sellColor.withValues(alpha: 0.14),
        onTap: () => context.go('/home/sell-asset'),
      ),
      (
        icon: Icons.add_card_rounded,
        label: l10n.dashboardTopUp,
        color: topUpColor,
        bg: topUpColor.withValues(alpha: 0.14),
        onTap: () => context.go('/home/top-up'),
      ),
      (
        icon: Icons.file_download_outlined,
        label: l10n.dashboardWithdraw,
        color: withdrawColor,
        bg: withdrawColor.withValues(alpha: 0.14),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const WithdrawBottomSheet(),
        ),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((item) {
        return Column(
          children: [
            GestureDetector(
              onTap: item.onTap,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: item.bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivitySection(ThemeData theme, AppLocalizations l10n,
      AsyncValue<List<ActivityItem>> recentActivityAsync,
      String currency, double fxRate) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardRecentActivity,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.brandPurpleLight,
              ),
              child: Text(l10n.dashboardSeeAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        recentActivityAsync.when(
          data: (items) => items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    l10n.dashboardNoActivity,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  children: items
                      .map((item) =>
                          _buildActivityItem(theme, l10n, item, currency, fxRate))
                      .toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              l10n.commonError,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      ThemeData theme, AppLocalizations l10n, ActivityItem item, String currency, double fxRate) {
    return switch (item) {
      ActivityItemTransaction(:final transaction) =>
        _buildTransactionActivityItem(theme, l10n, transaction, currency, fxRate),
      ActivityItemContribution(:final contribution) =>
        _buildContributionActivityItem(theme, l10n, contribution, currency, fxRate),
    };
  }

  Widget _buildTransactionActivityItem(
      ThemeData theme, AppLocalizations l10n, Transaction transaction, String currency, double fxRate) {
    final isBuy = transaction.type.toLowerCase() == 'buy';
    final icon = isBuy ? Icons.trending_up : Icons.trending_down;
    final color = isBuy ? AppTheme.signalGreen : theme.colorScheme.error;
    final title = isBuy
        ? l10n.activityBought(transaction.symbol)
        : l10n.activitySold(transaction.symbol);
    final dateStr = _formatContributionDate(l10n, transaction.createdAt);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surface,
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(
          title,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dateStr,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          '${isBuy ? '-' : '+'} ${CurrencyFormatter.formatWithCurrency(transaction.totalBeforeFees * fxRate, currency)}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isBuy ? theme.colorScheme.error : AppTheme.signalGreen,
          ),
        ),
        onTap: () => _showActivityDetail(context, ActivityItemTransaction(transaction)),
      ),
    );
  }

  Widget _buildContributionActivityItem(
      ThemeData theme, AppLocalizations l10n, Contribution contribution, String currency, double fxRate) {
    final type = contribution.type.toLowerCase();
    final isDebit = type == 'withdrawal' || type == 'buy';
    final icon = _getContributionIcon(type);
    final color = _getContributionColor(theme.colorScheme, type);
    final title = _getContributionTitle(l10n, contribution.type);
    final dateStr = _formatContributionDate(l10n, contribution.createdAt);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surface,
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(
          title,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dateStr,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          '${isDebit ? '-' : '+'} ${CurrencyFormatter.formatWithCurrency(contribution.amount * fxRate, currency)}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDebit ? theme.colorScheme.error : AppTheme.signalGreen,
          ),
        ),
        onTap: () => _showActivityDetail(context, ActivityItemContribution(contribution)),
      ),
    );
  }

  void _showActivityDetail(BuildContext context, ActivityItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityDetailSheet(item: item),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// F4 — Owl Advisor Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _OwlAdvisorSheet extends ConsumerStatefulWidget {
  const _OwlAdvisorSheet();

  @override
  ConsumerState<_OwlAdvisorSheet> createState() => _OwlAdvisorSheetState();
}

class _OwlAdvisorSheetState extends ConsumerState<_OwlAdvisorSheet> {
  OwlState _owlState = OwlState.thinking;
  bool _isRefreshing = false;

  void _onRecsLoaded() {
    if (!mounted) return;
    setState(() => _owlState = OwlState.celebrating);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _owlState = OwlState.idle);
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() { _owlState = OwlState.thinking; _isRefreshing = true; });
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final language = ref.read(localeNotifierProvider).languageCode;
      if (userId == null) return;
      // Bust server-side cache first, then re-fetch via provider
      await ref
          .read(dashboardRemoteDataSourceProvider)
          .getRecommendations(userId, language: language, forceRefresh: true);
    } catch (_) {
      // If bust fails, still try to re-fetch
    }
    if (mounted) {
      setState(() => _isRefreshing = false);
      ref.invalidate(recommendationsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final recsAsync = ref.watch(recommendationsProvider);

    // Fire celebrate when provider transitions to data.
    ref.listen(recommendationsProvider, (prev, next) {
      if (next is AsyncData && prev is! AsyncData) _onRecsLoaded();
    });
    // Edge case: cached data already present on first build — listener never fires.
    // Only schedule when NOT in a manual refresh (which uses _isRefreshing to gate body).
    if (!_isRefreshing && _owlState == OwlState.thinking && recsAsync is AsyncData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _owlState == OwlState.thinking) _onRecsLoaded();
      });
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(color: Color(0x596C63FF), width: 1),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    OwlAiWidget(size: 44, state: _owlState),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.owlAiName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            l10n.owlAiPoweredAdvisor,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.brandPurpleLight,
                            ),
                          ),
                          if (recsAsync is AsyncData && _owlState != OwlState.thinking) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _refresh,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.auto_awesome_rounded,
                                        color: Colors.white, size: 13),
                                    const SizedBox(width: 5),
                                    Text(
                                      l10n.owlAiAskNewRecs,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            color: theme.colorScheme.onSurfaceVariant, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // Available cash — prominent
              _buildCashBanner(theme, l10n),
              const SizedBox(height: 4),
              // Body — _isRefreshing gates immediate thinking during manual refresh;
              // provider state handles initial load and error cases.
              Expanded(
                child: _isRefreshing
                    ? _buildThinking(theme, l10n)
                    : recsAsync.when(
                        loading: () => _buildThinking(theme, l10n),
                        error: (e, _) => SingleChildScrollView(child: _buildError(theme, l10n, e)),
                        data: (recs) => _buildRecList(theme, scrollController, recs),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThinking(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OwlAiWidget(size: 72, state: OwlState.thinking),
          const SizedBox(height: 16),
          Text(
            _isRefreshing ? l10n.owlAiRefreshing : l10n.owlAiAnalyzing,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppTheme.brandPurpleLight),
          ),
          if (_isRefreshing) ...[
            const SizedBox(height: 6),
            Text(
              l10n.owlAiRefreshingSubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, AppLocalizations l10n, Object error) {
    final isNotConfigured = error.toString().contains('ERR_AI_NOT_CONFIGURED') ||
        error.toString().contains('503');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              isNotConfigured
                  ? l10n.owlAiUnavailable
                  : l10n.owlAiErrorRetry,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (!isNotConfigured) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.owlAiRefresh),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecList(ThemeData theme, ScrollController ctrl, List<RecommendationModel> recs) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;
    return ListView.builder(
      controller: ctrl,
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad),
      itemCount: recs.length,
      itemBuilder: (context, i) => _RecCard(rec: recs[i], index: i),
    );
  }

  Widget _buildCashBanner(ThemeData theme, AppLocalizations l10n) {
    final cash = ref.watch(restAvailableCashProvider).valueOrNull;
    final currency = ref.watch(displayCurrencyProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.brandPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.owlAiCashAvailable,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              cash != null
                  ? Text(
                      CurrencyFormatter.formatWithCurrency(cash, currency),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.brandPurpleLight,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.brandPurple.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppTheme.brandPurpleLight,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecCard extends StatefulWidget {
  final RecommendationModel rec;
  final int index;

  const _RecCard({required this.rec, required this.index});

  @override
  State<_RecCard> createState() => _RecCardState();
}

class _RecCardState extends State<_RecCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Staggered delay per card
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final r = widget.rec;
    final suggestedDollars = (r.suggestedAmountCents / 100).toStringAsFixed(0);

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.brandPurple.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brandPurple.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _tickerIcon(r.ticker),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.ticker,
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800)),
                        Text(r.name,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _strengthBadge(r.strong),
                ],
              ),
              const SizedBox(height: 10),
              LeftAccentBox(
                child: Text(
                  r.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                      children: [
                        TextSpan(text: '${l10n.owlAiSuggested} '),
                        TextSpan(
                          text: '\$$suggestedDollars',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  GradientPillButton(
                    label: l10n.owlAiBuyButton,
                    onTap: () => context.push(
                      '/home/buy-asset',
                      extra: BuyAssetArgs(
                        symbol: r.ticker,
                        name: r.name,
                        priceCents: 0,
                        signalLabel: r.strong
                            ? l10n.owlAiStrongBuy
                            : l10n.owlAiModerateSignal,
                        signalColor: r.strong
                            ? AppTheme.signalGreen
                            : AppTheme.signalAmber,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tickerIcon(String ticker) {
    const colorMap = {
      'AAPL': [Color(0xFF1d4ed8), Color(0xFF3b82f6)],
      'VTI':  [Color(0xFF065f46), Color(0xFF10b981)],
      'BTC':  [Color(0xFF78350f), Color(0xFFf59e0b)],
      'MSFT': [Color(0xFF4c1d95), Color(0xFF8b5cf6)],
      'IAU':  [Color(0xFF881337), Color(0xFFf43f5e)],
    };
    final c = colorMap[ticker] ?? [AppTheme.brandPurple, AppTheme.brandPurpleLight];
    final displayLabel = ticker.length > 4 ? ticker.substring(0, 4) : ticker;

    return GradientIconBox(
      colors: c,
      child: Text(displayLabel,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }

  Widget _strengthBadge(bool strong) {
    final l10n = AppLocalizations.of(context);
    return SignalBadge(
      label: strong ? l10n.owlAiStrongBuy : l10n.owlAiModerateSignal,
      color: strong ? AppTheme.signalGreen : AppTheme.signalAmber,
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? photoURL;
  final String initial;

  const _UserAvatar({required this.photoURL, required this.initial});

  @override
  Widget build(BuildContext context) {
    if (photoURL != null && photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: AppTheme.brandPurple,
        backgroundImage: NetworkImage(photoURL!),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Activity Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _ActivityDetailSheet extends ConsumerWidget {
  final ActivityItem item;
  const _ActivityDetailSheet({required this.item});

  static const _colorMap = {
    'AAPL': [Color(0xFF1d4ed8), Color(0xFF3b82f6)],
    'VTI':  [Color(0xFF065f46), Color(0xFF10b981)],
    'BTC':  [Color(0xFF78350f), Color(0xFFf59e0b)],
    'MSFT': [Color(0xFF4c1d95), Color(0xFF8b5cf6)],
    'IAU':  [Color(0xFF881337), Color(0xFFf43f5e)],
  };

  List<Color> _tickerColors(String ticker) =>
      _colorMap[ticker] ?? [AppTheme.brandPurple, AppTheme.brandPurpleLight];

  String _formatQuantity(double qty) {
    if (qty == qty.truncateToDouble()) return qty.toStringAsFixed(0);
    final s = qty.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
    return s.endsWith('.') ? s.replaceAll('.', '') : s;
  }

  String _fullDate(DateTime dt) =>
      DateFormat('MMM d, y — h:mm a').format(dt.toLocal());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(displayCurrencyProvider);
    final fxRate = ref.watch(fxRateProvider).valueOrNull ?? 1.0;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusBottomSheet),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            switch (item) {
              ActivityItemTransaction(:final transaction) =>
                _buildTransactionDetail(theme, cs, l10n, transaction, currency, fxRate),
              ActivityItemContribution(:final contribution) =>
                _buildContributionDetail(theme, cs, l10n, contribution, currency, fxRate),
            },
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    Transaction tx,
    String currency,
    double fxRate,
  ) {
    final isBuy = tx.type.toLowerCase() == 'buy';
    final typeLabel = isBuy ? l10n.dashboardBuy : l10n.dashboardSell;
    final amountColor = isBuy ? cs.error : AppTheme.signalGreen;
    final signPrefix = isBuy ? '−' : '+';
    final hasPnl = !isBuy && tx.realizedPnlCents != 0;
    final pnlIsGain = tx.realizedPnlCents > 0;
    final pnlColor = pnlIsGain ? AppTheme.signalGreen : cs.error;
    final pnlLabel = pnlIsGain ? l10n.activityDetailGain : l10n.activityDetailLoss;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: ticker icon + type label
        Row(
          children: [
            GradientIconBox(
              colors: _tickerColors(tx.symbol),
              size: 44,
              child: Text(
                tx.symbol.length > 4 ? tx.symbol.substring(0, 4) : tx.symbol,
                style: const TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: AppDimens.spacingM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  tx.symbol,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '$signPrefix ${CurrencyFormatter.formatWithCurrency(tx.totalBeforeFees * fxRate, currency)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spacingL),
        // Detail rows
        CustomCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingL, vertical: AppDimens.spacingM),
          child: Column(
            children: [
              _detailRow(theme, cs, l10n.activityDetailQuantity,
                  _formatQuantity(tx.quantity)),
              _divider(cs),
              _detailRow(theme, cs, l10n.activityDetailPricePerUnit,
                  CurrencyFormatter.formatWithCurrency(tx.price * fxRate, currency)),
              _divider(cs),
              _detailRow(theme, cs, l10n.activityDetailTotal,
                  CurrencyFormatter.formatWithCurrency(tx.totalBeforeFees * fxRate, currency)),
              _divider(cs),
              _detailRow(theme, cs, l10n.activityDetailDate,
                  _fullDate(tx.createdAt)),
              if (hasPnl) ...[
                _divider(cs),
                _pnlRow(theme, cs, l10n.activityDetailRealizedPnl,
                    tx.realizedPnlCents, fxRate, currency, pnlColor, pnlLabel),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _pnlRow(
    ThemeData theme,
    ColorScheme cs,
    String label,
    int pnlCents,
    double fxRate,
    String currency,
    Color color,
    String badgeLabel,
  ) {
    final pnlDisplay = CurrencyFormatter.formatWithCurrency(
        pnlCents.abs() / 100.0 * fxRate, currency);
    final sign = pnlCents >= 0 ? '+' : '−';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingS),
      child: Row(
        children: [
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const Spacer(),
          SignalBadge(label: badgeLabel, color: color),
          const SizedBox(width: AppDimens.spacingS),
          Text(
            '$sign $pnlDisplay',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionDetail(
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    Contribution contribution,
    String currency,
    double fxRate,
  ) {
    final type = contribution.type.toLowerCase();
    final isDebit = type == 'withdrawal';
    final icon = _getContributionIcon(type);
    final color = _getContributionColor(cs, type);
    final typeLabel = _getContributionLabel(l10n, type);
    final signPrefix = isDebit ? '−' : '+';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: icon + label + amount
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: AppDimens.spacingM),
            Text(
              typeLabel,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '$signPrefix ${CurrencyFormatter.formatWithCurrency(contribution.amount * fxRate, currency)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDebit ? cs.error : AppTheme.signalGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spacingL),
        CustomCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingL, vertical: AppDimens.spacingM),
          child: Column(
            children: [
              _detailRow(theme, cs, l10n.activityDetailAmount,
                  CurrencyFormatter.formatWithCurrency(contribution.amount * fxRate, currency)),
              _divider(cs),
              _detailRow(theme, cs, l10n.activityDetailDate,
                  _fullDate(contribution.createdAt)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(ThemeData theme, ColorScheme cs, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingS),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _divider(ColorScheme cs) => Divider(
        height: 1,
        thickness: 0.5,
        color: cs.outlineVariant.withValues(alpha: 0.5),
      );

  String _getContributionLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'deposit': return l10n.activityDeposit;
      case 'withdrawal': return l10n.activityWithdrawal;
      default: return type;
    }
  }

  IconData _getContributionIcon(String type) {
    switch (type) {
      case 'deposit': return Icons.arrow_downward;
      case 'withdrawal': return Icons.arrow_upward;
      default: return Icons.swap_horiz;
    }
  }

  Color _getContributionColor(ColorScheme cs, String type) {
    switch (type) {
      case 'deposit': return AppTheme.signalGreen;
      case 'withdrawal': return cs.error;
      default: return cs.onSurfaceVariant;
    }
  }
}
