import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/left_accent_box.dart';
import '../../../../core/presentation/widgets/signal_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/fit_score_model.dart';

/// Shows how well a purchase fits this user (S19-G7).
///
/// The layout follows the decision of 2026-08-11: **colour and sentences in
/// front, the number behind "see why"**. A score presiding over the screen
/// claims a precision that five components over a few weeks of data do not
/// have, and reads as advice — which is exactly the framing to avoid. The number
/// stays available to whoever looks for it, without asking anyone to interpret
/// a scale we never explained.
///
/// Nothing here computes a verdict. Every score, threshold and caveat arrives
/// decided from the backend; this widget maps reason keys to sentences and lays
/// them out.
class FitScoreCard extends StatefulWidget {
  const FitScoreCard({super.key, required this.fit, this.isHolding = false});

  final FitScoreModel fit;

  /// True on asset detail, where the card assesses the position already held
  /// rather than a purchase being composed (`amountCents: 0`).
  ///
  /// Several reason strings only make sense as one or the other. Saying "this
  /// purchase isn't tied to a goal" over something the user already owns is
  /// wrong twice: there is no purchase, and a goal cannot be attached to a
  /// holding at all — `goal_id` lives on `transactions`, so it is chosen when
  /// buying and never after (see B123). Found in UAT on a physical device,
  /// 2026-08-27, on the third pass over the same defect: the owl's prose and
  /// the disclaimer had already been fixed and these were missed both times.
  final bool isHolding;

  @override
  State<FitScoreCard> createState() => _FitScoreCardState();
}

