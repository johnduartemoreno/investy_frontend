import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
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
      final token =
          await ref.read(kycRemoteDataSourceProvider).initFlow(userId);
      if (!mounted) return;
      setState(() => _launching = false);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _SumsubWebViewScreen(
            accessToken: token,
            onTokenRefresh: () => ref
                .read(kycRemoteDataSourceProvider)
                .initFlow(userId),
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
        context, theme, l10n,
        icon: Icons.error_outline,
        iconColor: theme.colorScheme.error,
        title: l10n.kycRejectedTitle,
        body: l10n.kycRejectedBody,
        buttonText: l10n.kycRetryButton,
      );
    }
    return _buildActionState(
      context, theme, l10n,
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
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium),
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
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium),
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
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium),
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
  final Future<String> Function() onTokenRefresh;
  final VoidCallback onCompleted;

  const _SumsubWebViewScreen({
    required this.accessToken,
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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: _onMessage,
      )
      ..loadHtmlString(_buildHtml(widget.accessToken));
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
      await _controller.loadHtmlString(_buildHtml(newToken));
    } catch (_) {}
  }

  String _buildHtml(String token) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    body { margin: 0; padding: 0; background: #fff; }
    #sumsub-websdk-container { height: 100vh; width: 100vw; }
  </style>
</head>
<body>
  <div id="sumsub-websdk-container"></div>
  <script src="https://static.sumsub.com/idensic/static/sns-websdk-builder.js"></script>
  <script>
    var snsSdk = snsWebSdkBuilder.init(
      "$token",
      function() { window.FlutterChannel.postMessage(JSON.stringify({event:"tokenExpired"})); }
    )
    .withConf({ lang: "en" })
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
