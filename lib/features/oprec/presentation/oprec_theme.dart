import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Tema halaman Open Recruitment (hijau #2C6E49 + kartu putih).
/// Dipasang lewat widget Theme di route oprec, jadi tidak mengubah tema screen lain.
ThemeData buildOprecTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.brandGreen)
      .copyWith(primary: AppColors.brandGreen, onPrimary: Colors.white);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.brandBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.brandGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: AppColors.brandShadow,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
