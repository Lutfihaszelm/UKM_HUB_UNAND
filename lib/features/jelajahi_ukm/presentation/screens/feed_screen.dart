import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/post.dart';
import '../../application/feed_provider.dart';
import '../../data/ukm_dummy_data.dart';
import '../widgets/post_card.dart';
import '../widgets/post_detail_bottom_sheet.dart';
import 'notification_screen.dart';

/// FR-04 & FR-05: Feed Informasi Terkini & Filter / Pencarian Feed.
///
/// Features:
/// - Feed seluruh UKM & feed personal (UKM yang diikuti)
/// - Filter kategori: Event, Lomba, Prestasi, Oprec, Pengumuman
/// - Filter berdasarkan UKM spesifik via dropdown
/// - Pencarian keyword pada judul dan konten postingan
/// - Reset filter cepat
/// - Tampilan empty state yang jelas & informatif
/// - Modal detail postingan lengkap saat kartu diklik
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({
    super.key,
    this.showBottomNav = true,
  });

  final bool showBottomNav;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _postSearchController = TextEditingController();

  @override
  void dispose() {
    _postSearchController.dispose();
    super.dispose();
  }

  void _resetAllFilters() {
    _postSearchController.clear();
    ref.read(postSearchQueryProvider.notifier).clear();
    ref.read(selectedCategoryProvider.notifier).select(null);
    ref.read(selectedUkmFilterProvider.notifier).select(null);
    ref.read(personalFeedOnlyProvider.notifier).set(false);
  }

  void _showPostDetailModal(BuildContext context, Post post) {
    showPostDetailBottomSheet(context, post);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(filteredPostListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedUkm = ref.watch(selectedUkmFilterProvider);
    final personalOnly = ref.watch(personalFeedOnlyProvider);
    final searchQuery = ref.watch(postSearchQueryProvider);
    final canPop = Navigator.of(context).canPop();

    final isAnyFilterActive = selectedCategory != null ||
        selectedUkm != null ||
        personalOnly ||
        searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                // ── Header & Filter Controls ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (canPop) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF1E293B),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 12),
                            ],
                            const Expanded(
                              child: Text(
                                'Feed',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Informasi terbaru dari UKM Unand',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Search Field in Feed (FR-05) ──
                        TextField(
                          controller: _postSearchController,
                          onChanged: (value) {
                            ref
                                .read(postSearchQueryProvider.notifier)
                                .update(value);
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari judul, topik, atau isi postingan...',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 14, right: 10),
                              child: Icon(
                                Icons.search_rounded,
                                color: Color(0xFF94A3B8),
                                size: 20,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            suffixIcon: _postSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _postSearchController.clear();
                                      ref
                                          .read(postSearchQueryProvider.notifier)
                                          .clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF2E7D6F),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Feed toggle (Semua / Personal) ──
                        Row(
                          children: [
                            _FeedToggle(
                              label: 'Semua',
                              isActive: !personalOnly,
                              onTap: () => ref
                                  .read(personalFeedOnlyProvider.notifier)
                                  .set(false),
                            ),
                            const SizedBox(width: 8),
                            _FeedToggle(
                              label: 'Personal',
                              isActive: personalOnly,
                              onTap: () => ref
                                  .read(personalFeedOnlyProvider.notifier)
                                  .set(true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Category filter chips ──
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'Semua Kategori',
                                isActive: selectedCategory == null,
                                onTap: () => ref
                                    .read(selectedCategoryProvider.notifier)
                                    .select(null),
                              ),
                              ...kPostCategories.map((cat) => Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: _FilterChip(
                                      label: categoryLabel(cat),
                                      isActive: selectedCategory == cat,
                                      onTap: () => ref
                                          .read(selectedCategoryProvider
                                              .notifier)
                                          .select(cat),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── UKM filter dropdown ──
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: selectedUkm,
                              hint: const Text(
                                'Filter berdasarkan UKM',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.filter_list_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Semua UKM'),
                                ),
                                ...kDummyUkmList.map((ukm) => DropdownMenuItem<String?>(
                                      value: ukm.id,
                                      child: Text(
                                        ukm.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                              ],
                              onChanged: (value) => ref
                                  .read(selectedUkmFilterProvider.notifier)
                                  .select(value),
                            ),
                          ),
                        ),

                        // ── Reset filter & Result count row ──
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${posts.length} postingan ditemukan',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              if (isAnyFilterActive)
                                TextButton.icon(
                                  onPressed: _resetAllFilters,
                                  icon: const Icon(
                                    Icons.clear_all_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Reset Filter'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFE11D48),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // ── Post list or empty state ──
                if (posts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.article_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak ada postingan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              personalOnly
                                  ? 'Belum ada postingan dari UKM yang kamu ikuti. Coba ikuti UKM lain di menu Direktori.'
                                  : 'Tidak ditemukan postingan yang cocok dengan kriteria filter saat ini.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isAnyFilterActive) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _resetAllFilters,
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Reset Semua Filter'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2E7D6F),
                                  side: const BorderSide(
                                    color: Color(0xFF2E7D6F),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onTap: () => _showPostDetailModal(context, post),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      // ── Standalone Bottom Navigation ──
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavigationBar(
              currentIndex: 0, // Feed tab is active
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8,
              selectedItemColor: const Color(0xFF2E7D6F),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              onTap: (index) {
                if (index == 1) {
                  Navigator.of(context).pushReplacementNamed('/jelajahi-ukm');
                } else if (index == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.apps_outlined),
                  activeIcon: Icon(Icons.apps_rounded),
                  label: 'UKM',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  activeIcon: Icon(Icons.notifications_rounded),
                  label: 'Notifikasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            )
          : null,
    );
  }
}

class _FeedToggle extends StatelessWidget {
  const _FeedToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E7D6F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF2E7D6F) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F7F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF2E7D6F) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF2E7D6F) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}