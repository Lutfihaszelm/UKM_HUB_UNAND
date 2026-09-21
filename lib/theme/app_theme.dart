import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgGradientBottom,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryGreenDark,
        secondary: AppColors.accentGreen,
        surface: AppColors.surfaceCard,
        error: AppColors.error,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accentGreen,
        selectionColor: Color(0x554ADE9C),
        selectionHandleColor: AppColors.accentGreen,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceCard,
        contentTextStyle: AppTextStyles.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
