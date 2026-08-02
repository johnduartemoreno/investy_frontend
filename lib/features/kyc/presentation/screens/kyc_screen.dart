import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    // ignore: depend_on_referenced_packages
    if (dart.library.html) 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'
    // ignore: depend_on_referenced_packages
    if (dart.library.html) 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../kyc_webview_config.dart';
import '../../data/datasources/kyc_remote_datasource.dart';
import '../../data/models/kyc_status_model.dart';
import '../providers/kyc_provider.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  bool _launching = false;

  Future<void> _startFlow() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _launching = true);
    try {
      // The liveness step needs a live camera feed. On Android the WebView's
      // own permission callback cannot grant what the OS has not granted to
      // the app first, so ask before launching the SDK.
      if (!await _ensureCameraPermission()) {
        if (mounted) setState(() => _launching = false);
        return;
      }

      final token =
          await ref.read(kycRemoteDataSourceProvider).initFlow(userId);
      if (!mounted) return;
      setState(() => _launching = false);

      // Resolved here (not in the WebView's initState) so the SDK inherits the
      // app's active locale and theme instead of hardcoded English on white.
      //
      // Both are fixed for the lifetime of the WebView, on purpose. KYC lives
      // inside a StatefulShellRoute branch, so this screen stays alive if the
      // user switches theme elsewhere — but applying the new theme means
      // re-initializing the Sumsub SDK, which would restart the verification.
      // A colour is never worth restarting a KYC flow; reopening picks it up.
      final lang = KycWebViewConfig.sumsubLang(
          Localizations.localeOf(context).languageCode);
      final theme = Theme.of(context);
      final surface = theme.colorScheme.surface;
      final sdkTheme = KycWebViewConfig.sumsubTheme(theme.brightness);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _SumsubWebViewScreen(
            accessToken: token,
            lang: lang,
            sdkTheme: sdkTheme,
            backgroundColor: surface,
            onTokenRefresh: () =>
                ref.read(kycRemoteDataSourceProvider).initFlow(userId),
            onCompleted: () {
              ref.invalidate(kycStatusProvider);
              if (mounted) setState(() {});
            },
          ),
        ),
      );
      ref.invalidate(kycStatusProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError)),
        );
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  /// Requests the OS camera permission on Android. iOS is left untouched —
  /// WKWebView drives its own prompt there and that flow already works.
  /// Returns true when the SDK can be launched.
  Future<bool> _ensureCameraPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    var status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (!status.isPermanentlyDenied) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) return true;

    if (mounted) _showCameraDeniedDialog();
    return false;
  }

  void _showCameraDeniedDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.kycCameraPermissionTitle),
        content: Text(l10n.kycCameraPermissionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: Text(l10n.kycOpenSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final kycAsync = ref.watch(kycStatusProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.kycTitle)),
      body: kycAsync.when(
        data: (kyc) => _buildContent(context, theme, l10n, kyc),
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, __) => Center(child: Text(l10n.commonError)),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    KycStatusModel kyc,
  ) {
    if (kyc.isApproved) return _buildApprovedState(context, theme, l10n);
    if (kyc.isSubmitted) return _buildPendingState(context, theme, l10n);
    if (kyc.isRejected) {
      return _buildActionState(
        context,
        theme,
        l10n,
        icon: Icons.error_outline,
        iconColor: theme.colorScheme.error,
        title: l10n.kycRejectedTitle,
        body: l10n.kycRejectedBody,
        buttonText: l10n.kycRetryButton,
      );
    }
    return _buildActionState(
      context,
      theme,
      l10n,
      icon: Icons.badge_outlined,
      iconColor: theme.colorScheme.primary,
      title: l10n.kycTitle,
      body: l10n.kycIntroBody,
      buttonText: l10n.kycStartButton,
      showRequirements: true,
    );
  }

  Widget _buildApprovedState(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user,
                size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: AppDimens.spacingL),
            Text(l10n.kycApprovedTitle,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimens.spacingM),
            Text(l10n.kycApprovedBody,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingState(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top,
                size: 80, color: theme.colorScheme.secondary),
            const SizedBox(height: AppDimens.spacingL),
            Text(l10n.kycPendingTitle,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimens.spacingM),
            Text(l10n.kycPendingBody,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildActionState(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String buttonText,
    bool showRequirements = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: AppDimens.spacingL),
          Text(title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppDimens.spacingM),
          Text(body,
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          if (showRequirements) ...[
            const SizedBox(height: AppDimens.spacingXL),
            _buildRequirementsList(theme, l10n),
          ],
          const SizedBox(height: AppDimens.spacingXL),
          PrimaryButton(
            text: buttonText,
            isLoading: _launching,
            onPressed: _startFlow,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsList(ThemeData theme, AppLocalizations l10n) {
    final items = [
      l10n.kycReqLegalName,
      l10n.kycReqDob,
      l10n.kycReqAddress,
      l10n.kycReqId,
      l10n.kycReqTaxId,
    ];
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: AppDimens.spacingM),
              Text(item, style: theme.textTheme.bodyMedium),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Sumsub WebSDK WebView ────────────────────────────────────────────────────

class _SumsubWebViewScreen extends StatefulWidget {
  final String accessToken;
  final String lang;
  final String sdkTheme;
  final Color backgroundColor;
  final Future<String> Function() onTokenRefresh;
  final VoidCallback onCompleted;

  const _SumsubWebViewScreen({
    required this.accessToken,
    required this.lang,
    required this.sdkTheme,
    required this.backgroundColor,
    required this.onTokenRefresh,
    required this.onCompleted,
  });

  @override
  State<_SumsubWebViewScreen> createState() => _SumsubWebViewScreenState();
}

class _SumsubWebViewScreenState extends State<_SumsubWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((msg) => debugPrint('[WebView] ${msg.message}'))
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (e) =>
            debugPrint('[WebView] resource error: ${e.url} — ${e.description}'),
      ))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: _onMessage,
      )
      ..loadHtmlString(_buildHtml(widget.accessToken),
          baseUrl: 'https://api.sumsub.com');

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _controller.platform as AndroidWebViewController;
      // Document upload from the gallery. Kept alongside the camera grant
      // below — the two are complementary: a document can come from a file,
      // the liveness check cannot.
      android.setOnShowFileSelector(_onShowFileSelector);
      // Without this callback Android denies every web permission request by
      // default, which is why the SDK reported "Allow access to your camera
      // and try again" with no way to grant it.
      android.setOnPlatformPermissionRequest(_onPermissionRequest);
    }
  }

  void _onPermissionRequest(PlatformWebViewPermissionRequest request) {
    // Logged so the Android UAT gives us evidence of what Sumsub actually
    // asks for. The spec says liveness is facial only and we deliberately did
    // not declare RECORD_AUDIO — if microphone shows up here in practice,
    // that is the evidence needed to revisit the decision (B61).
    debugPrint('[WebView] permission request: '
        '${request.types.map((t) => t.name).join(', ')}');

    if (request.types.contains(WebViewPermissionResourceType.camera)) {
      request.grant();
    } else {
      request.deny();
    }
  }

  Future<List<String>> _onShowFileSelector(FileSelectorParams params) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return [];
    return ['file://${picked.path}'];
  }

  void _onMessage(JavaScriptMessage msg) {
    try {
      final data = jsonDecode(msg.message) as Map<String, dynamic>;
      final event = data['event'] as String?;
      switch (event) {
        case 'submitted':
        case 'approved':
          widget.onCompleted();
          if (mounted) Navigator.of(context).pop();
        case 'tokenExpired':
          _refreshToken();
      }
    } catch (_) {}
  }

  Future<void> _refreshToken() async {
    try {
      final newToken = await widget.onTokenRefresh();
      await _controller.loadHtmlString(_buildHtml(newToken),
          baseUrl: 'https://api.sumsub.com');
    } catch (_) {}
  }

  String _buildHtml(String token) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    body { margin: 0; padding: 0; background: ${KycWebViewConfig.cssColor(widget.backgroundColor)}; }
    #sumsub-websdk-container { height: 100vh; width: 100vw; }
    #sdk-error { padding: 24px; color: red; font-family: sans-serif; }
  </style>
