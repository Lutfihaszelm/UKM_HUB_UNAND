import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Full-width primary CTA with the mint-green gradient used across the
/// auth flow (e.g. "Masuk Sekarang").
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;
    return Opacity(
      opacity: disabled && isLoading ? 0.85 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled ? null : onPressed,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryButtonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(AppColors.textOnButton),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: AppTextStyles.button),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(trailingIcon, size: 18, color: AppColors.textOnButton),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
