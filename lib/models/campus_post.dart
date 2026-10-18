import 'package:flutter/material.dart';

/// Model untuk postingan kabar / aktivitas kampus di beranda
class CampusPost {
  final String id;
  final String authorName;
  final String authorSubtitle;
  final String categoryBadge;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? assetImagePath;
  final String bannerTitle;
  final String bannerSubtitle;
  final List<Color> bannerGradient;
  final IconData bannerIcon;
  final String title;
  final String description;
  final String fullContent;
  final List<String> tags;
  final int initialLikes;
  final int initialComments;
  final String time;
  final String location;
  final bool isVerified;

  const CampusPost({
    required this.id,
    required this.authorName,
    required this.authorSubtitle,
    required this.categoryBadge,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.assetImagePath,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.bannerGradient,
    required this.bannerIcon,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.tags,
    required this.initialLikes,
    required this.initialComments,
    required this.time,
    required this.location,
    this.isVerified = true,
  });
}

/// Daftar dummy postingan kampus terkini
final List<CampusPost> dummyCampusPosts = [
  const CampusPost(
    id: 'post-pkm-2026',
    authorName: 'Pojok Statistik Universitas Andalas',
    authorSubtitle: '2 jam lalu • Limau Manis',
    categoryBadge: 'Event Nasional',
    icon: Icons.psychology_rounded,
    iconBgColor: Color(0xFFE8F5E9),
    iconColor: Color(0xFF2C6E49),
    assetImagePath: 'assets/images/what next.jpg',
    bannerTitle: 'WORKSHOP & KOMPETISI\nKARYA TULIS ILMIAH NASIONAL',
    bannerSubtitle: 'PROGRAM KREATIVITAS MAHASISWA (PKM) 2026',
    bannerGradient: [Color(0xFF004528), Color(0xFF1B6D24)],
    bannerIcon: Icons.workspace_premium_rounded,
    title: 'Analisis reaksi gen z saat melihat balasan komentar di instragram dengan gif "WHAT NEXT"',
    description: 'Instragam merupakan media sosial yang biasanya digunakan gen z untuk mengekspresikan dirinya.',
    fullContent:
        'Analisis reaksi gen z saat melihat balasan komentar di instragram dengan gif "WHAT NEXT"',
    tags: ['#PojokStatistik', '#PKMUnand', '#PrestasiKampus', '#RisetMahasiswa'],
    initialLikes: 128,
    initialComments: 24,
    time: '2 jam lalu',
    location: 'Limau Manis',
    isVerified: true,
  ),
  const CampusPost(
    id: 'post-neo-firetech',
    authorName: 'UKM Neo Telemetri',
    authorSubtitle: '5 jam lalu • Gedung PKM Lt. 2',
    categoryBadge: 'Hackathon IT',
    icon: Icons.terminal_rounded,
    iconBgColor: Color(0xFFEFF6FF),
    iconColor: Color(0xFF2563EB),
    assetImagePath: 'assets/images/hacker.jpg',
    bannerTitle: 'FIRETECH 2026 HACKATHON\nNATIONAL IT COMPETITION',
    bannerSubtitle: 'CODE • INNOVATE • DOMINATE • PRIZE POOL 50JT+',
    bannerGradient: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
    bannerIcon: Icons.laptop_chromebook_rounded,
    title: 'FIRETECH 2026: Kompetisi IT & Hackathon Nasional Neo Telemetri Resmi Dibuka!',
    description: 'Tantang kemampuan coding, UI/UX, dan AI tokomu dalam ajang kompetisi teknologi bergengsi...',
    fullContent:
        '🚀 Panggilan bagi seluruh software engineer, UI/UX designer, dan tech enthusiast Universitas Andalas!\n\nUKM Neo Telemetri dengan bangga mempersembahkan FIRETECH 2026: National Hackathon Competition! Kembangkan solusi teknologi inovatif dalam waktu 48 jam nonstop untuk menyelesaikan permasalahan nyata di Indonesia.\n\nKategori Lomba:\n• Hackaton Web & Mobile App Development\n• UI/UX Design\n• Efootbal PES\n• Fats Typing\n\nTotal Hadiah Puluhan Juta Rupiah + Golden Ticket Internship di Top Tech Startup Indonesia! Daftarkan tim kamu sekarang sebelum kuota habis!',
    tags: ['#NeoTelemetri', '#FIRETECH2026', '#HackathonNasional', '#ITUnand', '#LombaCoding'],
    initialLikes: 245,
    initialComments: 38,
    time: '5 jam lalu',
    location: 'Gedung PKM Lt. 2',
    isVerified: true,
  ),
  const CampusPost(
    id: 'post-aiesec-kalimantan',
    authorName: 'AIESEC in Unand',
    authorSubtitle: '1 hari lalu • Youth Hub Unand',
    categoryBadge: 'Youth Volunteer',
    icon: Icons.public_rounded,
    iconBgColor: Color(0xFFF0FDF4),
    iconColor: Color(0xFF0284C7),
    assetImagePath: 'assets/images/karhutla.jpg',
    bannerTitle: 'EXPEDITION TO BORNEO\nKALIMANTAN PROJECT 2026',
    bannerSubtitle: 'YOUTH EXCHANGE • RAINFOREST CONSERVATION • CULTURAL ADVENTURE',
    bannerGradient: [Color(0xFF065F46), Color(0xFF0D9488), Color(0xFF0284C7)],
    bannerIcon: Icons.forest_rounded,
    title: 'Global Volunteer Expedition Borneo 2026: Konservasi Hutan Kalimantan Bersama AIESEC',
    description: 'Program relawan 4 minggu untuk reboisasi, konservasi, dan pertukaran budaya di Kalimantan...',
    fullContent:
        '🌿 Siap menjelajahi jantung hutan Kalimantan dan merasakan pengalaman hidup bersama masyarakat lokal di Nusantara?\n\nAIESEC in Universitas Andalas membuka pendaftaran program "Global Youth Volunteer Project: Expedition Borneo 2026". Kamu akan diajak selama 4 minggu untuk:\n• Menjalankan proyek konservasi satwa dan reboisasi hutan hujan tropis\n• Mengajar literasi digital bagi anak-anak pesisir di sekitar kawasan IKN\n• Eksplorasi keindahan alam tersembunyi Kalimantan dan pertukaran budaya lintas provinsi\n\nFasilitas include: akomodasi, transportasi lokal, sertifikat internasional AIESEC, dan networking global. Jangan lewatkan kesempatan petualangan sekali seumur hidup ini! ✈️🎒',
    tags: ['#AIESECUnand', '#VolunteeringKalimantan', '#JalanJalanBerdampak', '#ExploreBorneo', '#PemudaMaju'],
    initialLikes: 189,
    initialComments: 42,
    time: '1 hari lalu',
    location: 'Youth Hub Unand',
    isVerified: true,
  ),
  const CampusPost(
    id: 'post-bem-dialog',
    authorName: 'BEM KM UNAND',
    authorSubtitle: '3 jam lalu • Gedung PKM',
    categoryBadge: 'Seruan Aksi',
    icon: Icons.campaign_rounded,
    iconBgColor: Color(0xFFFEF2F2),
    iconColor: Color(0xFFDC2626),
        assetImagePath: 'assets/images/wowok.jpg',
    bannerTitle: 'DIALOG TERBUKA MAHASISWA\nKEBIJAKAN PENDIDIKAN 2026',
    bannerSubtitle: 'SUARA MAHASISWA UNAND • UKT BERKEADILAN • TRANSPARANSI ANGGARAN',
    bannerGradient: [Color(0xFF450A0A), Color(0xFF991B1B), Color(0xFFB91C1C)],
    bannerIcon: Icons.gavel_rounded,
    title: 'BEM KM UNAND Gelar Dialog Terbuka Kebijakan Pendidikan dan UKT 2026',
    description: 'BEM KM UNAND mengundang seluruh mahasiswa menyampaikan aspirasi soal UKT dan anggaran pendidikan.',
    fullContent:
        '📢 BEM KM Universitas Andalas mengundang seluruh mahasiswa, ormawa, dan sivitas akademika dalam agenda Dialog Terbuka Kebijakan Pendidikan.\n\n🗓️ Waktu: Kamis, 16 Oktober 2026 | Pukul 15.30 WIB\n📍 Lokasi: Pelataran Gedung PKM Universitas Andalas\n\nPoin pembahasan:\n1. Transparansi alokasi anggaran pendidikan & UKT berkeadilan\n2. Fasilitas dan layanan akademik kampus\n3. Penyampaian aspirasi mahasiswa kepada pimpinan universitas\n\nMari hadir dan sampaikan suaramu!',
    tags: ['#BEMKMUNAND', '#SuaraMahasiswa', '#DialogTerbuka', '#UKTBerkeadilan'],
    initialLikes: 512,
    initialComments: 96,
    time: '3 jam lalu',
    location: 'Gedung PKM',
    isVerified: true,
  ),
];