</head>
<body>
  <div id="sumsub-websdk-container"></div>
  <div id="sdk-error" style="display:none"></div>
  <script>
    function initSumsub(token) {
      try {
        var snsSdk = snsWebSdk.init(
          token,
          function() { window.FlutterChannel.postMessage(JSON.stringify({event:"tokenExpired"})); }
        )
        .withConf({ lang: "${widget.lang}", theme: "${widget.sdkTheme}" })
        .withOptions({ addViewportTag: false, adaptIframeHeight: true })
        .on("idCheck.onApplicantSubmitted", function() {
          window.FlutterChannel.postMessage(JSON.stringify({event:"submitted"}));
        })
        .on("idCheck.onApplicantReviewComplete", function(payload) {
          if (payload && payload.reviewResult && payload.reviewResult.reviewAnswer === "GREEN") {
            window.FlutterChannel.postMessage(JSON.stringify({event:"approved"}));
          } else {
            window.FlutterChannel.postMessage(JSON.stringify({event:"submitted"}));
          }
        })
        .build();
        snsSdk.launch("#sumsub-websdk-container");
      } catch(e) {
        console.error("Sumsub init error: " + e.message);
        document.getElementById("sdk-error").style.display = "block";
        document.getElementById("sdk-error").innerText = "Init error: " + e.message;
      }
    }

    var sdkScript = document.createElement("script");
    sdkScript.src = "https://static.sumsub.com/idensic/static/sns-websdk-builder.js";
    sdkScript.onload = function() {
      console.log("Sumsub SDK loaded OK");
      initSumsub("$token");
    };
    sdkScript.onerror = function(e) {
      console.error("Failed to load Sumsub SDK script");
      document.getElementById("sdk-error").style.display = "block";
      document.getElementById("sdk-error").innerText = "Could not load verification SDK. Check network.";
    };
    document.head.appendChild(sdkScript);
  </script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).kycTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
