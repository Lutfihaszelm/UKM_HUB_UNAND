import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kartu putih membulat dengan bayangan hijau — gaya kartu standar aplikasi.
/// Sebelumnya dekorasi ini ditulis ulang di setiap screen.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
  });

  /// Dekorasi yang sama, dipakai juga untuk elemen non-kartu (mis. poster).
  static BoxDecoration decoration({Color? color}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.brandShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration(color: color ?? Colors.white),
      child: child,
    );
  }
}
