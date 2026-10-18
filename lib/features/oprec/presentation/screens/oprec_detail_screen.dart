import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/oprec_post.dart';
import '../../models/registration.dart';
import '../../data/oprec_repository.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/ukm_logo.dart';
import 'oprec_form_screen.dart';

String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

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
  Registration? _registration;

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
    if (_registration != null) {
      return 'Sudah Mendaftar · ${_registration!.status.label}';
    }
    if (widget.post.isClosed) return 'Pendaftaran Ditutup';
    return 'Daftar Sekarang';
  }

  VoidCallback? get _buttonAction {
    if (_registration != null || widget.post.isClosed) return null;
    return _openForm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Recruitment')),
      extendBody: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PosterImage(assetPath: widget.post.posterAsset),
            const SizedBox(height: 16),
            if (_registration != null) ...[
              _RegistrationCard(registration: _registration!),
              const SizedBox(height: 16),
            ],
            _OprecInfoCard(post: widget.post),
          ],
        ),
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

/// Poster oprec, fallback ke placeholder jika kosong / tidak ketemu.
class _PosterImage extends StatelessWidget {
  final String? assetPath;
  const _PosterImage({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      color: colors.primaryContainer,
      child: Icon(Icons.campaign_outlined, size: 64, color: colors.primary),
    );

    return Container(
      decoration: AppCard.decoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: assetPath == null
            ? placeholder
            : Image.asset(
                assetPath!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
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
          Text('Status: ${registration.status.label}',
              style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Berkas: ${registration.fileName}', style: textTheme.bodyMedium),
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

/// Kartu info oprec: UKM, judul, tanggal tutup, deskripsi.
class _OprecInfoCard extends StatelessWidget {
  final OprecPost post;
  const _OprecInfoCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UkmHeader(logoAsset: post.logoUKM, ukmName: post.ukmName),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Chip(
                label: Text('Oprec'),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              Icon(Icons.event, size: 18, color: colors.outline),
              const SizedBox(width: 4),
              Text(
                'Tutup: ${_formatDate(post.closeDate)}',
                style: textTheme.bodyMedium?.copyWith(color: colors.outline),
              ),
            ],
          ),
          Divider(height: 16, thickness: 4, color: colors.primary),
          Text(
            'Deskripsi',
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            post.description,
            style: textTheme.bodyMedium?.copyWith(height: 1.5),
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
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onPressed,
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