class _FitScoreCardState extends State<FitScoreCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final fit = widget.fit;

    return CustomCard(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.fitTitle,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: cs.onSurface)),
              ),
              if (fit.showScore)
                SignalBadge(
                    label: _levelLabel(l10n), color: _levelColor(fit.score!)),
            ],
          ),
          const SizedBox(height: AppDimens.spacingM),
          if (fit.showScore)
            ..._verdict(theme, cs, l10n, fit)
          else
            ..._cannotAssess(theme, cs, l10n, fit),
        ],
      ),
    );
  }

  /// The front of the card: the goal it was measured against, the owl's
  /// sentences, and the toggle that reveals everything behind them.
  List<Widget> _verdict(ThemeData theme, ColorScheme cs, AppLocalizations l10n,
      FitScoreModel fit) {
    return [
      if (fit.goalName.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.spacingS),
          child: Text(l10n.fitForGoal(fit.goalName),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ),
      // The owl's prose when it survived validation, otherwise the components'
      // own sentences. The card must read the same either way: the model is an
      // enhancement here, never the content.
      if (fit.explanation.isNotEmpty)
        LeftAccentBox(
          child: Text(fit.explanation,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: cs.onSurface, height: 1.45)),
        )
      else
        ..._headlineReasons(theme, cs, l10n, fit),
      if (fit.cappedBy.isNotEmpty) ...[
        const SizedBox(height: AppDimens.spacingM),
        _note(theme, cs, _cappedLabel(l10n, fit.cappedBy),
            color: AppTheme.signalAmber),
      ],
      const SizedBox(height: AppDimens.spacingM),
      _toggle(theme, l10n),
      if (_expanded) ..._breakdown(theme, cs, l10n, fit),
      // The disclaimer lives here, outside the collapsed section. It used to sit
      // inside the breakdown, which meant the one case where it matters — a
      // verdict about a purchase, right above the buy button — was the only
      // case where it was hidden. Found by the S19 audit, 2026-08-12.
      const SizedBox(height: AppDimens.spacingM),
      _disclaimer(theme, cs, l10n),
    ];
  }

  /// Fallback for when there is no prose: the two components that moved the
  /// score furthest from the middle, which is what a person would mention first.
  List<Widget> _headlineReasons(ThemeData theme, ColorScheme cs,
      AppLocalizations l10n, FitScoreModel fit) {
    final scored = fit.components.all.where((c) => c.scored).toList()
      ..sort((a, b) => (a.score! - 50).abs().compareTo((b.score! - 50).abs()));
    // A reason the app does not know yet renders as nothing, so it must be
    // dropped here rather than laid out — an empty Text still takes its padding,
    // which is a visible gap where the sentence should have been.
    final headline = scored.reversed
        .where((c) => _reasonText(l10n, c.reason, kind: c.kind).isNotEmpty)
        .take(2);

    return [
      for (final c in headline)
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.spacingS),
          child: LeftAccentBox(
            child: Text(_reasonText(l10n, c.reason, kind: c.kind),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurface, height: 1.4)),
          ),
        ),
    ];
  }

  /// Below the confidence threshold the score is not shown — and it is not
  /// present in the payload either. What replaces it is not an apology: it is
  /// the list of things that would let us answer.
  List<Widget> _cannotAssess(ThemeData theme, ColorScheme cs,
      AppLocalizations l10n, FitScoreModel fit) {
    return [
      Text(l10n.fitCantAssessTitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
      const SizedBox(height: AppDimens.spacingXS),
      Text(l10n.fitCantAssessBody,
          style:
              theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      if (fit.confidence.aboutYou.isNotEmpty) ...[
        const SizedBox(height: AppDimens.spacingM),
        Text(l10n.fitAboutYouTitle,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: AppTheme.brandPurpleLight)),
        const SizedBox(height: AppDimens.spacingXS),
        for (final reason in fit.confidence.aboutYou)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spacingXS),
            child: LeftAccentBox(
              child: Text(_reasonText(l10n, reason),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurface)),
            ),
          ),
      ],
      ..._ourDataNote(theme, cs, l10n, fit),
      const SizedBox(height: AppDimens.spacingM),
      _disclaimer(theme, cs, l10n),
    ];
  }

  /// Our own gaps, kept visually apart from the user's. Telling someone to
  /// complete their profile is useful; telling them we lack price history is an
  /// apology, and running the two together makes our problem look like their
  /// homework.
  List<Widget> _ourDataNote(ThemeData theme, ColorScheme cs,
      AppLocalizations l10n, FitScoreModel fit) {
    if (fit.confidence.aboutOurData.isEmpty) return const [];
    return [
      const SizedBox(height: AppDimens.spacingM),
      Text(l10n.fitAboutOurDataTitle,
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: AppDimens.spacingXS),
      for (final reason in fit.confidence.aboutOurData)
        Text(_reasonText(l10n, reason),
            style:
                theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
    ];
  }

  Widget _toggle(ThemeData theme, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_expanded ? l10n.fitHide : l10n.fitWhy,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: AppTheme.brandPurpleLight)),
          Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppTheme.brandPurpleLight),
        ],
      ),
    );
  }

  /// Everything behind "see why": the number, the five components, the
  /// confidence, and the disclaimer.
  List<Widget> _breakdown(ThemeData theme, ColorScheme cs,
      AppLocalizations l10n, FitScoreModel fit) {
    return [
      const SizedBox(height: AppDimens.spacingM),
      Text(l10n.fitScoreOutOf(fit.score!),
          style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700, color: _levelColor(fit.score!))),
      const SizedBox(height: AppDimens.spacingM),
      for (final c in fit.components.all) _componentRow(theme, cs, l10n, c, fit),
      const SizedBox(height: AppDimens.spacingS),
      Text(l10n.fitConfidence(fit.confidence.pct),
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ..._ourDataNote(theme, cs, l10n, fit),
    ];
  }

  Widget _componentRow(ThemeData theme, ColorScheme cs, AppLocalizations l10n,
      FitComponentModel c, FitScoreModel fit) {
    final showVolatility = c.kind == FitComponentKind.volatility &&
        fit.volatilityPct != null &&
        c.scored;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(_componentLabel(l10n, c.kind),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurface)),
              ),
              // An unmeasured component reads "not measured", never "0". A zero
              // says the fit is bad; the two are different statements and the
              // whole design depends on not blurring them (§Data Governance).
              c.scored
                  ? Text('${c.score}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: _componentColor(c),
                          fontWeight: FontWeight.w700))
                  : Text(l10n.fitUnmeasured,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppDimens.spacingXS),
          Text(_reasonText(l10n, c.reason, kind: c.kind),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.35)),
          if (showVolatility)
            Text(
                l10n.fitVolatilityObserved(
                    fit.volatilityPct!.toStringAsFixed(0)),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          if (c.caveat.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.spacingXS),
              child:
                  _note(theme, cs, _caveatText(l10n, c.caveat), color: AppTheme.signalAmber),
            ),
        ],
      ),
    );
  }

  Widget _note(ThemeData theme, ColorScheme cs, String text,
      {required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 13, color: color),
        const SizedBox(width: AppDimens.spacingXS),
        Expanded(
          child: Text(text,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.35)),
        ),
      ],
    );
  }

  /// Always present, on both branches of the card. The framing this sprint
  /// settled on is that Investy describes a relationship between a purchase and
  /// what the user told us — never what to do about it.
  Widget _disclaimer(ThemeData theme, ColorScheme cs, AppLocalizations l10n) {
    return Text(l10n.fitDisclaimer,
        style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant, height: 1.3, fontStyle: FontStyle.italic));
  }

  /// The badge wording follows the score, not the confidence level: confidence
  /// already decided whether there is a score to show at all, and showing both
  /// as words would give the user two scales to reconcile.
  String _levelLabel(AppLocalizations l10n) {
    final score = widget.fit.score ?? 0;
    if (score >= 75) return l10n.fitLevelHigh;
    if (score >= 45) return l10n.fitLevelMedium;
    return l10n.fitLevelLow;
  }

  /// Colour for a component's number in the breakdown (B118).
  ///
  /// Concentration does not use the generic 75/45 scale, because it does not
  /// mean the same thing. Its bands are prudence decisions written in the
  /// backend (`fit/entity.go`: 10% / 25% / 40%), and the linear score between
  /// them lands the green→amber boundary at 17.5% of the portfolio. That left
  /// 10–17.5% painting the number green while the sentence right underneath
  /// warned the position was "big enough to move your portfolio on its own" —
  /// in the band a user is most likely to be in, and the sentence was the half
  /// that was right. A 15% single position is not a small part of anything.
  ///
  /// So this component's colour comes from the same classification as its
  /// words. One source, so the two cannot disagree: the reason IS the colour.
  /// Every other component keeps the numeric scale — this is the one whose
  /// meaning is defined by thresholds rather than by the number itself.
  Color _componentColor(FitComponentModel c) {
    switch (c.reason) {
      case 'concentration_low':
        return AppTheme.signalGreen;
      case 'concentration_mid':
        return AppTheme.signalAmber;
      case 'concentration_high':
        return AppTheme.signalRed;
    }
    return _levelColor(c.score!);
  }

  Color _levelColor(int score) {
    if (score >= 75) return AppTheme.signalGreen;
    if (score >= 45) return AppTheme.signalAmber;
    return AppTheme.signalRed;
  }

  String _cappedLabel(AppLocalizations l10n, String cappedBy) {
    switch (cappedBy) {
      case 'concentration':
        return l10n.fitCappedConcentration;
      case 'horizon':
        return l10n.fitCappedHorizon;
      case 'class_not_in_plan':
        return l10n.fitCappedClassNotInPlan;
      default:
        return '';
    }
  }

  String _componentLabel(AppLocalizations l10n, FitComponentKind kind) {
    switch (kind) {
      case FitComponentKind.profile:
        return l10n.fitComponentProfile;
      case FitComponentKind.horizon:
        return l10n.fitComponentHorizon;
      case FitComponentKind.diversification:
        return l10n.fitComponentDiversification;
      case FitComponentKind.concentration:
        return l10n.fitComponentConcentration;
      case FitComponentKind.volatility:
        return l10n.fitComponentVolatility;
    }
  }

  String _caveatText(AppLocalizations l10n, String caveat) {
    switch (caveat) {
      case 'short_window':
        return l10n.fitCaveatShortWindow;
      default:
        return '';
    }
  }

  /// Maps a backend reason key to a sentence.
  ///
  /// An unknown key renders as nothing rather than as the raw key. A new reason
  /// shipped by the server before the app knows it would otherwise print
  /// `class_not_in_plan` at someone, which is worse than a shorter card.
  ///
  /// [kind] disambiguates a reason key that two components legitimately share.
  /// `class_not_in_plan` is returned for both profile and diversification —
  /// deliberately, per `entity.go:142-147`: "does it belong?" and "how far does
  /// it push you off?" are different questions that happen to have the same
  /// answer. That comment says G1 states it "in its own words", and until now it
  /// did not: both rows rendered the same sentence, so the breakdown showed one
  /// line twice and read like a rendering fault. Callers without a component —
  /// the confidence lists — pass nothing and get the profile wording.
  String _reasonText(AppLocalizations l10n, String reason,
      {FitComponentKind? kind}) {
    switch (reason) {
      case 'no_profile':
        return l10n.fitReasonNoProfile;
      case 'class_not_in_plan':
        return kind == FitComponentKind.diversification
            ? l10n.fitReasonClassNotInPlanMix
            : l10n.fitReasonClassNotInPlan;
      case 'class_core':
        return l10n.fitReasonClassCore;
      case 'class_supporting':
        return l10n.fitReasonClassSupporting;
      case 'no_goal':
        return widget.isHolding
            ? l10n.fitReasonNoGoalHolding
            : l10n.fitReasonNoGoal;
      case 'horizon_comfortable':
        return l10n.fitReasonHorizonComfortable;
      case 'horizon_tight':
        return l10n.fitReasonHorizonTight;
      case 'horizon_too_short':
        return l10n.fitReasonHorizonTooShort;
      case 'no_portfolio':
        // Same shape as class_not_in_plan above: diversification and
        // concentration both report it, and one sentence cannot serve both.
        // "no mix to compare against" is right under "effect on your mix" and
        // plainly wrong under "weight in your portfolio", which does not
        // measure the mix at all.
        return kind == FitComponentKind.concentration
            ? l10n.fitReasonNoPortfolioWeight
            : l10n.fitReasonNoPortfolio;
      case 'fills_gap':
        return widget.isHolding
            ? l10n.fitReasonFillsGapHolding
            : l10n.fitReasonFillsGap;
      case 'near_target':
        return l10n.fitReasonNearTarget;
      case 'over_target':
        return l10n.fitReasonOverTarget;
      case 'concentration_low':
        return l10n.fitReasonConcentrationLow;
      case 'concentration_mid':
        return l10n.fitReasonConcentrationMid;
      case 'concentration_high':
        return l10n.fitReasonConcentrationHigh;
      case 'no_history':
        return l10n.fitReasonNoHistory;
      case 'vol_calm':
        return l10n.fitReasonVolCalm;
      case 'vol_typical':
        return l10n.fitReasonVolTypical;
      case 'vol_elevated':
        return l10n.fitReasonVolElevated;
      case 'vol_extreme':
        return l10n.fitReasonVolExtreme;
      default:
        return '';
    }
  }
}


/// The card's frame while a new assessment is in flight.
///
/// Exists because the card used to render only on `data`: changing the goal
/// re-fetches, and for the length of that round trip the card **vanished** and
/// then came back. Nothing was wrong, but a block of the screen disappearing
/// while you use a control reads as a bug — and a user who thinks the screen
/// broke stops trusting the number when it returns.
///
/// It deliberately does not keep the previous verdict on screen. That answer
/// was computed for a different goal, and showing it as if it still applied
/// would be worse than showing nothing: it would be a confident, wrong
/// statement about the purchase being composed right now.
class FitScoreCardLoading extends StatelessWidget {
  const FitScoreCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return CustomCard(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.fitTitle,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

/// Shown when the assessment could not be produced at all.
///
/// Says so in one line rather than leaving a hole in the layout. The purchase
/// does not depend on this card, so the message is quiet — but silence here
/// would be indistinguishable from the bug this pair of widgets exists to fix.
class FitScoreCardUnavailable extends StatelessWidget {
  const FitScoreCardUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return CustomCard(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: cs.onSurfaceVariant),
          const SizedBox(width: AppDimens.spacingS),
          Expanded(
            child: Text(l10n.fitUnavailable,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
