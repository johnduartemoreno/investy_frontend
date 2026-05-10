import 'package:flutter/material.dart';
import '../../theme/app_dimens.dart';

/// Gradient square (or circle) icon box — matches the Owl AI rec card ticker icon pattern.
/// Use [radius] for rounded square (default), set [circle] = true for circular shape.
class GradientIconBox extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final double size;
  final double radius;
  final bool circle;

  const GradientIconBox({
    super.key,
    required this.colors,
    required this.child,
    this.size = 40,
    this.radius = AppDimens.radiusAssetIcon,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: circle ? null : BorderRadius.circular(radius),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
