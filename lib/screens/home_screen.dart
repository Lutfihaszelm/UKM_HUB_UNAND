import 'package:flutter/material.dart';

import '../core/routing/app_routes.dart';
import '../models/campus_post.dart';
import '../services/storage_service.dart';
import '../widgets/profile_avatar.dart';

/// Halaman Beranda (Home Screen) untuk aplikasi "UKM Hub Unand".
///
/// Dibuat persis 100% sesuai dengan desain revisi:
/// - Background menggunakan gambar 'bgpkm.jpg' di bagian atas dikombinasikan dengan lengkungan hijau organik.
/// - Header: "MyUKM HubUnand" tebal putih di kiri & tombol kapsul hitam "You [Avatar]" di kanan.
/// - Banner Slider interaktif (gambar BEM KM UNAND dll) yang dapat digeser (swipe) atau ditekan titik tiga/dots-nya.
/// - Section Postingan horizontal dengan animasi geser mulus (smooth PageView) berbayang rapi.
/// - Tombol Search & Filter dipindahkan ke bagian bawah (di atas Bottom Navigation Bar).
/// - Bottom Navigation Bar hijau dengan garis arch melengkung dan active pill indicator.
/// - Fixed layout tanpa vertical scroll utama agar anti overflow di berbagai ukuran layar.
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

  // Indeks aktif Bottom Navigation Bar
  int _selectedNavIndex = 0;

  // Banner Carousel State
  late final PageController _bannerController;
  int _currentBannerIndex = 0;

  // Post Carousel State
  late final PageController _postController;
  int _currentPostIndex = 0;

  // Data Banner Slider (Menggunakan aset-aset asli UNAND di assets/images/)
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
      logoAsset: 'assets/images/logoneo.png',
    ),
    _BannerItem(
      imageAsset: 'assets/images/mapala.jpeg',
      badgeText: 'MAPALA UNAND',
      logoAsset: 'assets/images/mapalalogo.png',
    ),
  ];

  // Data Postingan (Sesuai mockup & data kampus terkini)
  late final List<CampusPost> _posts;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _postController = PageController(viewportFraction: 0.78);

    _posts = [
      // Postingan persis seperti pada gambar desain mockup
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
        title: 'Serangan tentara TNI berhasil menumbangkan satu anggota OPM, Kobo Kanaeru selaku Ketua Guild OPM :" sA GAgAl BOyaH"',
        description: 'Kobo Kanaeru selaku Ketua Guild Pace OPM langsung merespons lewat open mic dengan suara melengking khasnya yang campur aduk antara panik dan kesal. "sa dah bilang, ko jangan macam" dengan kami kalau tidak ingin mati, ko pikir ko karakter utama anime ka?! Knock satu, cik!" teriak Kobo dengan imut ',
        fullContent: 'Diskusi publik dan kajian mahasiswa terus bergulir dalam menyoroti berbagai kebijakan publik serta arah perkembangan ekosistem riset dan teknologi kampus di masa depan.',
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
        title: 'Gibran mengajak prabowo untuk mundur bersama, Prabowo : Oke Gas oke Gas',
        description: 'Di tengah memanasnya tekanan politik di Istana Merdeka, Gibran meletakkan surat pengunduran dirinya di atas meja dan menatap Prabowo. "Pak, bagaimana kalau kita juga mundur bersama agar situasi tenang?" ujar Gibran serius. Teddy menatap sinis, lalu hendak mengusir gibran, prabowo menghentikan nya, lalu tersenyum lebar dan menjawab "Oke gas, oke gas!" sambil dance tiktok body pata pata',
        fullContent: 'Di tengah memanasnya tekanan politik di Istana Merdeka, Gibran meletakkan surat pengunduran dirinya di atas meja dan menatap Prabowo. "Pak, bagaimana kalau kita juga mundur bersama agar situasi tenang?" ujar Gibran serius. Teddy menatap sinis, lalu hendak mengusir gibran, prabowo menghentikan nya, lalu tersenyum lebar dan menjawab "Oke gas, oke gas!" sambil dance tiktok body pata pata',
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
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,

      body: Stack(
        children: [
          // ─── 1. Background Image 'bgpkm.jpg' di Bagian Atas ───
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

          // ─── 2. Lengkungan Hijau Organik (#2C6E49) di Sisi Kiri Atas ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.52,
            child: CustomPaint(
              painter: _HeaderGreenCurvePainter(color: primaryGreen),
            ),
          ),

          // ─── 3. Struktur Konten Utama (Fixed Column - Pas di Layar) ───
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: "MyUKM HubUnand" & Tombol Kapsul "You"
                _buildHeader(),

                const SizedBox(height: 10),

                // Banner Slider (Swipeable + Dots Indicator interaktif)
                _buildBannerSlider(screenHeight),

                const SizedBox(height: 12),

                // Carousel Postingan Horizontal (Smooth PageView)
                Expanded(
                  child: _buildPostinganCarousel(),
                ),

                const SizedBox(height: 10),

                // Search Bar & Filter Button (Dipindahkan ke Bawah)
                _buildSearchAndFilterBar(),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
      // ─── 4. Bottom Navigation Bar ───
      bottomNavigationBar: _buildBottomNavigationBar(),
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
          // Teks Judul "MyUKM HubUnand" Dua Baris Tebal Putih
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

          // Kapsul Hitam "You [Avatar]" di Pojok Kanan Atas
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile, arguments: true);
              },
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
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildBannerSlider(double screenHeight) {
    final bannerHeight = (screenHeight * 0.21).clamp(160.0, 195.0);

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
            // PageView Banner Gambar
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
                    // Gambar Utama Banner
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

                    // Gradien Halus di Atas & Bawah agar Teks dan Dots Tetap Kontras
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

                    // Badge Kapsul Putih di Kiri Atas (Logo UKM + Nama)
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

            // Indikator Titik Tiga / Dots Interaktif di Tengah Bawah Banner
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
                // 1. Gambar Postingan dengan Logo UKM Bundar di Kanan Atas
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

                      // Vignette halus
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

                      // Logo UKM Bundar di Pojok Kanan Atas Gambar
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

                // 2. Info Postingan: Judul, Panah, Likes, Comments, Share
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Judul Postingan & Panah Kanan
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

                      // Footer Stats: Heart Likes, Chat Comments, Open Share
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
  // 4. Search Bar & Filter Button (Dipindahkan ke Bawah)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Container Putih Berbentuk Pill dengan Soft Shadow
          Expanded(
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
          const SizedBox(width: 12),

          // Tombol Filter Hijau (#2C6E49) Kotak Sudut Membulat
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
      color: backgroundColor,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Garis Arch / Lengkungan Halus di Atas Bar Hijau (Persis Sesuai Mockup)
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

          // Bar Utama Hijau #2C6E49 dengan Sudut Atas Sangat Membulat
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
                // 1. Home (Ikon Rumah - Aktif dengan Bentuk Pill)
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  isActive: _selectedNavIndex == 0,
                ),

                // 2. UKM (Ikon Gedung Bertingkat)
                _buildNavItem(
                  index: 1,
                  icon: Icons.apartment_outlined,
                  isActive: _selectedNavIndex == 1,
                ),

                // 3. Aktivitas (Ikon Papan Clipboard)
                _buildNavItem(
                  index: 2,
                  icon: Icons.assignment_outlined,
                  isActive: _selectedNavIndex == 2,
                ),

                // 4. Profil (Ikon Siluet Orang)
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
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        if (index == 3) {
          Navigator.pushNamed(context, AppRoutes.profile, arguments: true);
        }
      },
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
// Painter Lengkungan Hijau Organik (#2C6E49) Sesuai Desain Mockup
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

    // Lengkungan pertama dari batas atas ke samping kanan teks header
    path.cubicTo(
      size.width * 0.66,
      size.height * 0.20,
      size.width * 0.52,
      size.height * 0.36,
      size.width * 0.45,
      size.height * 0.50,
    );

    // Lengkungan kedua meliuk anggun ke kiri bawah di samping kartu postingan
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
