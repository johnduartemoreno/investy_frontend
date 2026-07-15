import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investy/features/dashboard/presentation/trading_error_localizer.dart';
import 'package:investy/l10n/app_localizations.dart';

/// Builds the AppLocalizations for a locale without spinning up a widget tree.
Future<AppLocalizations> l10nFor(String code) =>
    AppLocalizations.delegate.load(Locale(code));

DioException backendError(String code) => DioException(
      requestOptions: RequestOptions(path: '/transactions'),
      response: Response(
        requestOptions: RequestOptions(path: '/transactions'),
        statusCode: 400,
        data: {'code': code},
      ),
    );

void main() {
  test('ERR_ORDER_TOO_SMALL on a buy names the actual minimum', () async {
    final l10n = await l10nFor('en');
    final msg = localizeTradingError(l10n, backendError('ERR_ORDER_TOO_SMALL'),
        minBuyNotionalCents: 100);

    // The UAT failure this fixes: the user saw "Something went wrong" for a rule
    // the server states very precisely.
    expect(msg, contains('\$1.00'));
    expect(msg, isNot(contains('went wrong')));
  });

  test('the minimum comes from the server, not a hardcoded dollar', () async {
    final l10n = await l10nFor('en');
    // If the floor ever moves (it is policy, not a constant), the copy follows.
    final msg = localizeTradingError(l10n, backendError('ERR_ORDER_TOO_SMALL'),
        minBuyNotionalCents: 500);
    expect(msg, contains('\$5.00'));
  });

  test('the same code on a sell says something different', () async {
    final l10n = await l10nFor('en');
    final msg = localizeTradingError(l10n, backendError('ERR_ORDER_TOO_SMALL'),
        isSell: true);

    // Sells have no $1 minimum — the fees swallowing the proceeds is the real cause.
    expect(msg, isNot(contains('\$1.00')));
    expect(msg.toLowerCase(), contains('fees'));
  });

  test('insufficient funds keeps its own message', () async {
    final l10n = await l10nFor('en');
    expect(localizeTradingError(l10n, backendError('ERR_INSUFFICIENT_FUNDS')),
        l10n.buyInsufficientFunds);
  });

  test('an unknown code falls back to the generic message', () async {
    final l10n = await l10nFor('en');
    expect(localizeTradingError(l10n, backendError('ERR_SOMETHING_NEW')),
        l10n.commonError);
  });

  test('a non-Dio error does not crash the localizer', () async {
    final l10n = await l10nFor('en');
    expect(localizeTradingError(l10n, Exception('boom')), l10n.commonError);
    expect(localizeTradingError(l10n, null), l10n.commonError);
  });

  test('the minimum is translated', () async {
    for (final loc in ['es', 'pt']) {
      final l10n = await l10nFor(loc);
      final msg = localizeTradingError(
          l10n, backendError('ERR_ORDER_TOO_SMALL'),
          minBuyNotionalCents: 100);
      expect(msg, contains('\$1.00'),
          reason: 'locale $loc must keep the amount');
      expect(msg, isNot(contains('went wrong')), reason: 'locale $loc');
    }
  });
}
