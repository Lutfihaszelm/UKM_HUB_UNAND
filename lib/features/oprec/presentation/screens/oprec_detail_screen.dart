import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/oprec_post.dart';
import '../../models/registration.dart';
import '../../data/oprec_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_card.dart';
import 'oprec_form_screen.dart';

const _namaBulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', //
  'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

/// Contoh: 17 Agustus 2026 (waktu lokal HP).
String _formatDate(DateTime d) {
  final local = d.toLocal();
  return '${local.day} ${_namaBulan[local.month - 1]} ${local.year}';
}

class OprecDetailScreen extends StatefulWidget {
  final OprecPost post;
  final OprecRepository repository;

  const OprecDetailScreen({
    super.key,
    required this.post,
    required this.repository,
  });

  @override
  State<OprecDetailScreen> createState() => _OprecDetailScreenState();
}

class _OprecDetailScreenState extends State<OprecDetailScreen> {
  // Tinggi sheet info (bagian dari tinggi layar): awal dan saat ditarik penuh.
  static const _sheetMin = 0.42;
  static const _sheetMax = 0.92;

  Registration? _registration;
  double _sheetExtent = _sheetMin;

  bool get _hasActiveRegistration =>
      _registration != null &&
      _registration!.status != RegistrationStatus.dibatalkan;

  // ---------- Aksi ----------
  Future<void> _openForm() async {
    // Kirim post + repository ke form, lalu TUNGGU hasil yang dikembalikan
    final theme = Theme.of(context); // bawa tema oprec ke halaman form
    final result = await Navigator.push<Registration>(
      context,
      MaterialPageRoute(
        builder: (context) => Theme(
          data: theme,
          child: OprecFormScreen(
            post: widget.post,
            repository: widget.repository,
          ),
        ),
      ),
    );

    // result == null berarti user menekan back tanpa mendaftar
    if (result == null || !mounted) return;

    setState(() => _registration = result);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Pendaftaran terkirim!')),
      );
  }

  // ---------- Tombol ----------
  String get _buttonLabel {
    if (_hasActiveRegistration) {
      return 'Sudah Mendaftar · ${_registration!.status.label}';
    }
    if (widget.post.isClosed) return 'Pendaftaran Ditutup';
    return 'Daftar Sekarang';
  }

  VoidCallback? get _buttonAction {
    if (_hasActiveRegistration || widget.post.isClosed) return null;
    return _openForm;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Poster makin buram saat sheet ditarik ke atas.
    final pulled =
        ((_sheetExtent - _sheetMin) / (_sheetMax - _sheetMin)).clamp(0.0, 1.0);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * (1 - _sheetMin) + 32, // terselip di bawah sheet
            child: _PosterImage(assetPath: post.posterAsset, blur: pulled * 10),
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() => _sheetExtent = notification.extent);
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: _sheetMin,
              minChildSize: _sheetMin,
              maxChildSize: _sheetMax,
              builder: (context, scrollController) => _InfoSheet(
                scrollController: scrollController,
                children: [
                  _OprecHeader(post: post),
                  if (_registration != null)
                    _RegistrationCard(registration: _registration!),
                  if (post.requirements.isNotEmpty)
                    _BulletCard(
                      title: 'Syarat Pendaftaran',
                      items: post.requirements,
                      collapsible: true,
                    ),
                  if (post.requiredFiles.isNotEmpty)
                    _BulletCard(
                      title: 'Berkas yang diunggah',
                      items: [
                        for (final file in post.requiredFiles)
                          file.isRequired
                              ? file.label
                              : '${file.label} (opsional)',
                      ],
                    ),
                  if (post.terms.isNotEmpty)
                    _BulletCard(
                      title: 'Syarat dan Ketentuan Berlaku',
                      items: post.terms,
                      collapsible: true,
                    ),
                ],
              ),
            ),
          ),
          const _BackButton(),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        label: _buttonLabel,
        onPressed: _buttonAction,
      ),
    );
  }
}

