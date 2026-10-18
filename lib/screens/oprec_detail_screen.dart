import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/oprec_post.dart';
import '../models/registration.dart';
import '../repositories/oprec_repository.dart';
import 'oprec_form_screen.dart';

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
  
  static const _shadowColor = Color.fromRGBO(44, 110, 73, 0.5);

  
  Registration? _registration;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  // ---------- Aksi ----------
  Future<void> _openForm() async {
    // Kirim post + repository ke form, lalu TUNGGU hasil yang dikembalikan
    final result = await Navigator.push<Registration>(
      context,
      MaterialPageRoute(
        builder: (context) => OprecFormScreen(
          post: widget.post,
          repository: widget.repository,
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
      return 'Sudah Mendaftar · ${_registration!.status}';
    }
    if (widget.post.isClosed) return 'Pendaftaran Ditutup';
    return 'Daftar Sekarang';
  }

  VoidCallback? get _buttonAction {
    if (_registration != null || widget.post.isClosed) return null;
    return _openForm;
  }

  // ---------- Placeholder ----------
  Widget _logoPlaceholder(ColorScheme colors) => Container(
        color: colors.primary,
        alignment: Alignment.center,
        child: Icon(Icons.groups, size: 20, color: colors.onPrimary),
      );

  Widget _posterPlaceholder(ColorScheme colors) => Container(
        height: 180,
        width: double.infinity,
        alignment: Alignment.center,
        color: colors.primaryContainer,
        child: Icon(
          Icons.campaign_outlined,
          size: 64,
          color: colors.primary,
        ),
      );

  // ---------- Kartu hasil pendaftaran ----------
  Widget _registrationCard(ColorScheme colors, TextTheme textTheme) {
    final reg = _registration!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
          Text('Status: ${reg.status}', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Berkas: ${reg.fileName}', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            'Dikirim: ${_formatDate(reg.createdAt)}',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Open Recruitment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colors.primary,
        elevation: 4,
        shadowColor: _shadowColor,
      ),
      extendBody: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Poster (fallback ke placeholder jika kosong / tidak ketemu)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: _shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: post.posterAsset == null
                    ? _posterPlaceholder(colors)
                    : Image.asset(
                        post.posterAsset!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) =>
                            _posterPlaceholder(colors),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Hasil pendaftaran (muncul setelah form mengembalikan hasil)
            if (_registration != null) ...[
              _registrationCard(colors, textTheme),
              const SizedBox(height: 16),
            ],

            // 3. Kartu info oprec
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: _shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama UKM
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: post.logoUKM == null
                              ? _logoPlaceholder(colors)
                              : Image.asset(
                                  post.logoUKM!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _logoPlaceholder(colors),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        post.ukmName,
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Judul
                  Text(
                    post.title,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Kategori + tanggal tutup
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
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colors.outline),
                      ),
                    ],
                  ),
                  Divider(height: 16, thickness: 4, color: colors.primary),

                  // Deskripsi
                  Text(
                    'Deskripsi',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.description,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 4. Tombol aksi di bawah (panel kaca)
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                  onPressed: _buttonAction,
                  child: Text(_buttonLabel),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
