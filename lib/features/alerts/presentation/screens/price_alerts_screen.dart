import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      backgroundColor: Colors.transparent,
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
              await ref
                  .read(alertFormControllerProvider.notifier)
                  .deleteAlert(alert.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.alertsDeleted)),
                );
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

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusBottomSheet)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusBottomSheet)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GradientSheetHeader(title: l10n.alertsCreateTitle),
            Padding(
              padding: EdgeInsets.only(
                left: AppDimens.spacingL,
                right: AppDimens.spacingL,
                top: AppDimens.spacingL,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Asset search
                    TextFormField(
                      controller: _searchController,
                      onChanged: _search,
                      decoration: InputDecoration(
                        hintText: l10n.alertsSearchHint,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    if (_results.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: AppDimens.spacingS),
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          shrinkWrap: true,
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

                    if (_selected != null) ...[
                      const SizedBox(height: AppDimens.spacingM),
                      Text(
                        l10n.alertsCurrentPrice(
                            CurrencyFormatter.format(_selected!.currentPrice)),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppDimens.spacingL),

                      // Direction toggle
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
                          const SizedBox(width: AppDimens.spacingS),
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
                      const SizedBox(height: AppDimens.spacingL),

                      // Target price
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          hintText: l10n.alertsTargetPriceHint,
                        ),
                      ),
                      const SizedBox(height: AppDimens.spacingXL),

                      PrimaryButton(
                        text: l10n.alertsCreateButton,
                        isLoading: formState is AsyncLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand gradient header band for the create-alert sheet — anchors the sheet
/// with the same visual language as the buy-asset and Owl AI flows.
class _GradientSheetHeader extends StatelessWidget {
  const _GradientSheetHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppDimens.spacingL, AppDimens.spacingM,
          AppDimens.spacingL, AppDimens.spacingL),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spacingL),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.spacingS),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_outlined,
                    color: AppTheme.brandPurple, size: 20),
              ),
              const SizedBox(width: AppDimens.spacingM),
              Expanded(
                child: Text(title,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
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
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppDimens.spacingM, horizontal: AppDimens.spacingS),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.brandPurple.withValues(alpha: 0.12)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
            color: selected
                ? AppTheme.brandPurple
                : cs.outline.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? AppTheme.brandPurple : cs.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          selected ? AppTheme.brandPurple : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    )),
          ],
        ),
      ),
    );
  }
}
