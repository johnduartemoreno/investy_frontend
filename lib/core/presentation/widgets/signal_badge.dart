import 'package:flutter/material.dart';
import '../../theme/app_dimens.dart';

/// Outlined pill badge with semantic color — matches the Owl AI signal badge pattern.
/// Used for: "Compra fuerte", "Moderado", return percentages, status labels.
class SignalBadge extends StatelessWidget {
  final String label;
  final Color color;

  const SignalBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
