import 'package:flutter/material.dart';

import '../../../../models/post.dart';
import '../../application/feed_provider.dart';

/// Card widget for displaying a single post in the feed.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(post.tanggal);
    final catLabel = categoryLabel(post.kategori);
    final catColor = _categoryColor(post.kategori);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFF2F6), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UKM name + date row
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.ukmName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D6F),
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
            const SizedBox(height: 10),
            // Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
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
            const SizedBox(height: 12),
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                catLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: catColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    switch (kategori) {
      case 'event':
        return const Color(0xFF2E7D6F);
      case 'lomba':
        return const Color(0xFF4F46E5);
      case 'prestasi':
        return const Color(0xFFD97706);
      case 'oprec':
        return const Color(0xFFE11D48);
      case 'pengumuman':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFF64748B);
    }
  }
}