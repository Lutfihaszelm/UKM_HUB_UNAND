import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/ukm.dart';
import '../../application/feed_provider.dart';
import '../../application/follow_provider.dart';
import '../widgets/post_detail_bottom_sheet.dart';

/// FR-02: Detail Profil UKM Screen.
///
/// Displays comprehensive profile details of a student organization (UKM):
/// - Green curved hero header matching the Home Screen aesthetic
/// - Prominent UKM avatar squircle with icon / logo
/// - UKM Name and Category pill badge
/// - Follow / Following button (prepared UI with persistent state)
/// - "Tentang" card with detailed organization description
/// - "Detail Organisasi" card with Category, Contact / Social Media, and Status
/// - Fully responsive, cleanly scrolls without overflow on all screen sizes
class UkmDetailScreen extends ConsumerWidget {
  const UkmDetailScreen({super.key, required this.ukm});

  final Ukm ukm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followedUkmIdsProvider);
    final isFollowing = followState.value?.contains(ukm.id) ?? false;
    final ukmPosts = ref.watch(postsByUkmProvider(ukm.id));

    return Scaffold(
      backgroundColor: const Color(0xFFE5EDE8),
      body: Stack(
        children: [
          // ── Curved organic green background shape matching Home Screen ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: CustomPaint(
              painter: _DetailHeaderCurvePainter(),
            ),
          ),

          // ── Main scrollable content ──
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: CustomScrollView(
                  slivers: [
                    // Top navigation bar with back button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            GestureDetector(
                              onTap: () => Navigator.of(context).maybePop(),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF1E293B),
                                  size: 22,
                                ),
                              ),
                            ),

                            // Screen title
                            const Text(
                              'Detail Profil UKM',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            // Placeholder to balance the row
                            const SizedBox(width: 44),
                          ],
                        ),
                      ),
                    ),

                    // Hero Profile Avatar & Name
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          children: [
                            // Logo / Avatar Squircle
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                ukm.icon,
                                color: ukm.color,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // UKM Name
                            Text(
                              ukm.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Category Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF266E4E)
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                ukm.kategori,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF266E4E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Follow Button (Milestone 2 UI preparation)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: () {
                                  ref
                                      .read(followedUkmIdsProvider.notifier)
                                      .toggleFollow(ukm.id);
                                },
                                icon: Icon(
                                  isFollowing
                                      ? Icons.check_rounded
                                      : Icons.person_add_alt_1_rounded,
                                  size: 20,
                                ),
                                label: Text(
                                  isFollowing ? 'Following' : 'Follow',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isFollowing
                                      ? const Color(0xFFE8F7F0)
                                      : const Color(0xFF266E4E),
                                  foregroundColor: isFollowing
                                      ? const Color(0xFF266E4E)
                                      : Colors.white,
                                  elevation: isFollowing ? 0 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: isFollowing
                                        ? const BorderSide(
                                            color: Color(0xFF266E4E),
                                            width: 1.5,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Card: Tentang Organisasi ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFEFF2F6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF266E4E),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tentang',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ukm.description,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF475569),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Card: Detail & Kontak Organisasi ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFEFF2F6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    color: Color(0xFF266E4E),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Detail Informasi',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Kategori
                              _DetailInfoTile(
                                icon: Icons.category_rounded,
                                label: 'Kategori: ',
                                value: ukm.kategori,
                              ),

                              // Kontak
                              if (ukm.contact != null) ...[
                                const Divider(
                                  color: Color(0xFFF1F5F9),
                                  height: 20,
                                ),
                                _DetailInfoTile(
                                  icon: Icons.alternate_email_rounded,
                                  label: 'Kontak: ',
                                  value: ukm.contact!,
                                ),
                              ],

                              const Divider(
                                color: Color(0xFFF1F5F9),
                                height: 20,
                              ),

                              // Status
                              const _DetailInfoTile(
                                icon: Icons.verified_rounded,
                                label: 'Status: ',
                                value: 'Unit Kegiatan Mahasiswa Aktif',
                              ),

                              const Divider(
                                color: Color(0xFFF1F5F9),
                                height: 20,
                              ),

                              // Afiliasi
                              const _DetailInfoTile(
                                icon: Icons.account_balance_rounded,
                                label: 'Afiliasi: ',
                                value: 'Universitas Andalas',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Card: Postingan Terkini UKM (FR-04) ──
                    if (ukmPosts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFFEFF2F6),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.article_outlined,
                                      color: Color(0xFF266E4E),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Postingan Terbaru',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${ukmPosts.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF266E4E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ...ukmPosts.map((post) => InkWell(
                                      onTap: () => showPostDetailBottomSheet(
                                          context, post),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFEFF2F6),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    post.title,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    post.content,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 20,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}

/// An informative tile row with leading icon, label, and value.
class _DetailInfoTile extends StatelessWidget {
  const _DetailInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7F0),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF266E4E),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

/// Organic curved green background for the detail screen hero.
class _DetailHeaderCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF266E4E)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.45);

    // Organic curve flowing down to the bottom-left
    path.cubicTo(
      size.width * 0.75,
      size.height * 0.65,
      size.width * 0.35,
      size.height * 0.75,
      0,
      size.height * 0.60,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
