import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/gradient_icon_box.dart';
import '../../../../core/presentation/widgets/left_accent_box.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/owl_session_model.dart';
import '../../data/models/recommendation_model.dart';
import '../providers/owl_history_provider.dart';

/// Semantic gradient pairs per ticker (mirrors dashboard rec cards).
const Map<String, List<Color>> _tickerColors = {
  'AAPL': [Color(0xFF1d4ed8), Color(0xFF3b82f6)],
  'VTI': [Color(0xFF065f46), Color(0xFF10b981)],
  'BTC': [Color(0xFF78350f), Color(0xFFf59e0b)],
  'MSFT': [AppTheme.brandPurple, AppTheme.brandPurpleLight],
  'IAU': [Color(0xFF881337), Color(0xFFf43f5e)],
};

List<Color> _tickerGradient(String ticker) =>
    _tickerColors[ticker] ?? [AppTheme.brandPurple, AppTheme.brandPurpleLight];

/// Owl AI recommendation session history (B29).
class OwlHistoryScreen extends ConsumerWidget {
  const OwlHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(owlHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.owlHistoryTitle,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: historyAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, __) => Center(child: Text(l10n.commonError)),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.spacingXL),
                child: Text(
                  l10n.owlHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            );
          }
          return SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              itemCount: sessions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.spacingM),
              itemBuilder: (context, index) =>
                  _SessionCard(session: sessions[index]),
            ),
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final OwlSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final local = session.createdAt.toLocal();
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;

    return GestureDetector(
      onTap: () => _showSessionDetail(context, session),
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GradientIconBox(
                  colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
                  circle: true,
                  child: Icon(Icons.auto_awesome_rounded,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: AppDimens.spacingM),
                Expanded(
                  child: Text(
                    DateFormat.yMMMd().format(local),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                SignalBadge(
                  label: l10n.owlHistoryDaysAgo(days),
                  color: cs.primary,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spacingM),
            Wrap(
              spacing: AppDimens.spacingS,
              runSpacing: AppDimens.spacingS,
              children: [
                for (final ticker in session.tickers)
                  SignalBadge(label: ticker, color: AppTheme.brandPurpleLight),
              ],
            ),
            const SizedBox(height: AppDimens.spacingM),
            Text(
              l10n.owlHistoryContext(
                CurrencyFormatter.format(
                    session.contextSnapshot.portfolioValue),
                CurrencyFormatter.format(session.contextSnapshot.cashBalance),
              ),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSessionDetail(BuildContext context, OwlSessionModel session) {
  final cs = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      // expand: false — the sheet sizes itself, so the dimmed barrier above
      // stays tappable to dismiss.
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusBottomSheet)),
        ),
        child: _OwlHistoryDetailSheet(
            session: session, scrollController: scrollController),
      ),
    ),
  );
}

/// Read-only view of one past session — same card language as the live sheet.
class _OwlHistoryDetailSheet extends StatelessWidget {
  const _OwlHistoryDetailSheet({
    required this.session,
    required this.scrollController,
  });

  final OwlSessionModel session;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final local = session.createdAt.toLocal();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingL, vertical: AppDimens.spacingM),
          child: Row(
            children: [
              Expanded(
                child: LeftAccentBox(
                  child: Text(
                    l10n.owlHistorySessionBanner(
                        DateFormat.yMMMd().format(local)),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.brandPurpleLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Same close affordance as the live Owl sheet header.
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.close, color: cs.onSurfaceVariant, size: 16),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
                AppDimens.spacingL, 0, AppDimens.spacingL, AppDimens.spacingXL),
            itemCount: session.recommendations.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.spacingM),
            itemBuilder: (context, index) =>
                _RecCard(rec: session.recommendations[index]),
          ),
        ),
      ],
    );
  }
}

class _RecCard extends StatelessWidget {
  const _RecCard({required this.rec});

  final RecommendationModel rec;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIconBox(
                colors: _tickerGradient(rec.ticker),
                child: Text(
                  rec.ticker.substring(0, rec.ticker.length.clamp(0, 4)),
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
                    Text(rec.ticker,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      rec.name,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SignalBadge(
                label:
                    rec.strong ? l10n.owlAiStrongBuy : l10n.owlAiModerateSignal,
                color: rec.strong ? AppTheme.signalGreen : AppTheme.signalAmber,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingM),
          LeftAccentBox(
            child: Text(
              rec.reason,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
            ),
          ),
          const SizedBox(height: AppDimens.spacingM),
          Row(
            children: [
              Text(
                l10n.owlAiSuggested,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: AppDimens.spacingXS),
              Text(
                CurrencyFormatter.format(rec.suggestedAmountCents / 100.0),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.brandPurpleLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
