import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Logo badge shown on Splash & Login using the official Unand Building emblem.
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
        color: Colors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: isCircle
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(radius),
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Image.asset(
            'assets/images/Logo_PKM_Hub_Unand-removebg-preview.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.apartment_rounded,
                size: size * 0.5,
                color: AppColors.primaryGreenDark,
              );
            },
          ),
        ),
      ),
    );
  }
}
