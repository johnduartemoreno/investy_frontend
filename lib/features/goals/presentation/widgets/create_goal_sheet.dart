import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../../../features/dashboard/data/models/create_goal_request_model.dart';
import '../providers/rest_goals_provider.dart';

/// Bottom sheet for creating a new financial goal.
/// Mirrors the visual style of WithdrawBottomSheet / TopUpScreen.
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
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  String _formatDeadline(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _displayDeadline(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

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

    final rawAmount = _amountController.text.replaceAll(',', '');
    final amountDouble = double.tryParse(rawAmount) ?? 0.0;
    final targetAmountCents = (amountDouble * 100).round();

    setState(() => _isLoading = true);
    try {
      await ref.read(dashboardRemoteDataSourceProvider).createGoal(
            userId,
            CreateGoalRequestModel(
              name: _nameController.text.trim(),
              targetAmountCents: targetAmountCents,
              category: _selectedCategory,
              deadline: _formatDeadline(_selectedDeadline!),
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
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Goal',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Goal name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Goal name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a goal name' : null,
            ),
            const SizedBox(height: 12),

            // Target amount
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: 'Target amount (\$)',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a target amount';
                final raw = v.replaceAll(',', '');
                final amount = double.tryParse(raw) ?? 0;
                if (amount <= 0) return 'Amount must be greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Deadline picker
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDeadline != null
                          ? _displayDeadline(_selectedDeadline!)
                          : 'Select deadline',
                      style: TextStyle(
                        color: _selectedDeadline != null
                            ? Colors.black87
                            : Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category selector
            Text('Category',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final isSelected = _selectedCategory == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(alpha: 0.12)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(color: primary, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.$3,
                            size: 16,
                            color: isSelected ? primary : Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          c.$2,
                          style: TextStyle(
                            color: isSelected ? primary : Colors.grey[700],
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
            const SizedBox(height: 24),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Create Goal',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
