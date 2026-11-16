import 'package:flutter/material.dart';

import '../core/routing/app_routes.dart';
import '../core/widgets/coming_soon_screen.dart';
import '../data/ukm_repository.dart';
import '../features/jelajahi_ukm/presentation/screens/jelajahi_ukm_screen.dart';
import '../features/oprec/data/oprec_providers.dart';
import '../features/oprec/models/oprec_post.dart';
import '../models/campus_post.dart';
import '../services/storage_service.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/state_views.dart';
import '../widgets/ukm_logo.dart';

enum ViewStatus { loading, success, error }

/// Halaman Beranda "UKM Hub Unand" (gabungan).
///
/// - Tab 0 (Home)   : desain beranda baru (header, banner slider, carousel
///                    postingan, search bar) + section Open Recruitment (Modul 3).
/// - Tab 1 (UKM)    : JelajahiUkmScreen (Modul 1).
/// - Tab 2 (Aktivitas): ComingSoonScreen.
/// - Tab 3 (Profil) : membuka route AppRoutes.profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Warna Utama & Tema
  static const Color primaryGreen = Color(0xFF2C6E49);
  static const Color backgroundColor = Color(0xFFEBF1EC);
  static const Color navPillColor = Color(0xFF427C5C);

  // State loading data (dari modul teman)
  final _repository = UkmRepository();
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  final bool _simulateError = false;

  // Indeks aktif Bottom Navigation Bar
  int _selectedNavIndex = 0;

  // Banner Carousel State
  late final PageController _bannerController;
  int _currentBannerIndex = 0;

  // Post Carousel State
  late final PageController _postController;
  int _currentPostIndex = 0;

  // Data Banner Slider
  final List<_BannerItem> _banners = const [
    _BannerItem(
      imageAsset: 'assets/images/bemkm.jpg',
      badgeText: 'BEM KM UNAND',
      logoAsset: 'assets/images/logounand.jpg',
    ),
    _BannerItem(
      imageAsset: 'assets/images/fotoaiesec.jpg',
      badgeText: 'AIESEC UNAND',
      logoAsset: 'assets/images/logoaiesec.jpg',
    ),
    _BannerItem(
      imageAsset: 'assets/images/firetech.jpeg',
      badgeText: 'NEO TELEMETRI',
      logoAsset: 'assets/images/logounand.jpg',
    ),
    _BannerItem(
      imageAsset: 'assets/images/mapala.jpeg',
      badgeText: 'MAPALA UNAND',
      logoAsset: 'assets/images/mapalalogo.png',
    ),
  ];

  // Data Postingan
  late final List<CampusPost> _posts;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _postController = PageController(viewportFraction: 0.78);

    _posts = [
      const CampusPost(
        id: 'post-rezim-gibran',
        authorName: 'LiputanMahasiswaNguwawor',
        authorSubtitle: 'Baru saja',
        categoryBadge: 'Berita',
        icon: Icons.terminal_rounded,
        iconBgColor: Colors.black,
        iconColor: Colors.white,
        assetImagePath: 'assets/images/pace.jpg',
        bannerTitle: 'OPINI & ANALISIS TEKNOLOGI',
        bannerSubtitle: 'Perspektif Mahasiswa Unand',
        bannerGradient: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
        bannerIcon: Icons.article_rounded,
        title: 'Diskusi Terbuka Mahasiswa: Arah Riset dan Teknologi Kampus',
        description:
            'Mahasiswa dari berbagai fakultas berkumpul membahas arah pengembangan riset dan ekosistem teknologi di Universitas Andalas, mulai dari kolaborasi lintas jurusan hingga pemanfaatan laboratorium bersama.',
        fullContent:
            'Diskusi publik dan kajian mahasiswa terus bergulir dalam menyoroti berbagai kebijakan publik serta arah perkembangan ekosistem riset dan teknologi kampus di masa depan.',
        tags: ['#OpiniKampus', '#DiskusiUnand', '#NeoTelemetri'],
        initialLikes: 1067,
        initialComments: 5,
        time: '13 November 2026',
        location: 'Universitas Andalas',
        isVerified: true,
      ),
      const CampusPost(
        id: 'post-ai-danger',
        authorName: 'BEM KM UNAND',
        authorSubtitle: '13 November 2026',
        categoryBadge: 'Event',
        icon: Icons.terminal_rounded,
        iconBgColor: Colors.black,
        iconColor: Colors.white,
        assetImagePath: 'assets/images/wowok.jpg',
        bannerTitle: 'AI & MASA DEPAN TEKNOLOGI',
        bannerSubtitle: 'SEMINAR & WORKSHOP NASIONAL 2026',
        bannerGradient: [Color(0xFF0F172A), Color(0xFF1E293B)],
        bannerIcon: Icons.smart_toy_rounded,
        title: 'Seminar & Workshop Nasional: AI dan Masa Depan Teknologi',
        description:
            'BEM KM UNAND mengundang seluruh mahasiswa untuk mengikuti seminar dan workshop nasional tentang perkembangan kecerdasan buatan, peluang karier, serta tantangan etika penggunaannya.',
        fullContent:
            'Seminar dan workshop nasional ini menghadirkan pembicara dari akademisi dan praktisi industri untuk membahas perkembangan kecerdasan buatan, peluang karier, serta tantangan etika penggunaannya di lingkungan kampus.',
        tags: ['#NeoTelemetri', '#ArtificialIntelligence', '#EventUnand', '#TechSeminar'],
        initialLikes: 128,
        initialComments: 5,
        time: '13 November 2026',
        location: 'Convention Hall Unand',
        isVerified: true,
      ),
      if (dummyCampusPosts.isNotEmpty) dummyCampusPosts.first,
      if (dummyCampusPosts.length > 1) dummyCampusPosts[1],
    ];

    _loadItems();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      await _repository.fetchUkms(simulateError: _simulateError);
      if (!mounted) return;
      setState(() {
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  void _openProfile() {
    Navigator.pushNamed(context, AppRoutes.profile, arguments: true).then((_) {
      // Refresh nama pada kapsul header setelah kembali dari halaman profil.
      if (mounted) setState(() {});
    });
  }

  void _onNavTap(int index) {
    if (index == 3) {
      // Profil dibuka sebagai halaman terpisah, tab aktif tidak berubah.
      _openProfile();
      return;
    }
    setState(() => _selectedNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedNavIndex == 0 ? backgroundColor : Colors.white,
      body: _buildTabBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Isi tiap tab bottom navigation (integrasi modul).
  Widget _buildTabBody() {
    return switch (_selectedNavIndex) {
      0 => _buildHomeTab(), // Home feed
      1 => const JelajahiUkmScreen(), // Jelajahi UKM (Modul 1)
      2 => const ComingSoonScreen(title: 'Aktivitas'),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildHomeTab() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildHomeContent(),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Konten Home: desain baru + section Open Recruitment (Modul 3)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHomeContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = (screenHeight * 0.40).clamp(280.0, 340.0).toDouble();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Stack(
        children: [
          // 1. Background Image 'bgpkm.jpg' di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.46,
            child: Image.asset(
              'assets/images/bgpkm.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: primaryGreen);
              },
            ),
          ),

          // 2. Lengkungan hijau organik
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.52,
            child: CustomPaint(
              painter: _HeaderGreenCurvePainter(color: primaryGreen),
            ),
          ),

          // 3. Konten utama (ikut ter-scroll bersama background)
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildBannerSlider(screenHeight),
                const SizedBox(height: 12),

                // Carousel postingan (tinggi tetap agar bisa di dalam scroll)
                SizedBox(
                  height: carouselHeight,
                  child: _buildPostinganCarousel(),
                ),

                const SizedBox(height: 10),
                _buildSearchAndFilterBar(),
                const SizedBox(height: 20),

                // Section Open Recruitment (Modul 3)
                _buildOprecSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Section Open Recruitment
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildOprecSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Open Recruitment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...kDummyOprecPosts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OprecCard(post: post),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. Header: "MyUKM HubUnand" & Kapsul "You [Avatar]"
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'MyUKM\nHubUnand',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openProfile,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentDisplayTitleName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const ProfileAvatar(radius: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. Banner Slider (Swipeable + Dots Indicator interaktif)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBannerSlider(double screenHeight) {
    final bannerHeight = (screenHeight * 0.21).clamp(160.0, 195.0).toDouble();

    return Container(
      height: bannerHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      banner.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.white54, size: 48),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                banner.logoAsset,
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.school_rounded,
                                    color: primaryGreen,
                                    size: 16,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              banner.badgeText,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _banners.length,
                    (index) {
                      final isActive = _currentBannerIndex == index;
                      return GestureDetector(
                        onTap: () {
                          _bannerController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeInOut,
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 14 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. Carousel Postingan Horizontal (Smooth PageView)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildPostinganCarousel() {
    return PageView.builder(
      controller: _postController,
      onPageChanged: (index) {
        setState(() {
          _currentPostIndex = index;
        });
      },
      physics: const BouncingScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final isCenter = _currentPostIndex == index;

        return AnimatedScale(
          scale: isCenter ? 1.0 : 0.96,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: _buildPostCard(post),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(CampusPost post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.postDetail,
                arguments: post,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar postingan + logo UKM bundar di kanan atas
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (post.assetImagePath != null)
                        Image.asset(
                          post.assetImagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildThumbnailFallback(post);
                          },
                        )
                      else
                        _buildThumbnailFallback(post),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.25),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/images/logoneo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.terminal_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info postingan: judul, panah, likes, comments, share
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFFE53935),
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${post.initialLikes}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(0xFF64748B),
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${post.initialComments}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.open_in_new_rounded,
                            color: Color(0xFF64748B),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. Search Bar & Filter Button
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            // Tap search bar -> membuka tab Jelajahi UKM (Modul 1)
            child: GestureDetector(
              onTap: () => setState(() => _selectedNavIndex = 1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.search_rounded,
                      color: Color(0xFF1E293B),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Jelajahi UKM baru',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter UKM'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. Bottom Navigation Bar
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBottomNavigationBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: _selectedNavIndex == 0 ? backgroundColor : Colors.white,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            bottom: bottomPadding,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFC7D7CD),
                  width: 1.5,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding * 0.4 : 0),
            height: 64 + (bottomPadding > 0 ? bottomPadding * 0.4 : 0),
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  isActive: _selectedNavIndex == 0,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.apartment_outlined,
                  isActive: _selectedNavIndex == 1,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.assignment_outlined,
                  isActive: _selectedNavIndex == 2,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  isActive: _selectedNavIndex == 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: navPillColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
    );
  }

  // ── Helper: Nama tampilan untuk tombol kapsul pojok kanan atas ──────────
  String get _currentDisplayTitleName {
    final name = StorageService.instance.displayName;
    if (name.isEmpty) return 'You';
    return name[0].toUpperCase() + name.substring(1);
  }

  // ── Helper: Fallback widget jika thumbnail asset tidak ditemukan ─────────
  Widget _buildThumbnailFallback(CampusPost post) {
    final gradient = post.bannerGradient.isNotEmpty
        ? post.bannerGradient
        : const [Color(0xFF0F172A), Color(0xFF1E293B)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          post.bannerIcon,
          color: Colors.white70,
          size: 40,
        ),
      ),
    );
  }
}

/// Kartu ringkas postingan oprec di Home. Tap -> Detail Open Recruitment.
class _OprecCard extends StatelessWidget {
  final OprecPost post;
  const _OprecCard({required this.post});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2C6E49);
    final close = post.closeDate;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UkmLogo(assetPath: post.logoUKM, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.ukmName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pendaftaran dibuka',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              Text(
                'Sampai ${close.day}/${close.month}/${close.year}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.oprecDetail,
                arguments: post,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lihat Detail',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model Data Item Banner Slider
// ─────────────────────────────────────────────────────────────────────────────
class _BannerItem {
  final String imageAsset;
  final String badgeText;
  final String logoAsset;

  const _BannerItem({
    required this.imageAsset,
    required this.badgeText,
    required this.logoAsset,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter Lengkungan Hijau Organik (#2C6E49)
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderGreenCurvePainter extends CustomPainter {
  final Color color;

  const _HeaderGreenCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.64, 0);

    path.cubicTo(
      size.width * 0.66,
      size.height * 0.20,
      size.width * 0.52,
      size.height * 0.36,
      size.width * 0.45,
      size.height * 0.50,
    );

    path.cubicTo(
      size.width * 0.38,
      size.height * 0.66,
      size.width * 0.16,
      size.height * 0.82,
      0,
      size.height * 0.90,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeaderGreenCurvePainter oldDelegate) =>
      oldDelegate.color != color;
}