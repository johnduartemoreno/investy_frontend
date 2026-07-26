import '../../../l10n/app_localizations.dart';

/// Supported display currencies — must match the backend CHECK constraint.
/// Shared by the signup form and the Google Sign-In onboarding sheet (F5).
const kCurrencyCodes = [
  'USD', 'EUR', 'GBP', 'COP', 'BRL', 'MXN', 'CAD',
  'ARS', 'CLP', 'PEN', 'CHF', 'JPY', 'AUD', //
];

/// Localized name for an ISO 4217 [code]; falls back to the raw code.
String currencyLabel(AppLocalizations l10n, String code) {
  switch (code) {
    case 'USD':
      return l10n.currencyUSD;
    case 'EUR':
      return l10n.currencyEUR;
    case 'GBP':
      return l10n.currencyGBP;
    case 'COP':
      return l10n.currencyCOP;
    case 'BRL':
      return l10n.currencyBRL;
    case 'MXN':
      return l10n.currencyMXN;
    case 'CAD':
      return l10n.currencyCAD;
    case 'ARS':
      return l10n.currencyARS;
    case 'CLP':
      return l10n.currencyCLP;
    case 'PEN':
      return l10n.currencyPEN;
    case 'CHF':
      return l10n.currencyCHF;
    case 'JPY':
      return l10n.currencyJPY;
    case 'AUD':
      return l10n.currencyAUD;
    default:
      return code;
  }
}
