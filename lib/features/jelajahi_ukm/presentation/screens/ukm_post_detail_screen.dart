import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_routes.dart';
import '../../application/feed_provider.dart';
import '../../application/jelajahi_ukm_provider.dart';
import '../../application/repository_providers.dart';
import '../../models/post.dart';
import '../utils/formatters.dart';
import '../widgets/post_card.dart';
import '../widgets/ukm_logo_view.dart';

/// Detail postingan versi Modul 1 (read-only).
///
/// Like, komentar, dan share tetap milik Modul 2 sehingga layar ini hanya
/// menampilkan isi, lampiran, dan informasi penulis.
class UkmPostDetailScreen extends ConsumerWidget {
  const UkmPostDetailScreen({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(postByIdProvider(post.id));
    final detail = detailAsync.value ?? post;
    final categoryColor = postCategoryGradient(detail.category).first;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF122019),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Detail Postingan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          PostBanner(post: detail, height: 200, borderRadius: 22),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE7ECE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UkmLogoView(
                      logoUrl: detail.author.logoUrl,
                      fallbackIcon: Icons.groups_rounded,
                      color: categoryColor,
                      size: 46,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  detail.author.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF122019),
                                  ),
                                ),
                              ),
                              if (detail.author.isVerified) ...[
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 15,
                                  color: Color(0xFF2C6E49),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${formatLongDate(detail.publishedAt)}'
                            '${detail.location == null || detail.location!.isEmpty ? '' : ' • ${detail.location}'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              color: Color(0xFF7A8A80),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        detail.badge ?? detail.categoryLabel,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  detail.title,
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1.28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Color(0xFF122019),
                  ),
                ),
                if (detail.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final tag in detail.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6F3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B6B61),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEFF2F0)),
                const SizedBox(height: 16),
                Text(
                  detail.readableContent,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: Color(0xFF3F5145),
                  ),
                ),
                if (detail.attachments.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Lampiran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF122019),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final attachment in detail.attachments) ...[
                    _AttachmentRow(attachment: attachment),
                    const SizedBox(height: 8),
                  ],
                ],
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEFF2F0)),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _Stat(
                      icon: Icons.favorite_rounded,
                      color: const Color(0xFFE11D48),
                      label: '${formatCount(detail.likeCount)} suka',
                    ),
                    _Stat(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFF64748B),
                      label: '${formatCount(detail.commentCount)} komentar',
                    ),
                    const _Stat(
                      icon: Icons.visibility_outlined,
                      color: Color(0xFF64748B),
                      label: 'Publik',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => _openUkmProfile(context, ref, detail),
                    icon: const Icon(Icons.groups_rounded, size: 18),
                    label: const Text(
                      'Lihat Profil UKM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C6E49),
                      side: const BorderSide(color: Color(0xFFB9D3C3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUkmProfile(
    BuildContext context,
    WidgetRef ref,
    Post detail,
  ) async {
    try {
      final ukmList = ref.read(ukmListProvider).value;
      final existing = ukmList?.where((item) => item.id == detail.author.id);
      final ukm = existing != null && existing.isNotEmpty
          ? existing.first
          : await ref
                .read(ukmRepositoryProvider)
                .fetchUkmById(detail.author.id);
      if (!context.mounted) return;
      await Navigator.pushNamed(context, AppRoutes.ukmDetail, arguments: ukm);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil UKM tidak ditemukan.')),
      );
    }
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment});

  final PostAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final icon = switch (attachment.type) {
      'image' => Icons.image_outlined,
      'video' => Icons.play_circle_outline_rounded,
      _ => Icons.description_outlined,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2C6E49)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF26382D),
                  ),
                ),
                Text(
                  formatFileSize(attachment.sizeBytes),
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF7A8A80),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.download_outlined,
            size: 18,
            color: Color(0xFF8A978F),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6B61)),
        ),
      ],
    );
  }
}
