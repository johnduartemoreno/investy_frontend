import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/currency_formatter.dart';

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

/// Returns the appropriate icon for a contribution type.
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

/// Returns the appropriate color for a contribution type.
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

/// Returns a capitalized title for the contribution type.
String _getContributionTitle(String type) {
  if (type.isEmpty) return 'Unknown';
  return type[0].toUpperCase() + type.substring(1);
}

/// Formats date for display.
String _formatContributionDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) {
    return 'Today, ${DateFormat.jm().format(date)}';
  } else if (dateOnly == yesterday) {
    return 'Yesterday, ${DateFormat.jm().format(date)}';
  } else {
    return DateFormat.yMMMd().format(date);
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
  // Local UI State (Ephemeral)
  // Privacy toggle removed as per new design spec (always visible)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              _buildHeader(theme, userNameAsync),
              const SizedBox(height: 24),

              // --- PORTFOLIO SUMMARY (Side-by-Side Cards) ---
              _buildPortfolioSummary(theme, netWorthAsync, availableCashAsync,
                  currencyAsync.valueOrNull ?? 'USD'),
              const SizedBox(height: 32),

              // --- QUICK ACTIONS ---
              _buildQuickActions(theme),
              const SizedBox(height: 32),

              // --- RECENT ACTIVITY ---
              _buildRecentActivitySection(
                  theme, recentActivityAsync, currency, fxRate),

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
      ThemeData theme, AsyncValue<String> userNameAsync) {
    final displayName = userNameAsync.when(
      data: (name) => name,
      loading: () => 'Loading...',
      error: (_, __) => 'Investor',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
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

  Widget _buildPortfolioSummary(ThemeData theme,
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
                    'Invested Portfolio',
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
                    'Cash to Invest',
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

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      (
        icon: Icons.trending_up,
        label: 'Buy',
        onTap: () => context.go('/home/buy-asset'),
      ),
      (
        icon: Icons.trending_down,
        label: 'Sell',
        onTap: () => context.go('/home/sell-asset'),
      ),
      (
        icon: Icons.add_card,
        label: 'Top-up',
        onTap: () => context.go('/home/top-up'),
      ),
      (
        icon: Icons.file_download_outlined,
        label: 'Withdraw',
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

  Widget _buildRecentActivitySection(ThemeData theme,
      AsyncValue<List<ActivityItem>> recentActivityAsync,
      String currency, double fxRate) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        recentActivityAsync.when(
          data: (items) => items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No recent activity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  children: items
                      .map((item) =>
                          _buildActivityItem(theme, item, currency, fxRate))
                      .toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              'Error loading activity: $error',
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
      ThemeData theme, ActivityItem item, String currency, double fxRate) {
    return switch (item) {
      ActivityItemTransaction(:final transaction) =>
        _buildTransactionActivityItem(theme, transaction, currency, fxRate),
      ActivityItemContribution(:final contribution) =>
        _buildContributionActivityItem(theme, contribution, currency, fxRate),
    };
  }

  Widget _buildTransactionActivityItem(
      ThemeData theme, Transaction transaction, String currency, double fxRate) {
    final isBuy = transaction.type.toLowerCase() == 'buy';
    final icon = isBuy ? Icons.trending_up : Icons.trending_down;
    final color = isBuy ? Colors.green : Colors.red;
    final title =
        isBuy ? 'Bought ${transaction.symbol}' : 'Sold ${transaction.symbol}';
    final dateStr = _formatContributionDate(transaction.createdAt);

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
      ThemeData theme, Contribution contribution, String currency, double fxRate) {
    final isWithdrawal = contribution.type == 'withdrawal';
    final icon = _getContributionIcon(contribution.type);
    final color = _getContributionColor(contribution.type);
    final title = _getContributionTitle(contribution.type);
    final dateStr = _formatContributionDate(contribution.createdAt);

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
