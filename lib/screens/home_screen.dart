import 'package:flutter/material.dart';

import '../core/routing/app_routes.dart';
import '../models/campus_post.dart';
import '../models/ukm.dart';

/// Halaman Beranda (Home Screen) untuk aplikasi "UKM Hub Unand".
/// 
/// Dibuat persis 100% sesuai dengan desain:
/// - Fixed layout tanpa vertical scroll pada struktur utama.
/// - Header dengan wave/lengkungan asimetris hijau (#2C6E49).
/// - Floating search bar berbentuk pil + filter button hijau.
/// - Section UKM UNAND (kartu putih berisi horizontal list 4 UKM).
/// - Section Postingan (Expanded dengan horizontal list card berbayang).
/// - Bottom Navigation Bar rounded green dengan active pill pada icon Home.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Warna Utama & Tema
  static const Color primaryGreen = Color(0xFF2C6E49);
  static const Color backgroundColor = Color(0xFFF5F7F5);
  static const Color navPillColor = Color(0xFF427C5C);
  static const Color ukmBlueColor = Color(0xFF027FF3);

  // Indeks aktif Bottom Navigation Bar
  int _selectedNavIndex = 0;

  // Data Dummy UKM (4 item sesuai desain)
  final List<_UkmItemData> _ukmList = const [
    _UkmItemData(
      id: 'aiesec',
      name: 'AIESEC in\nUNAND',
      isBlue: true,
      category: 'Kepemimpinan & Internasional',
    ),
    _UkmItemData(
      id: 'neo-telemetri',
      name: 'Neo\nTelemetri',
      isBlue: true,
      category: 'Teknologi & Informasi',
    ),
    _UkmItemData(
      id: 'mapala',
      name: 'Mapala\n',
      isBlue: true,
      category: 'Pecinta Alam',
    ),
    _UkmItemData(
      id: 'ukm-lainnya',
      name: 'UKM\nLainnya',
      isBlue: false,
      category: 'Semua Kategori',
    ),
  ];

  // Data Dummy Postingan (Menggunakan judul dan detail persis dari desain)
  late final List<CampusPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = [
      const CampusPost(
        id: 'post-ai-danger',
        authorName: 'Neotelemetri',
        authorSubtitle: '13 November 2026',
        categoryBadge: 'Event',
        icon: Icons.terminal_rounded,
        iconBgColor: Colors.black,
        iconColor: Colors.white,
        assetImagePath: 'assets/images/hacker.jpg',
        bannerTitle: 'AI & MASA DEPAN TEKNOLOGI',
        bannerSubtitle: 'SEMINAR & WORKSHOP NASIONAL 2026',
        bannerGradient: [Color(0xFF0F172A), Color(0xFF1E293B)],
        bannerIcon: Icons.smart_toy_rounded,
        title: 'Ini Judul Postingan, Misal : Lari !!!, selamatkan diri anda dari AI yang meraja lela',
        description: 'Tantangan era kecerdasan buatan bagi mahasiswa. Pelajari bagaimana beradaptasi dan berkembang di era otomatisasi.',
        fullContent: 'Perkembangan kecerdasan buatan (Artificial Intelligence) berkembang sangat pesat dalam beberapa tahun terakhir. UKM Neo Telemetri mengajak seluruh mahasiswa Universitas Andalas untuk mendiskusikan peluang dan tantangan nyata AI.',
        tags: ['#NeoTelemetri', '#ArtificialIntelligence', '#EventUnand', '#TechSeminar'],
        initialLikes: 128,
        initialComments: 5,
        time: '13 November 2026',
        location: 'Convention Hall Unand',
        isVerified: true,
      ),
      if (dummyCampusPosts.isNotEmpty) dummyCampusPosts.first,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // ─── 1. Background Wave Lengkungan Asimetris Hijau ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.46,
            child: CustomPaint(
              painter: _HeaderWavePainter(color: primaryGreen),
            ),
          ),

          // ─── 2. Struktur Utama (Fixed Column - Tanpa Scroll Vertikal) ───
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Atas (Avatar, Greeting, Bell)
                _buildHeader(),

                // Search Bar (Melayang di atas batas lengkungan)
                _buildSearchBar(),

                // Section UKM UNAND (Kartu Putih Horizontal)
                _buildUkmSection(),

                // Section Postingan: Judul
                _buildPostinganHeader(),

                // Section Postingan: Horizontal List (Expanded agar pas & anti-overflow)
                Expanded(
                  child: _buildPostinganList(),
                ),
              ],
            ),
          ),
        ],
      ),
      // ─── 3. Bottom Navigation Bar ───
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. Header (Avatar, Halo Lutfi, Bell Notifikasi)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar Bundar Putih
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Center(
                child: Icon(
                  Icons.groups_rounded,
                  color: primaryGreen,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Teks Sapaan "Halo Lutfi," & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Halo ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'Lutfi,',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Siap menjelajahi UKM di UNAND?',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Ikon Lonceng Notifikasi Outline Hitam
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tidak ada notifikasi baru'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. Search Bar & Filter Button
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
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
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.search_rounded,
                    color: Colors.black,
                    size: 24,
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

          // Kotak Filter Hijau dengan 3 Garis Putih
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 3.5),
                  Container(
                    width: 14,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 3.5),
                  Container(
                    width: 8,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. Section UKM UNAND (Kartu Putih Besar)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildUkmSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: UKM UNAND & Lihat Semua
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'UKM UNAND',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
              InkWell(
                onTap: () {
                  final dummyUkm = Ukm(
                    id: 'ukm-all',
                    name: 'Daftar Seluruh UKM',
                    category: 'Universitas Andalas',
                    description: 'Kumpulan seluruh Unit Kegiatan Mahasiswa di Universitas Andalas.',
                  );
                  Navigator.pushNamed(context, AppRoutes.detail, arguments: dummyUkm);
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal List 4 UKM
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ukmList.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: InkWell(
                    onTap: () {
                      final ukm = Ukm(
                        id: item.id,
                        name: item.name.replaceAll('\n', ' '),
                        category: item.category,
                        description: 'Unit Kegiatan Mahasiswa ${item.name.replaceAll('\n', ' ')} di Universitas Andalas.',
                      );
                      Navigator.pushNamed(context, AppRoutes.detail, arguments: ukm);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 62,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kotak Ikon / Logo
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: item.isBlue ? ukmBlueColor : Colors.black,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: item.isBlue
                                  ? const Icon(
                                      Icons.directions_walk_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Image.asset(
                                        'assets/images/firetech neo.jpeg',
                                        width: 38,
                                        height: 38,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Text(
                                            'TELEMETRI',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Teks Judul Dua Baris
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. Section Postingan Header & List
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildPostinganHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        'Postingan',
        style: TextStyle(
          color: Colors.white,
          fontSize: ,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildPostinganList() {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Container(
          width: screenWidth * 0.78,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Postingan (Avatar, Nama, Tanggal, Badge Capsule "Event")
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/firetech neo.jpeg',
                        width: 22,
                        height: 22,
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.time,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0EFE5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF66BB6A),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Event',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2. Thumbnail (Expanded agar elastis dan anti-overflow)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF1E1E1E),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/hacker.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.smart_toy_rounded,
                                      color: Colors.white70,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Soft cinematic vignette
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.35),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3. Judul Postingan
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),

              // 4. Footer Postingan (Suka, Komentar, Lihat Postingan)
              Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFE53935),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.initialLikes} Suka',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF616161),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.initialComments} Komentar',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.postDetail,
                        arguments: post,
                      );
                    },
                    child: const Text(
                      'Lihat Postingan >',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Model Data Internal UKM
// ─────────────────────────────────────────────────────────────────────────────
class _UkmItemData {
  final String id;
  final String name;
  final bool isBlue;
  final String category;

  const _UkmItemData({
    required this.id,
    required this.name,
    required this.isBlue,
    required this.category,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter Lengkungan Asimetris Hijau (#2C6E49)
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderWavePainter extends CustomPainter {
  final Color color;

  const _HeaderWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    // Garis atas dari kiri ke sekitar 56% lebar layar
    path.lineTo(size.width * 0.56, 0);

    // Lengkungan halus pertama ke arah kanan-bawah
    path.cubicTo(
      size.width * 0.68,
      size.height * 0.15,
      size.width * 0.72,
      size.height * 0.40,
      size.width * 0.58,
      size.height * 0.62,
    );

    // Lengkungan kedua meliuk kembali ke sisi kiri bawah
    path.cubicTo(
      size.width * 0.44,
      size.height * 0.84,
      size.width * 0.08,
      size.height * 0.92,
      0,
      size.height,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeaderWavePainter oldDelegate) =>
      oldDelegate.color != color;
}
