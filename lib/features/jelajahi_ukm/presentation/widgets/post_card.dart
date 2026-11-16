import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../utils/formatters.dart';
import 'app_image.dart';

/// Banner postingan. Memakai gambar bila ada, jika tidak memakai gradasi
/// warna sesuai kategori agar kartu tetap hidup tanpa aset tambahan.
class PostBanner extends StatelessWidget {
  const PostBanner({
    super.key,
    required this.post,
    this.height = 148,
    this.borderRadius = 16,
  });

  final Post post;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallback = _CategoryPlaceholder(post: post);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: AppImage(path: post.bannerUrl, fallback: fallback),
      ),
    );
  }
}

class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder({required this.post, this.showText = true});

  final Post post;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final colors = postCategoryGradient(post.category);
    final icon = postCategoryIcon(post.category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -18,
            child: Icon(
              icon,
              size: 116,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showText) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      post.badge ?? post.categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Color> postCategoryGradient(String category) {
  switch (category) {
    case 'event':
      return const [Color(0xFF1E5A3C), Color(0xFF3E8E63)];
    case 'lomba':
      return const [Color(0xFF9A3412), Color(0xFFEA580C)];
    case 'prestasi':
      return const [Color(0xFF1E3A8A), Color(0xFF4338CA)];
    case 'oprec':
      return const [Color(0xFF0F766E), Color(0xFF0D9488)];
    default:
      return const [Color(0xFF334155), Color(0xFF64748B)];
  }
}

IconData postCategoryIcon(String category) {
  switch (category) {
    case 'event':
      return Icons.event_available_rounded;
    case 'lomba':
      return Icons.emoji_events_rounded;
    case 'prestasi':
      return Icons.workspace_premium_rounded;
    case 'oprec':
      return Icons.campaign_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

/// Varian tampilan kartu postingan.
///
/// [feed] adalah kartu feed lengkap dengan penulis, ringkasan, dan meta.
/// [detail] adalah kartu ringkas pada tab Postingan profil UKM: banner di
/// atas, judul, lalu footer tanggal.
enum PostCardVariant { feed, detail }

/// Kartu postingan pada feed Modul 1.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showBanner = true,
    this.variant = PostCardVariant.feed,
  });

  final Post post;
  final VoidCallback? onTap;
  final bool showBanner;
  final PostCardVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == PostCardVariant.detail) {
      return _DetailPostCard(post: post, onTap: onTap);
    }

    final categoryColor = postCategoryGradient(post.category).first;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7ECE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      postCategoryIcon(post.category),
                      size: 20,
                      color: categoryColor,
                    ),
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
                                post.author.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF122019),
                                ),
                              ),
                            ),
                            if (post.author.isVerified) ...[
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: Color(0xFF2C6E49),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          formatPostDate(post.publishedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7A8A80),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CategoryPill(
                    label: post.categoryLabel,
                    color: categoryColor,
                  ),
                ],
              ),
              if (showBanner) ...[
                const SizedBox(height: 12),
                PostBanner(post: post),
              ],
              const SizedBox(height: 12),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF122019),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                post.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF5B6B61),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MetaItem(
                    icon: Icons.favorite_rounded,
                    text: '${formatCount(post.likeCount)} suka',
                    color: const Color(0xFFE11D48),
                  ),
                  _MetaItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    text: '${formatCount(post.commentCount)} komentar',
                    color: const Color(0xFF64748B),
                  ),
                  if (post.location != null && post.location!.isNotEmpty)
                    _MetaItem(
                      icon: Icons.place_outlined,
                      text: post.location!,
                      color: const Color(0xFF64748B),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat postingan',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: categoryColor,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: categoryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu postingan ringkas untuk tab Postingan profil UKM.
///
/// Susunannya mengikuti referensi: banner gambar di atas, blok judul putih,
/// lalu footer abu-abu berisi ikon jam, tanggal, dan chevron.
class _DetailPostCard extends StatelessWidget {
  const _DetailPostCard({required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: Color(0xFFE6ECE7)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 156,
              child: AppImage(
                path: post.bannerUrl,
                fallback: _CategoryPlaceholder(post: post, showText: false),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  color: Color(0xFF122019),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F5F3),
                border: Border(top: BorderSide(color: Color(0xFFE6ECE7))),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: Color(0xFF6B7A71),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formatLongDate(post.publishedAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7A71),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: Color(0xFF6B7A71),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }
}
