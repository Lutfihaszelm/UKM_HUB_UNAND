import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Outlined secondary button for "SSO Universitas Andalas".
class SsoButton extends StatelessWidget {
  const SsoButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceInput,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderInput),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, size: 20, color: AppColors.accentGold),
              const SizedBox(width: 10),
              Text(label, style: AppTextStyles.buttonSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
