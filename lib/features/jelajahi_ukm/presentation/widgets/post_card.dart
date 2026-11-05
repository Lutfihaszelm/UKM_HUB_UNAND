import 'package:flutter/material.dart';

import '../../../../models/post.dart';
import '../../application/feed_provider.dart';

/// Card widget for displaying a single post in the feed (FR-04).
///
/// Features:
/// - Authoring UKM name with campus icon & publication date
/// - Post title in bold clear typography
/// - Post image banner if [imageUrl] is available
/// - Content snippet (up to 3 lines)
/// - Category pill badge & engagement metrics (likes & comments)
/// - "Lihat Postingan >" action link
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    if (diff < 7) return '$diff hari lalu';
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  Color _categoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'event':
        return const Color(0xFF266E4E);
      case 'lomba':
        return const Color(0xFF4F46E5);
      case 'prestasi':
        return const Color(0xFFD97706);
      case 'oprec':
        return const Color(0xFFE11D48);
      case 'pengumuman':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFF266E4E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(post.tanggal);
    final catLabel = categoryLabel(post.kategori);
    final catColor = _categoryColor(post.kategori);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFEFF2F6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UKM name + date row
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFF266E4E),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.ukmName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF266E4E),
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Optional post image banner
            if (post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF334155),
                        Color(0xFF1E293B),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 44,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Post Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Content preview
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),

            // Category badge & Likes + Comments stats
            Row(
              children: [
                // Category badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    catLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                    ),
                  ),
                ),
                const Spacer(),

                // Likes count
                const Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likes}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),

                // Comments count
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),

                // Action arrow
                const Text(
                  'Lihat >',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF266E4E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
