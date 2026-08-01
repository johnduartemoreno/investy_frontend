import 'package:flutter/material.dart';

/// Pure helpers that adapt the Sumsub WebSDK page to the app's locale and
/// theme. Extracted from the KYC screen so they can be unit tested (B61).
class KycWebViewConfig {
  const KycWebViewConfig._();

  /// Languages the Sumsub WebSDK is configured for in this app.
  static const supportedLanguages = {'en', 'es', 'pt'};

  /// Maps the app locale to a language the Sumsub WebSDK understands.
  /// Anything else falls back to English rather than showing a broken UI.
  static String sumsubLang(String languageCode) =>
      supportedLanguages.contains(languageCode) ? languageCode : 'en';

  /// Renders a theme color as a CSS hex string, so the page behind the Sumsub
  /// card follows the app theme instead of a hardcoded white block.
  static String cssColor(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
