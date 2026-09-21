import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Glowing logo badge shown on Splash & Login.
///
/// NOTE: renders a placeholder campus icon since the real UKM Hub Unand
/// logo asset hasn't been exported from Figma yet. Once available, drop
/// it at `assets/images/2.0x/logo.webp` (+ 3.0x) and swap the [Icon]
/// below for an `Image.asset('assets/images/logo.webp')`.
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({
    super.key,
    this.size = 88,
    this.isCircle = true,
  });

  final double size;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final radius = isCircle ? size / 2 : size * 0.28;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGreen.withValues(alpha: 0.35),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.apartment_rounded,
        size: size * 0.42,
        color: AppColors.accentGold,
      ),
    );
  }
}
