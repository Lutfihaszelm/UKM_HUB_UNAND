import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Outlined button for "SSO Universitas Andalas" with white surface and subtle border.
class SsoButton extends StatelessWidget {
  const SsoButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, size: 20, color: Color(0xFFD97706)),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.buttonSecondary.copyWith(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
