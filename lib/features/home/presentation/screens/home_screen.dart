import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/post.dart';
import '../../../../models/ukm.dart';
import '../../../jelajahi_ukm/application/notification_provider.dart';
import '../../../jelajahi_ukm/data/post_dummy_data.dart';
import '../../../jelajahi_ukm/data/ukm_dummy_data.dart';
import '../../../jelajahi_ukm/presentation/screens/feed_screen.dart';
import '../../../jelajahi_ukm/presentation/screens/notification_screen.dart';
import '../../../jelajahi_ukm/presentation/screens/ukm_detail_screen.dart';
import '../../../jelajahi_ukm/presentation/widgets/post_detail_bottom_sheet.dart';
import '../../data/home_dummy_data.dart';
import '../widgets/home_header.dart';
import '../widgets/home_post_card.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_ukm_section.dart';

/// Home Screen — the main landing page of UKM Hub Unand.
///
/// Designed to closely match the Figma design:
/// - Curved green header background with student greeting
/// - Search bar + filter button directing to Jelajahi UKM
/// - "UKM UNAND" squircle card with "Lihat Semua"
/// - Horizontal scrollable "Postingan" cards
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    this.onNavigateToTab,
  });

  /// Callback to switch tabs in [MainShellScreen].
  /// Tab 1 = Jelajahi UKM, Tab 2 = Notifikasi.
  final void Function(int index)? onNavigateToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadNotifCount = ref.watch(unreadNotificationCountProvider);

    // Featured UKMs (AIESEC, Neo Telemetri, Mapala)
    final featuredUkms = kDummyUkmList
        .where((ukm) => kFeaturedUkmIds.contains(ukm.id))
        .toList();

    // Recent posts sorted by date
    final recentPosts = List<Post>.from(kDummyPostList)
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    final displayPosts = recentPosts.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE5EDE8),
      body: Stack(
        children: [
          // ── Curved organic green background shape ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 440,
            child: CustomPaint(
              painter: _HomeHeaderCurvePainter(),
            ),
          ),

          // ── Main content scrollable ──
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (Avatar, Halo Lutfi, Bell with unread badge)
                      HomeHeader(
                        studentName: kDummyStudentName,
                        badgeCount: unreadNotifCount,
                        onNotificationTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationScreen(),
                            ),
                          );
                        },
                      ),

                      // 2. Search bar + filter button (directs to Feed filter)
                      HomeSearchBar(
                        onTap: () => onNavigateToTab?.call(1),
                        onFilterTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const FeedScreen(showBottomNav: false),
                            ),
                          );
                        },
                      ),

                      // 3. UKM UNAND Section
                      HomeUkmSection(
                        featuredUkms: featuredUkms,
                        onSeeAllTap: () => onNavigateToTab?.call(1),
                        onUkmTap: (ukm) => _navigateToDetail(context, ukm),
                        onMoreTap: () => onNavigateToTab?.call(1),
                      ),

                      // 4. Postingan Section Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Postingan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FeedScreen(showBottomNav: false),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: const Text(
                                'Feed Lengkap >',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF266E4E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Horizontal scrolling post cards
                      SizedBox(
                        height: 395,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20, right: 6),
                          itemCount: displayPosts.length,
                          itemBuilder: (context, index) {
                            final post = displayPosts[index];
                            return HomePostCard(
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
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Ukm ukm) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UkmDetailScreen(ukm: ukm),
      ),
    );
  }

  void _showPostDetailModal(BuildContext context, Post post) {
    showPostDetailBottomSheet(context, post);
  }
}

/// Custom painter for the organic curved green shape at the top.
class _HomeHeaderCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF266E4E)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.64, 0);

    // Curve down around the greeting
    path.cubicTo(
      size.width * 0.68,
      size.height * 0.12,
      size.width * 0.72,
      size.height * 0.32,
      size.width * 0.44,
      size.height * 0.46,
    );

    // Curve down the left edge
    path.cubicTo(
      size.width * 0.16,
      size.height * 0.58,
      0,
      size.height * 0.75,
      0,
      size.height * 0.95,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
