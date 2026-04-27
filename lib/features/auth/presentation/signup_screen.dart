import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

// Supported display currencies — must match backend CHECK constraint.
const _kCurrencies = [
  ('USD', 'US Dollar'),
  ('EUR', 'Euro'),
  ('GBP', 'British Pound'),
  ('COP', 'Colombian Peso'),
  ('BRL', 'Brazilian Real'),
  ('MXN', 'Mexican Peso'),
  ('CAD', 'Canadian Dollar'),
  ('ARS', 'Argentine Peso'),
  ('CLP', 'Chilean Peso'),
  ('PEN', 'Peruvian Sol'),
  ('CHF', 'Swiss Franc'),
  ('JPY', 'Japanese Yen'),
  ('AUD', 'Australian Dollar'),
];

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _lastShownError;
  String _displayCurrency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _currencyLabel(String code) =>
      _kCurrencies.firstWhere((c) => c.$1 == code, orElse: () => (code, code)).$2;

  Future<void> _pickCurrency(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Display Currency',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                ..._kCurrencies.map((c) => ListTile(
                      title: Text('${c.$1} — ${c.$2}'),
                      trailing: _displayCurrency == c.$1
                          ? Icon(Icons.check,
                              color: colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() => _displayCurrency = c.$1);
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      _lastShownError = null;
      ref.invalidate(authNotifierProvider);
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          ref.read(authNotifierProvider.notifier).signUp(
                _nameController.text.trim(),
                _emailController.text.trim(),
                _passwordController.text,
                _displayCurrency,
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    ref.listen(authNotifierProvider, (previous, next) {
      if (mounted) {
        setState(() => _isLoading = next.isLoading);
        if (next.isLoading) return;

        if (!next.isLoading && next.hasValue && next.value != null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          _lastShownError = null;
          context.go('/verify-email');
        } else if (next.hasError && !next.isLoading) {
          final errorMessage = next.error.toString();
          if (_lastShownError != errorMessage) {
            _lastShownError = errorMessage;
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Branding header — same visual language as login
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: isKeyboardOpen ? screenHeight * 0.12 : screenHeight * 0.28,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 4,
                    left: 4,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: colorScheme.onPrimaryContainer),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  // Logo + title
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          elevation: 4.0,
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding:
                                EdgeInsets.all(isKeyboardOpen ? 10 : 16),
                            child: Icon(
                              Icons.savings_outlined,
                              size: isKeyboardOpen ? 24 : 44,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        if (!isKeyboardOpen) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Investy',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Card(
                        elevation: 0,
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Create Account',
                                  style:
                                      textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start your investment journey today.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 28),

                                // Full Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Full Name',
                                    prefixIcon:
                                        Icon(Icons.person_outline),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                          ? 'Full name is required'
                                          : null,
                                ),
                                const SizedBox(height: 16),

                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon:
                                        Icon(Icons.email_outlined),
                                  ),
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!_isValidEmail(value.trim())) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon:
                                        const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons
                                                .visibility_off_outlined,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                      tooltip: _obscurePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Minimum 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    prefixIcon:
                                        const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword),
                                    ),
                                  ),
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _signUp(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Display currency selector
                                InkWell(
                                  onTap: () => _pickCurrency(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      hintText: 'Display Currency',
                                      prefixIcon:
                                          Icon(Icons.currency_exchange),
                                      suffixIcon:
                                          Icon(Icons.arrow_drop_down),
                                    ),
                                    child: Text(
                                      '$_displayCurrency — ${_currencyLabel(_displayCurrency)}',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Sign Up button
                                SizedBox(
                                  height: 56,
                                  child: FilledButton(
                                    onPressed:
                                        _isLoading ? null : _signUp,
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child:
                                                CircularProgressIndicator(
                                              color:
                                                  colorScheme.onPrimary,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'Sign Up',
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  colorScheme.onPrimary,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                            color:
                                                colorScheme.outlineVariant)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'Or continue with',
                                        style:
                                            textTheme.bodySmall?.copyWith(
                                          color:
                                              colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            color:
                                                colorScheme.outlineVariant)),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Google Sign-In button
                                OutlinedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () => ref
                                          .read(
                                              authNotifierProvider.notifier)
                                          .signInWithGoogle(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                        color: colorScheme.outline),
                                  ),
                                  icon: Icon(
                                    Icons.g_mobiledata,
                                    size: 28,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  label: Text(
                                    'Continue with Google',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Already have an account?
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
