import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

/// Labeled dark input field matching the Login screen design
/// (leading icon, optional trailing action, rounded surface).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.leadingIcon,
    this.controller,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final String hintText;
  final IconData leadingIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderInput),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: AppTextStyles.inputText,
            cursorColor: AppColors.accentGreen,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.inputPlaceholder,
              prefixIcon: Icon(leadingIcon, size: 20, color: AppColors.iconMuted),
              suffixIcon: trailing,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
