import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../../../features/dashboard/data/models/create_goal_request_model.dart';
import '../providers/rest_goals_provider.dart';

class CreateGoalSheet extends ConsumerStatefulWidget {
  const CreateGoalSheet({super.key});

  @override
  ConsumerState<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'car';
  DateTime? _selectedDeadline;
  bool _isLoading = false;
  double _amount = 0.0;

  static const _categories = [
    ('car', 'Car', Icons.directions_car),
    ('home', 'Home', Icons.home),
    ('vacation', 'Vacation', Icons.flight),
    ('education', 'Education', Icons.school),
    ('emergency', 'Emergency', Icons.shield),
    ('health', 'Health', Icons.favorite),
    ('other', 'Other', Icons.flag),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDeadline = picked);
  }

  String _toApiDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(dashboardRemoteDataSourceProvider).createGoal(
            userId,
            CreateGoalRequestModel(
              name: _nameController.text.trim(),
              targetAmountCents: (_amount * 100).round(),
              category: _selectedCategory,
              deadline: _toApiDate(_selectedDeadline!),
            ),
          );
      ref.invalidate(restGoalsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create goal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      // Ensures the sheet scrolls when keyboard appears
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Goal',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Goal name — hintText keeps label inside the field cleanly
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Goal name',
                prefixIcon: const Icon(Icons.flag_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a goal name' : null,
            ),
            const SizedBox(height: 20),

            // Target amount label
            Text(
              'Target Amount',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),

            // Large centered $ input with thousands separator
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                hintText: '0',
                hintStyle: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              onChanged: (value) {
                final parsed =
                    ThousandsSeparatorInputFormatter.parseFormatted(value);
                setState(() => _amount = parsed ?? 0.0);
              },
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a target amount';
                final parsed =
                    ThousandsSeparatorInputFormatter.parseFormatted(v);
                if (parsed == null || parsed <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Deadline picker
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDeadline != null
                          ? _displayDate(_selectedDeadline!)
                          : 'Select deadline',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _selectedDeadline != null
                            ? colorScheme.onSurface
                            : colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category label
            Text(
              'Category',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),

            // Category chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final isSelected = _selectedCategory == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(
                              color: colorScheme.primary, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.$3,
                            size: 16,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          c.$2,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Full-width confirm button (crossAxisAlignment.stretch handles width)
            PrimaryButton(
              text: 'Create Goal',
              isLoading: _isLoading,
              onPressed: _amount > 0 ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
