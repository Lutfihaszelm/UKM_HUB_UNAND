import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/coming_soon_screen.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../application/auth_controller.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/circular_checkbox.dart';
import '../widgets/gradient_button.dart';
import '../widgets/sso_button.dart';
import '../../../../utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrNimController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailOrNimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await ref.read(authControllerProvider.notifier).submitLogin(
          emailOrNim: _emailOrNimController.text,
          password: _passwordController.text,
        );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _openPlaceholder(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ComingSoonScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppSpacing.xl),
                          const AppLogoBadge(size: 68),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Login MyPKM',
                            style: AppTextStyles.h1.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ' Ayo Kenali PKM di Universitas Andalas',
                            style: AppTextStyles.bodyRegular.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                    // Card Form Putih dengan Border Halus & Soft Shadow
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            AuthTextField(
                              label: 'Email Mahasiswa',
                              hintText: 'Masukkan Email Anda',
                              leadingIcon: Icons.mail_outline_rounded,
                              controller: _emailOrNimController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              label: 'Kata Sandi Portal',
                              hintText: '••••••••••••',
                              leadingIcon: Icons.lock_outline_rounded,
                              controller: _passwordController,
                              obscureText: authState.obscurePassword,
                              textInputAction: TextInputAction.done,
                              trailing: IconButton(
                                icon: Icon(
                                  authState.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: const Color(0xFF64748B),
                                ),
                                onPressed: () => ref
                                    .read(authControllerProvider.notifier)
                                    .toggleObscurePassword(),
                              ),
                              validator: Validators.password,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                CircularCheckbox(
                                  value: authState.rememberMe,
                                  onChanged: (_) => ref
                                      .read(authControllerProvider.notifier)
                                      .toggleRememberMe(),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Ingat saya',
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    color: const Color(0xFF334155),
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _openPlaceholder('Lupa Sandi'),
                                  child: Text(
                                    'Lupa Sandi?',
                                    style: AppTextStyles.link.copyWith(
                                      color: const Color(0xFF2C6E49),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (authState.errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                authState.errorMessage!,
                                style: AppTextStyles.bodyRegular.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            GradientButton(
                              label: 'Masuk Sekarang',
                              trailingIcon: Icons.arrow_forward_rounded,
                              isLoading: authState.isSubmitting,
                              onPressed: _handleSubmit,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                  child: Text(
                                    'ATAU MASUK RESMI VIA',
                                    style: AppTextStyles.caption.copyWith(
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0)),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SsoButton(
                              label: 'SSO Universitas Andalas',
                              onPressed: () => _openPlaceholder('SSO Universitas Andalas'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Mahasiswa baru belum punya akun? ',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
                          child: Text(
                            'Aktivasi Akun',
                            style: AppTextStyles.link.copyWith(
                              color: const Color(0xFF2C6E49),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
        _AuthFooter(onTap: _openPlaceholder),
      ],
    ),
  ),
),
);
}
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FooterLink(
            icon: Icons.headset_mic_outlined,
            label: 'Helpdesk IT Kampus',
            onTap: () => onTap('Helpdesk IT Kampus'),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('•', style: AppTextStyles.caption.copyWith(color: const Color(0xFFCBD5E1))),
          const SizedBox(width: AppSpacing.md),
          _FooterLink(
            icon: Icons.shield_outlined,
            label: 'Privasi Data',
            onTap: () => onTap('Privasi Data'),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