// =====================================================================
// Widget-widget kecil penyusun halaman (hasil pemecahan build() yang panjang)
// =====================================================================

/// Poster oprec memenuhi bagian atas layar, fallback ke placeholder.
class _PosterImage extends StatelessWidget {
  final String? assetPath;
  final double blur;
  const _PosterImage({required this.assetPath, required this.blur});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Container(
      alignment: Alignment.center,
      color: colors.primaryContainer,
      child: Icon(Icons.campaign_outlined, size: 72, color: colors.primary),
    );

    final image = assetPath == null
        ? placeholder
        : Image.asset(
            assetPath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => placeholder,
          );
    if (blur < 0.1) return image;
    return ClipRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: image,
      ),
    );
  }
}

/// Tombol kembali bulat di atas poster.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            foregroundColor: AppColors.textPrimary,
          ),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}

/// Sheet putih yang bisa ditarik, berisi info oprec.
class _InfoSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> children;
  const _InfoSheet({required this.scrollController, required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        // Ruang bawah supaya isi terakhir tidak tertutup tombol.
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderInput,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// Logo UKM persegi + nama, deskripsi, dan tanggal tutup.
class _OprecHeader extends StatelessWidget {
  final OprecPost post;
  const _OprecHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final placeholder = Container(
      color: colors.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.groups, size: 56, color: colors.primary),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: post.logoUKM == null
              ? placeholder
              : Image.asset(
                  post.logoUKM!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => placeholder,
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.ukmName,
                style: textTheme.titleLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.description,
                style: textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 10),
              Text(
                'Ditutup : ${_formatDate(post.closeDate)}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu hijau berisi daftar poin. Bila [collapsible], hanya 3 poin pertama
/// yang tampil sampai user menekan "lihat selengkapnya".
class _BulletCard extends StatefulWidget {
  final String title;
  final List<String> items;
  final bool collapsible;

  const _BulletCard({
    required this.title,
    required this.items,
    this.collapsible = false,
  });

  @override
  State<_BulletCard> createState() => _BulletCardState();
}

class _BulletCardState extends State<_BulletCard> {
  static const _collapsedCount = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canExpand =
        widget.collapsible && widget.items.length > _collapsedCount;
    final visible = canExpand && !_expanded
        ? widget.items.take(_collapsedCount)
        : widget.items;
    const onCard = AppColors.textOnButton;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.brandGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.brandShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: textTheme.titleMedium
                      ?.copyWith(color: onCard, fontWeight: FontWeight.w700),
                ),
              ),
              if (canExpand)
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Text(
                        _expanded ? 'tutup' : 'lihat selengkapnya',
                        style: textTheme.labelSmall?.copyWith(color: onCard),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.chevron_right,
                        size: 18,
                        color: onCard,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in visible)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ',
                      style: textTheme.bodyLarge?.copyWith(color: onCard)),
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodyLarge?.copyWith(color: onCard),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Kartu ringkasan pendaftaran milik user.
class _RegistrationCard extends StatelessWidget {
  final Registration registration;
  const _RegistrationCard({required this.registration});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final files = registration.files.map((f) => f.name).join(', ');

    return AppCard(
      color: colors.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Pendaftaranmu',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Nama: ${registration.name} (${registration.nim})',
              style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Prodi: ${registration.prodi}', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('WhatsApp: ${registration.whatsapp}',
              style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Status: ${registration.status.label}',
              style: textTheme.bodyMedium),
          if (files.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Berkas: $files', style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 4),
          Text(
            'Dikirim: ${_formatDate(registration.createdAt)}',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Panel kaca berisi tombol aksi utama di bagian bawah layar.
class _BottomActionBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _BottomActionBar({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.actionBlue,
                  foregroundColor: AppColors.textOnButton,
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                onPressed: onPressed,
                child: Text(label.toUpperCase()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
