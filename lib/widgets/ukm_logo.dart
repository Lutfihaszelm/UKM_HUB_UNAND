import 'package:flutter/material.dart';

/// Logo UKM berbentuk lingkaran, dengan placeholder jika logo kosong/gagal dimuat.
/// Sebelumnya kode ini diduplikasi di OprecDetailScreen dan OprecFormScreen.
class UkmLogo extends StatelessWidget {
  final String? assetPath;
  final double size;

  const UkmLogo({super.key, required this.assetPath, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Container(
      color: colors.primary,
      alignment: Alignment.center,
      child: Icon(Icons.groups, size: size * 0.55, color: colors.onPrimary),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: assetPath == null
            ? placeholder
            : Image.asset(
                assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

/// Baris "logo + nama UKM" yang dipakai di header kartu oprec.
class UkmHeader extends StatelessWidget {
  final String? logoAsset;
  final String ukmName;
  final TextStyle? nameStyle;

  const UkmHeader({
    super.key,
    required this.logoAsset,
    required this.ukmName,
    this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        UkmLogo(assetPath: logoAsset),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            ukmName,
            style: nameStyle ??
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
