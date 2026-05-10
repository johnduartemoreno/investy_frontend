import 'package:flutter/material.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: isDisabled
          ? BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radius),
            )
          : BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.brandPurple, AppTheme.brandPurpleLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppDimens.radius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandPurple.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.spacingL,
              horizontal: AppDimens.spacingXL,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: isDisabled ? cs.onSurface.withValues(alpha: 0.38) : Colors.white),
                          const SizedBox(width: AppDimens.spacingS),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDisabled
                                ? cs.onSurface.withValues(alpha: 0.38)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
