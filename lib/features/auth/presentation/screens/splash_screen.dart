import 'package:flutter/material.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../widgets/app_logo_badge.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(flex: 3),
                const AppLogoBadge(size: 96, isCircle: false),
                const SizedBox(height: AppSpacing.lg),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.h1.copyWith(fontSize: 26, letterSpacing: 0.5),
                    children: [
                      const TextSpan(text: 'UKM HUB '),
                      TextSpan(
                        text: 'UNAND',
                        style: TextStyle(color: AppColors.accentGreen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Portal Organisasi & Kegiatan Mahasiswa',
                  style: AppTextStyles.bodyRegular,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded, size: 14, color: AppColors.accentGreen),
                      const SizedBox(width: 6),
                      Text('Universitas Andalas', style: AppTextStyles.badge),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceInput,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Menghubungkan ke Kampus...', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('v1.0.0 • Limau Manis Campus Edition', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
