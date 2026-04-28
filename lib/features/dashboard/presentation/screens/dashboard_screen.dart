import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/currency_formatter.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              _buildHeader(theme, l10n, userNameAsync),
              const SizedBox(height: 24),

              // --- PORTFOLIO SUMMARY (Side-by-Side Cards) ---
              _buildPortfolioSummary(theme, l10n, netWorthAsync, availableCashAsync,
                  currencyAsync.valueOrNull ?? 'USD'),
              const SizedBox(height: 32),

              // --- QUICK ACTIONS ---
              _buildQuickActions(theme, l10n),
              const SizedBox(height: 32),

              // --- RECENT ACTIVITY ---
              _buildRecentActivitySection(
                  theme, l10n, recentActivityAsync, currency, fxRate),

              // Bottom Scroll Padding
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
    final displayName = userNameAsync.when(
      data: (name) => name,
      loading: () => l10n.commonLoading,
      error: (_, __) => '',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardWelcomeBack,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildPortfolioSummary(ThemeData theme, AppLocalizations l10n,
      AsyncValue<double> netWorthAsync, AsyncValue<double> availableCashAsync,
      String currency) {
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        // Card 1: Invested Portfolio
        Expanded(
          child: Card(
            elevation: 0,
            color: colors.primaryContainer.withValues(alpha: 0.4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardInvestedPortfolio,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  netWorthAsync.when(
                    data: (value) => Text(
                      CurrencyFormatter.formatWithCurrency(value, currency),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    loading: () => SizedBox(
                      height: 24,
                      width: 80,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(4),
                        color: colors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    error: (_, __) => Text(
                      '--',
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Card 2: Cash to Invest
        Expanded(
          child: Card(
            elevation: 0,
            color: colors.tertiaryContainer.withValues(alpha: 0.4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardCashToInvest,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  availableCashAsync.when(
                    data: (value) => Text(
                      CurrencyFormatter.formatWithCurrency(value, currency),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    loading: () => SizedBox(
                      height: 24,
                      width: 80,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(4),
                        color: colors.tertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    error: (_, __) => Text(
                      '--',
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme, AppLocalizations l10n) {
    final actions = [
      (
        icon: Icons.trending_up,
        label: l10n.dashboardBuy,
        onTap: () => context.go('/home/buy-asset'),
      ),
      (
        icon: Icons.trending_down,
        label: l10n.dashboardSell,
        onTap: () => context.go('/home/sell-asset'),
      ),
      (
        icon: Icons.add_card,
        label: l10n.dashboardTopUp,
        onTap: () => context.go('/home/top-up'),
      ),
      (
        icon: Icons.file_download_outlined,
        label: l10n.dashboardWithdraw,
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const WithdrawBottomSheet(),
          );
        },
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((item) {
        return Column(
          children: [
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
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
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
