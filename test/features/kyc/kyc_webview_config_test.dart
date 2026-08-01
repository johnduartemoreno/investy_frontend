import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investy/features/kyc/presentation/kyc_webview_config.dart';

void main() {
  group('KycWebViewConfig.sumsubLang (B61)', () {
    test('passes through the languages the app ships', () {
      expect(KycWebViewConfig.sumsubLang('en'), 'en');
      expect(KycWebViewConfig.sumsubLang('es'), 'es');
      expect(KycWebViewConfig.sumsubLang('pt'), 'pt');
    });

    test('falls back to English for an unsupported locale', () {
      expect(KycWebViewConfig.sumsubLang('fr'), 'en');
      expect(KycWebViewConfig.sumsubLang(''), 'en');
    });
  });

  group('KycWebViewConfig.cssColor (B61)', () {
    test('renders a six-digit hex string without the alpha channel', () {
      expect(KycWebViewConfig.cssColor(const Color(0xFF0F0F13)), '#0f0f13');
      expect(KycWebViewConfig.cssColor(const Color(0xFFFFFFFF)), '#ffffff');
    });

    test('pads short values so the hex is always six digits', () {
      // Would render as "#f13" without padding, which CSS reads as a
      // completely different color.
      expect(KycWebViewConfig.cssColor(const Color(0xFF000F13)), '#000f13');
      expect(KycWebViewConfig.cssColor(const Color(0xFF000000)), '#000000');
    });

    test('ignores alpha — the WebView page is always opaque', () {
      expect(KycWebViewConfig.cssColor(const Color(0x000F0F13)), '#0f0f13');
    });
  });
}
