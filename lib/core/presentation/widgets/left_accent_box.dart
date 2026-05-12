import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Left purple border accent container — matches the Owl AI rec card reason text pattern.
/// Wraps any child with a 2px left border in brandPurple.
class LeftAccentBox extends StatelessWidget {
  final Widget child;
  final Color? color;

  const LeftAccentBox({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppTheme.brandPurple.withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: accentColor, width: 2),
        ),
      ),
      child: child,
    );
  }
}
