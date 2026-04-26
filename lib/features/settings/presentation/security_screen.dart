import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  bool _isGoogleUser() {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    return user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGoogle = _isGoogleUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(context, 'Account Security'),
            const SizedBox(height: AppDimens.spacingM),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _tile(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: isGoogle ? 'Managed by Google' : null,
                    enabled: !isGoogle,
                    onTap: () => _showChangePassword(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spacingXL),
            _sectionLabel(context, 'Danger Zone'),
            const SizedBox(height: AppDimens.spacingM),
            CustomCard(
              padding: EdgeInsets.zero,
              child: _tile(
                context,
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                subtitle: 'Permanently delete all your data',
                iconColor: Theme.of(context).colorScheme.error,
                titleColor: Theme.of(context).colorScheme.error,
                onTap: () => _showDeleteConfirm(context, ref, isGoogle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool enabled = true,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: enabled ? (iconColor ?? cs.primary) : cs.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled ? titleColor : cs.onSurfaceVariant,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: enabled
          ? Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant)
          : null,
      onTap: enabled ? onTap : null,
    );
  }

  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, bool isGoogle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all data — holdings, goals, and transaction history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDeleteAuth(context, ref, isGoogle);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAuth(BuildContext context, WidgetRef ref, bool isGoogle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DeleteAccountSheet(isGoogle: isGoogle, ref: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Change Password Sheet
// ---------------------------------------------------------------------------

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser!;
      final cred = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);
      if (mounted) Navigator.of(context).pop();
    } on firebase_auth.FirebaseAuthException catch (e) {
      setState(() {
        _error = _mapError(e.code);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
        _loading = false;
      });
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect.';
      case 'weak-password':
        return 'New password is too weak. Use at least 6 characters.';
      case 'requires-recent-login':
        return 'Please sign out and sign back in before changing your password.';
      default:
        return 'Failed to change password. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.spacingL,
        right: AppDimens.spacingL,
        top: AppDimens.spacingXL,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change Password',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimens.spacingXL),
              CustomTextField(
                controller: _currentCtrl,
                label: 'Current password',
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppDimens.spacingM),
              CustomTextField(
                controller: _newCtrl,
                label: 'New password',
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppDimens.spacingM),
              CustomTextField(
                controller: _confirmCtrl,
                label: 'Confirm new password',
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != _newCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: AppDimens.spacingM),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: AppDimens.spacingXL),
              PrimaryButton(
                text: 'Update Password',
                isLoading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delete Account Sheet — reauthenticate then delete
// ---------------------------------------------------------------------------

class _DeleteAccountSheet extends StatefulWidget {
  final bool isGoogle;
  final WidgetRef ref;

  const _DeleteAccountSheet({required this.isGoogle, required this.ref});

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notifier = widget.ref.read(authNotifierProvider.notifier);
      if (widget.isGoogle) {
        await notifier.deleteAccountGoogle();
      } else {
        if (_passwordCtrl.text.isEmpty) {
          setState(() {
            _error = 'Please enter your password.';
            _loading = false;
          });
          return;
        }
        await notifier.deleteAccountEmail(_passwordCtrl.text);
      }
      if (mounted) {
        Navigator.of(context).pop();
        context.go('/login');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.spacingL,
        right: AppDimens.spacingL,
        top: AppDimens.spacingXL,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirm Deletion',
                style:
                    theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimens.spacingM),
            Text(
              widget.isGoogle
                  ? 'Re-authenticate with Google to confirm account deletion.'
                  : 'Enter your password to confirm account deletion.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppDimens.spacingXL),
            if (!widget.isGoogle)
              CustomTextField(
                controller: _passwordCtrl,
                label: 'Your password',
                obscureText: true,
              ),
            if (_error != null) ...[
              const SizedBox(height: AppDimens.spacingM),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            ],
            const SizedBox(height: AppDimens.spacingXL),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                padding: const EdgeInsets.all(AppDimens.spacingL),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radius)),
              ),
              onPressed: _loading ? null : _delete,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Text('Delete My Account',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
