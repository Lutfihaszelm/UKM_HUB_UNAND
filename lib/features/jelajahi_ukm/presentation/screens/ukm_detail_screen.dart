import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/ukm.dart';
import '../../application/feed_provider.dart';
import '../../application/follow_provider.dart';
import '../widgets/post_card.dart';

/// FR-02: Detail profil UKM
/// FR-03: Follow / Unfollow UKM
class UkmDetailScreen extends ConsumerWidget {
  const UkmDetailScreen({super.key, required this.ukm});

  final Ukm ukm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followedUkmIdsProvider);
    final isFollowing = followState.value?.contains(ukm.id) ?? false;
    final posts = ref.watch(postsByUkmProvider(ukm.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ukm.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ukm.color,
                      ukm.color.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Icon(ukm.icon, color: Colors.white, size: 44),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ukm.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ref.read(followedUkmIdsProvider.notifier).toggleFollow(ukm.id);
                      },
                      icon: Icon(
                        isFollowing ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
                      ),
                      label: Text(isFollowing ? 'Following' : 'Follow'),
                      style: FilledButton.styleFrom(
                        backgroundColor: isFollowing ? const Color(0xFFE8F7F0) : const Color(0xFF2E7D6F),
                        foregroundColor: isFollowing ? const Color(0xFF2E7D6F) : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tentang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Text(ukm.description, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
                  const SizedBox(height: 16),
                  _infoRow(Icons.category_rounded, 'Kategori', ukm.kategori),
                  if (ukm.contact != null) _infoRow(Icons.alternate_email_rounded, 'Kontak', ukm.contact!),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFEFF2F6)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Postingan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE8F7F0), borderRadius: BorderRadius.circular(12)),
                        child: Text('${posts.length} post', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2E7D6F))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (posts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.article_outlined, size: 48, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text('Belum ada postingan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      SizedBox(height: 4),
                      Text('UKM ini belum memiliki postingan.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) => PostCard(post: posts[index]),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D6F)),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)))),
        ],
      ),
    );
  }
}