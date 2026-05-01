import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/risk_remote_datasource.dart';
import '../providers/risk_provider.dart';

class RiskQuestionnaireScreen extends ConsumerStatefulWidget {
  const RiskQuestionnaireScreen({super.key});

  @override
  ConsumerState<RiskQuestionnaireScreen> createState() =>
      _RiskQuestionnaireScreenState();
}

class _RiskQuestionnaireScreenState
    extends ConsumerState<RiskQuestionnaireScreen> {
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};
  bool _isLoading = false;

  List<_Question> _buildQuestions(AppLocalizations l10n) => [
        _Question(
          text: l10n.riskProfileQ1,
          options: [
            l10n.riskProfileQ1A1,
            l10n.riskProfileQ1A2,
            l10n.riskProfileQ1A3,
            l10n.riskProfileQ1A4,
          ],
        ),
        _Question(
          text: l10n.riskProfileQ2,
          options: [
            l10n.riskProfileQ2A1,
            l10n.riskProfileQ2A2,
            l10n.riskProfileQ2A3,
            l10n.riskProfileQ2A4,
          ],
        ),
        _Question(
          text: l10n.riskProfileQ3,
          options: [
            l10n.riskProfileQ3A1,
            l10n.riskProfileQ3A2,
            l10n.riskProfileQ3A3,
            l10n.riskProfileQ3A4,
          ],
        ),
        _Question(
          text: l10n.riskProfileQ4,
          options: [
            l10n.riskProfileQ4A1,
            l10n.riskProfileQ4A2,
            l10n.riskProfileQ4A3,
            l10n.riskProfileQ4A4,
          ],
        ),
        _Question(
          text: l10n.riskProfileQ5,
          options: [
            l10n.riskProfileQ5A1,
            l10n.riskProfileQ5A2,
            l10n.riskProfileQ5A3,
            l10n.riskProfileQ5A4,
          ],
        ),
      ];

  Future<void> _submit(AppLocalizations l10n) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(riskRemoteDataSourceProvider)
          .submitAnswers(userId, _answers);
      ref.invalidate(riskProfileProvider);
      if (mounted) context.pushReplacement('/settings/risk-profile/result');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.riskProfileLoadError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOptionSelected(int questionIndex, int optionValue,
      List<_Question> questions, AppLocalizations l10n) {
    setState(() => _answers[questionIndex + 1] = optionValue);
    final isLast = _currentQuestion == questions.length - 1;
    if (!isLast) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _currentQuestion++);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questions = _buildQuestions(l10n);
    final q = questions[_currentQuestion];
    final selectedOption = _answers[_currentQuestion + 1];
    final isLast = _currentQuestion == questions.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.riskProfileTitle),
        centerTitle: true,
        leading: _currentQuestion > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    setState(() => _currentQuestion--),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / questions.length,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
            const SizedBox(height: AppDimens.spacingS),
            Text(
              l10n.riskProfileQuestionOf(
                  _currentQuestion + 1, questions.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: AppDimens.spacingXL),

            // Question text
            Text(
              q.text,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimens.spacingXL),

            // Options
            ...List.generate(q.options.length, (i) {
              final optionValue = i + 1;
              final isSelected = selectedOption == optionValue;
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimens.spacingM),
                child: _OptionTile(
                  label: q.options[i],
                  isSelected: isSelected,
                  onTap: () => _onOptionSelected(
                      _currentQuestion, optionValue, questions, l10n),
                ),
              );
            }),

            const Spacer(),

            if (isLast)
              PrimaryButton(
                text: l10n.riskProfileSubmit,
                isLoading: _isLoading,
                onPressed: selectedOption != null
                    ? () => _submit(l10n)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _Question {
  final String text;
  final List<String> options;
  const _Question({required this.text, required this.options});
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingL,
          vertical: AppDimens.spacingM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primaryContainer
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
