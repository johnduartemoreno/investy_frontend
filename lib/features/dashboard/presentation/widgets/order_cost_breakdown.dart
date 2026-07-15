import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/trading_quote_model.dart';

/// Shows what an order actually costs, itemized, before the user commits.
///
/// Every number here comes from the server's quote — the same engine that executes
/// the order. Nothing is recomputed locally, so what is shown cannot drift from what
/// is charged.
class OrderCostBreakdown extends StatelessWidget {
  const OrderCostBreakdown({
    super.key,
    required this.quote,
    required this.isBuy,
  });

  final TradingQuoteModel quote;

  /// A buy ADDS its fees to what you pay; a sell SUBTRACTS them from what you get.
  final bool isBuy;

  String _chargeLabel(AppLocalizations l10n, String chargeType) {
    switch (chargeType) {
      case 'investy_commission':
        return l10n.tradingCommission;
      case 'sec_31':
        return l10n.tradingFeeSec31;
      case 'finra_taf':
        return l10n.tradingFeeFinraTaf;
      case 'finra_cat':
        return l10n.tradingFeeFinraCat;
      case 'broker_spread':
        return l10n.tradingFeeBrokerSpread;
    }
    // A charge type the client has not been taught yet must still be shown — an
    // unnamed fee is better than a hidden one.
    return chargeType;
  }

  /// USD, like the rest of the buy/sell flow. Deliberate: the trade leg is priced in
  /// the asset's settlement currency, and the user chose to keep it that way. No FX
  /// is applied here — introducing it would silently change what these screens mean.
  String _money(double usd) => CurrencyFormatter.format(usd);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row(theme, l10n.tradingSubtotal, _money(quote.totalBeforeFees)),
        for (final c in quote.components)
          _row(theme, _chargeLabel(l10n, c.chargeType), _money(c.fee)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingS),
          child: Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
        ),
        _row(
          theme,
          isBuy ? l10n.tradingTotalToPay : l10n.tradingYouReceive,
          _money(quote.total),
          emphasized: true,
        ),
      ],
    );
  }

  Widget _row(ThemeData theme, String label, String value,
      {bool emphasized = false}) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: emphasized
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: AppDimens.spacingS),
          Text(
            value,
            style: emphasized
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandPurpleLight,
                  )
                : theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
