import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Temporary placeholder for screens not yet designed/implemented.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientBottom,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, color: AppColors.accentGreen, size: 40),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Halaman ini belum tersedia.',
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
