import 'package:dio/dio.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';

/// Maps a backend trading error code to a localized, actionable message.
///
/// Mirrors [localizeAuthError]: the backend speaks error CODES, the client owns the
/// copy. Before this, the buy screen special-cased `ERR_INSUFFICIENT_FUNDS` with an
/// inline `if` and collapsed everything else into "Something went wrong" — so the
/// $1 minimum, which the server rejects very precisely, reached the user as noise.
String localizeTradingError(
  AppLocalizations l10n,
  Object? error, {
  /// The order floor, in USD cents, as reported by /trading/config.
  int minBuyNotionalCents = 100,

  /// True when the failed order was a sell — the same code means a different thing:
  /// a buy is under the minimum, a sell cannot cover its own fees.
  bool isSell = false,
}) {
  switch (_codeOf(error)) {
    case 'ERR_INSUFFICIENT_FUNDS':
      return l10n.buyInsufficientFunds;
    case 'ERR_ORDER_TOO_SMALL':
      return isSell
          ? l10n.tradingSellTooSmall
          : l10n.tradingOrderTooSmall(
              CurrencyFormatter.format(minBuyNotionalCents / 100.0),
            );
    case 'ERR_ASSET_NOT_FOUND':
      return l10n.commonError;
    default:
      return l10n.commonError;
  }
}

/// Extracts the backend error code from a Dio failure, if there is one.
String? _codeOf(Object? error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  if (data is! Map) return null;
  return data['code'] as String?;
}
