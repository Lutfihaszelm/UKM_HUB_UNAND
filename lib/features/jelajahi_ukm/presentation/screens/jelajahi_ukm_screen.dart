import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/follow_provider.dart';
import '../../application/jelajahi_ukm_provider.dart';
import '../../application/notification_provider.dart';
import '../widgets/ukm_card.dart';
import 'feed_screen.dart';
import 'notification_screen.dart';
import 'ukm_detail_screen.dart';

/// FR-01: Jelajahi & Cari UKM screen.
///
/// Clean, spacious organization directory matching the original reference:
/// - Prominent title and descriptive subtitle
/// - Generously padded search field with green focus state
/// - Section header with soft-green pill count badge
/// - Proportional, comfortably padded cards with wrapped descriptions
/// - Desktop-responsive layout centered and constrained to a comfortable width
/// - Adaptive sliver layout that gracefully handles keyboard open states without overflow
/// - Interactive cards that navigate to FR-02 UkmDetailScreen
class JelajahiUkmScreen extends ConsumerStatefulWidget {
  const JelajahiUkmScreen({
    super.key,
    this.showBottomNav = true,
  });

  final bool showBottomNav;

  @override
  ConsumerState<JelajahiUkmScreen> createState() => _JelajahiUkmScreenState();
}

class _JelajahiUkmScreenState extends ConsumerState<JelajahiUkmScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = ref.watch(filteredUkmListProvider);
    final followedState = ref.watch(followedUkmIdsProvider);
    final followedIds = followedState.value ?? {};
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                // ── Header section (Title, Subtitle, Search Field, Section Header) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Jelajahi UKM',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Badge(
                                isLabelVisible: unreadCount > 0,
                                label: Text('$unreadCount'),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFF1E293B),
                                  size: 24,
                                ),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Temukan dan ikuti unit kegiatan mahasiswa di Universitas Andalas sesuai minatmu.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── Search Field with clear button ──
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            ref
                                .read(searchQueryProvider.notifier)
                                .update(value);
                          },
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari nama UKM...',
                            hintStyle: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 16, right: 12),
                              child: Icon(
                                Icons.search_rounded,
                                color: Color(0xFF94A3B8),
                                size: 22,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                          .read(searchQueryProvider.notifier)
                                          .update('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFF2E7D6F),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Section heading with result count badge ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Daftar Organisasi Kampus',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredList.length} UKM',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D6F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // ── Organization list or empty state ──
                if (filteredList.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'UKM tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Coba kata kunci lain.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final ukm = filteredList[index];
                        final isFollowing = followedIds.contains(ukm.id);
                        return UkmCard(
                          ukm: ukm,
                          isFollowing: isFollowing,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => UkmDetailScreen(ukm: ukm),
                              ),
                            );
                          },
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
              currentIndex: 1, // UKM tab is active
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8,
              selectedItemColor: const Color(0xFF2E7D6F),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FeedScreen()),
                  );
                } else if (index == 2) {
                  // Menu ketiga (Slot Open Recruitment) dinonaktifkan sementara di branch Modul 1
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
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment_rounded),
                  label: 'Open Recruitment',
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