import 'package:flutter/material.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

/// Small gradient pill button — matches the COMPRAR/VENDER/Actualizar pattern from Owl AI.
/// Use [PrimaryButton] for full-width primary actions instead.
class GradientPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color>? colors;
  final Widget? leading;

  const GradientPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.colors,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        colors ?? [AppTheme.brandPurple, AppTheme.brandPurpleLight];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
