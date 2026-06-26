import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../../dashboard/data/models/asset_search_result_model.dart';
import '../../data/datasources/alerts_remote_data_source.dart';
import '../../data/models/price_alert_model.dart';
import '../controllers/alert_form_controller.dart';
import '../providers/alerts_provider.dart';

class PriceAlertsScreen extends ConsumerWidget {
  const PriceAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alertsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openCreateSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: alertsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (_, __) => Center(child: Text(l10n.commonError)),
          data: (alerts) => alerts.isEmpty
              ? _EmptyState(l10n: l10n)
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.spacingL),
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.spacingM),
                  itemBuilder: (_, i) => _AlertTile(alert: alerts[i]),
                ),
        ),
      ),
    );
  }

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _CreateAlertSheet(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active_outlined,
                size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: AppDimens.spacingL),
            Text(l10n.alertsEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppDimens.spacingS),
            Text(l10n.alertsEmptyHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends ConsumerWidget {
  const _AlertTile({required this.alert});
  final PriceAlertModel alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final price = CurrencyFormatter.format(alert.targetPrice);
    final condition = alert.isAbove
        ? l10n.alertsConditionAbove(price)
        : l10n.alertsConditionBelow(price);

    return CustomCard(
      padding: const EdgeInsets.all(AppDimens.spacingM),
      child: Row(
        children: [
          GradientIconBox(
            colors: const [AppTheme.brandPurple, AppTheme.brandPurpleLight],
            child: Text(
              alert.symbol.substring(0, alert.symbol.length.clamp(0, 4)),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: AppDimens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.symbol,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      alert.isAbove
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(condition,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          SignalBadge(
            label: alert.isActive
                ? l10n.alertsStatusActive
                : l10n.alertsStatusTriggered,
            color: alert.isActive ? AppTheme.signalGreen : cs.onSurfaceVariant,
          ),
          IconButton(
            tooltip: l10n.alertsDeleteTooltip,
            icon: Icon(Icons.delete_outline,
                size: 20, color: cs.onSurfaceVariant),
            onPressed: () async {
              final userId = ref.read(currentUserIdProvider);
              if (userId == null) return;
              try {
                await ref
                    .read(alertsRemoteDataSourceProvider)
                    .deleteAlert(userId, alert.id);
                ref.invalidate(alertsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.alertsDeleted)),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.commonError)),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CreateAlertSheet extends ConsumerStatefulWidget {
  const _CreateAlertSheet();

  @override
  ConsumerState<_CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends ConsumerState<_CreateAlertSheet> {
  final _searchController = TextEditingController();
  final _priceController = TextEditingController();
  List<AssetSearchResultModel> _results = [];
  AssetSearchResultModel? _selected;
  String _direction = 'above';

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final results = await ref
        .read(dashboardRemoteDataSourceProvider)
        .searchAssets(query.trim());
    if (mounted) {
      setState(() => _results = results);
    }
  }

  void _select(AssetSearchResultModel asset) {
    setState(() {
      _selected = asset;
      _results = [];
      _searchController.text = asset.symbol;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _submit() async {
    final asset = _selected;
    final l10n = AppLocalizations.of(context);
    if (asset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.alertsSelectAssetFirst)),
      );
      return;
    }
    final dollars =
        ThousandsSeparatorInputFormatter.parseFormatted(_priceController.text);
    if (dollars == null || dollars <= 0) return;

    await ref.read(alertFormControllerProvider.notifier).createAlert(
          symbol: asset.symbol,
          direction: _direction,
          targetPriceCents: (dollars * 100).round(),
        );
  }

  String _mapError(Object? err, AppLocalizations l10n) {
    if (err is DioException) {
      final code = err.response?.statusCode;
      final bodyCode = err.response?.data is Map
          ? (err.response?.data as Map)['code']
          : null;
      if (bodyCode == 'ERR_ASSET_NOT_FOUND') {
        return l10n.alertsErrorUnknownSymbol;
      }
      if (bodyCode == 'ERR_DUPLICATE_ALERT') {
        return l10n.alertsErrorDuplicate;
      }
      if (code == 409) return l10n.alertsErrorLimit;
      if (code == 400) return l10n.alertsErrorAlreadyMet;
    }
    return l10n.commonError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final formState = ref.watch(alertFormControllerProvider);

    ref.listen(alertFormControllerProvider, (prev, next) {
      if (next is AsyncData && prev is AsyncLoading) {
        // Refresh the list BEFORE popping: this ref is still alive here, whereas
        // the controller is disposed by the pop, so invalidating from there is
        // dropped and the new alert never appears in the list.
        ref.invalidate(alertsProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.alertsCreated)),
        );
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mapError(next.error, l10n))),
        );
      }
    });

    // Tall sheet (≈92% of the safe area) with all fields visible from the start
    // and the button pinned at the bottom — matches the height/feel of
    // create_goal_sheet. useSafeArea on the modal keeps the title clear of the notch.
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (fixed)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.alertsCreateTitle,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Scrollable fields
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Asset
                  Text(l10n.alertsAssetLabel,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _searchController,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: l10n.alertsSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  if (_results.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final a = _results[i];
                          return ListTile(
                            dense: true,
                            title: Text(a.symbol,
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            subtitle: Text(a.name,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Text(
                                CurrencyFormatter.format(a.currentPrice),
                                style: theme.textTheme.bodySmall),
                            onTap: () => _select(a),
                          );
                        },
                      ),
                    ),
                  // Current price — only once an asset is picked
                  if (_selected != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          l10n.alertsCurrentPrice(CurrencyFormatter.format(
                              _selected!.currentPrice)),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Condition
                  Text(l10n.alertsConditionLabel,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DirectionChip(
                          label: l10n.alertsDirectionAbove,
                          icon: Icons.trending_up_rounded,
                          selected: _direction == 'above',
                          onTap: () => setState(() => _direction = 'above'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DirectionChip(
                          label: l10n.alertsDirectionBelow,
                          icon: Icons.trending_down_rounded,
                          selected: _direction == 'below',
                          onTap: () => setState(() => _direction = 'below'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Target price
                  Text(l10n.alertsTargetPriceHint,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      hintText: '0',
                      hintStyle: theme.textTheme.headlineMedium?.copyWith(
                        color: cs.outline.withValues(alpha: 0.4),
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Create button — pinned at the bottom
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 16),
            child: PrimaryButton(
              text: l10n.alertsCreateButton,
              isLoading: formState is AsyncLoading,
              onPressed: formState is AsyncLoading ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionChip extends StatelessWidget {
  const _DirectionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: cs.primary, width: 1.5)
              : Border.all(color: cs.outlineVariant, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}
