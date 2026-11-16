import 'package:flutter/material.dart';

/// Menampilkan gambar dari URL jaringan atau aset lokal.
///
/// Saat backend aktif, `logo_url`/`banner_url` berisi URL penuh. Untuk data
/// dummy, path aset Flutter juga didukung agar UI bisa dipakai sekarang.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String? path;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final source = path?.trim();
    if (source == null || source.isEmpty) {
      return fallback ?? const SizedBox.shrink();
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            fallback ?? const SizedBox.shrink(),
      );
    }

    return Image.asset(
      source,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          fallback ?? const SizedBox.shrink(),
    );
  }
}
