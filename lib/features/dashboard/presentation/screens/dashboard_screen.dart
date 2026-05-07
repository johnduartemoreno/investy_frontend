import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/owl_ai_widget.dart';
import '../../../../l10n/app_localizations.dart';

import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/dashboard_response_model.dart';
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
/// Maps each ActivityItemModel → ActivityItemContribution wrapping a Contribution,
/// compatible with the existing ActivityItem sealed class used in the UI.
final restRecentActivityProvider =
    Provider.autoDispose<AsyncValue<List<ActivityItem>>>((ref) {
  return ref.watch(restDashboardProvider).whenData(
        (dash) => dash.recentActivity
            .map((m) => ActivityItemContribution(m.toDomain()))
            .toList(),
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
    default:
      return Icons.swap_horiz;
  }
}

Color _getContributionColor(String type) {
  switch (type.toLowerCase()) {
    case 'deposit':
      return Colors.green;
    case 'withdrawal':
      return Colors.red;
    default:
      return Colors.grey;
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '${l10n.commonToday}, ${DateFormat.jm().format(date)}';
    } else if (dateOnly == yesterday) {
      return '${l10n.commonYesterday}, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat.yMMMd().format(date);
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
                  currencyAsync.valueOrNull ?? 'USD'),
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
    final greeting = _greeting();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
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
      String currency) {
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
            l10n.dashboardInvestedPortfolio,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          netWorthAsync.when(
            data: (value) => Text(
              CurrencyFormatter.formatWithCurrency(value, currency),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            loading: () => _shimmer(width: 140, height: 36),
            error: (_, __) => Text('--',
                style: theme.textTheme.displaySmall
                    ?.copyWith(color: Colors.white)),
          ),
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
                    l10n.dashboardCashToInvest,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  availableCashAsync.when(
                    data: (value) => Text(
                      CurrencyFormatter.formatWithCurrency(value, currency),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    loading: () => _shimmer(width: 80, height: 20),
                    error: (_, __) => const Text('--',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
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
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                  Row(
                    children: [
                      Text(
                        l10n.owlAiName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppTheme.brandPurple,
                            AppTheme.brandPurpleLight
                          ]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.owlAiAdvisorLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
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
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppTheme.brandPurpleLight),
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
    final color = isBuy ? Colors.green : Colors.red;
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
            color: isBuy ? theme.colorScheme.error : Colors.green.shade700,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildContributionActivityItem(
      ThemeData theme, AppLocalizations l10n, Contribution contribution, String currency, double fxRate) {
    final isWithdrawal = contribution.type == 'withdrawal';
    final icon = _getContributionIcon(contribution.type);
    final color = _getContributionColor(contribution.type);
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
          '${isWithdrawal ? '-' : '+'} ${CurrencyFormatter.formatWithCurrency(contribution.amount * fxRate, currency)}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color:
                isWithdrawal ? theme.colorScheme.error : Colors.green.shade700,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// F4 — Owl Advisor Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _OwlAdvisorSheet extends StatefulWidget {
  const _OwlAdvisorSheet();

  @override
  State<_OwlAdvisorSheet> createState() => _OwlAdvisorSheetState();
}

class _OwlAdvisorSheetState extends State<_OwlAdvisorSheet> {
  OwlState _owlState = OwlState.thinking;
  bool _loaded = false;

  // Placeholder recs — replaced by Claude API in S15
  static const _recs = [
    (
      ticker: 'AAPL',
      name: 'Apple Inc.',
      reason:
          'Strong brand moat + services revenue growing 15% YoY. Low-volatility blue chip aligned with moderate risk.',
      suggested: 300,
      strong: true,
    ),
    (
      ticker: 'VTI',
      name: 'Vanguard Total Market',
      reason:
          'Broad diversification at 0.03% expense ratio. Ideal anchor for a 20-year retirement goal.',
      suggested: 500,
      strong: true,
    ),
    (
      ticker: 'BTC',
      name: 'Bitcoin',
      reason:
          '5% allocation adds asymmetric upside. Your 0% crypto exposure leaves return on the table for a 20-year horizon.',
      suggested: 200,
      strong: false,
    ),
    (
      ticker: 'MSFT',
      name: 'Microsoft Corp.',
      reason:
          'Azure + AI (Copilot) compound runway. Moderate volatility — complements AAPL without sector overlap.',
      suggested: 150,
      strong: true,
    ),
    (
      ticker: 'IAU',
      name: 'iShares Gold Trust',
      reason:
          'Inflation hedge for long horizons. ETF form adds stability when equities correct — zero custody risk.',
      suggested: 90,
      strong: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate thinking delay — replaced by real API call in S15
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _owlState = OwlState.celebrating;
        _loaded = true;
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _owlState = OwlState.idle);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                    width: 36,
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
                    Column(
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
                      ],
                    ),
                    const Spacer(),
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
              // Divider
              Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                  indent: 20,
                  endIndent: 20),
              // Context pills — Wrap prevents overflow on small screens
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill('📊 Moderate risk'),
                    _pill('🎯 Retire in 20y'),
                    _pill('💵 Cash ready'),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                  indent: 20,
                  endIndent: 20),
              const SizedBox(height: 4),
              // Body
              Expanded(
                child: !_loaded
                    ? _buildThinking(theme, l10n)
                    : _buildRecList(theme, scrollController),
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
            l10n.owlAiAnalyzing,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppTheme.brandPurpleLight),
          ),
        ],
      ),
    );
  }

  Widget _buildRecList(ThemeData theme, ScrollController ctrl) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;
    return ListView.builder(
      controller: ctrl,
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad),
      itemCount: _recs.length,
      itemBuilder: (context, i) {
        return _RecCard(rec: _recs[i], index: i);
      },
    );
  }

  Widget _pill(String label) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RecCard extends StatefulWidget {
  final ({
    String ticker,
    String name,
    String reason,
    int suggested,
    bool strong
  }) rec;
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
    final r = widget.rec;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
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
              Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                        color: AppTheme.brandPurple.withValues(alpha: 0.5),
                        width: 2),
                  ),
                ),
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
                        TextSpan(text: '${AppLocalizations.of(context).owlAiSuggested} '),
                        TextSpan(
                          text: '\$${r.suggested}',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          AppTheme.brandPurple,
                          AppTheme.brandPurpleLight
                        ]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalizations.of(context).owlAiBuyButton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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
    final colors = {
      'AAPL': [const Color(0xFF1d4ed8), const Color(0xFF3b82f6)],
      'VTI': [const Color(0xFF065f46), const Color(0xFF10b981)],
      'BTC': [const Color(0xFF78350f), const Color(0xFFf59e0b)],
      'MSFT': [const Color(0xFF4c1d95), const Color(0xFF8b5cf6)],
      'IAU': [const Color(0xFF881337), const Color(0xFFf43f5e)],
    };
    final c = colors[ticker] ??
        [AppTheme.brandPurple, AppTheme.brandPurpleLight];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: c,
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        ticker.length > 4 ? ticker.substring(0, 4) : ticker,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _strengthBadge(bool strong) {
    final l10n = AppLocalizations.of(context);
    final label = strong ? l10n.owlAiStrongBuy : l10n.owlAiModerateSignal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: strong
            ? const Color(0xFF4ade80).withValues(alpha: 0.12)
            : const Color(0xFFfbbf24).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: strong
              ? const Color(0xFF4ade80).withValues(alpha: 0.35)
              : const Color(0xFFfbbf24).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: strong ? const Color(0xFF4ade80) : const Color(0xFFfbbf24),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
