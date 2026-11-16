import 'package:flutter/material.dart';

import 'app_image.dart';

/// Logo UKM dengan fallback ikon berwarna.
///
/// `logoUrl` dari API adalah URL penuh; data dummy boleh memakai path aset.
class UkmLogoView extends StatelessWidget {
  const UkmLogoView({
    super.key,
    required this.logoUrl,
    required this.fallbackIcon,
    required this.color,
    this.size = 56,
  });

  final String? logoUrl;
  final IconData fallbackIcon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: color.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: color, size: size * 0.48),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppImage(path: logoUrl, fit: BoxFit.cover, fallback: fallback),
    );
  }
}
