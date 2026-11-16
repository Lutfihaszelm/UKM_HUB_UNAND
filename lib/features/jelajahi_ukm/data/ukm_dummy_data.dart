import 'package:flutter/material.dart';

import '../models/ukm.dart';

/// Dummy dataset 20 UKM Universitas Andalas untuk Modul 1.
///
/// Nama, urutan, dan deskripsi dipertahankan dari data awal agar test lama
/// tetap relevan. Field tambahan (id, kategori, kontak, jumlah pengikut,
/// logo, sejarah) mengikuti kebutuhan UI baru dan siap dipetakan ke
/// `docs/api-contract.md` saat backend tersedia.
const List<Ukm> _rawDummyUkmList = [
  Ukm(
    id: 'ukm-01',
    name: 'UKPM Genta Andalas',
    description: 'Jurnalis kampus, nulis berita & liputan acara.',
    icon: Icons.newspaper_rounded,
    color: Color(0xFF1E88E5),
    category: 'Media',
    contact: 'gentaandalas@unand.ac.id',
    instagram: '@gentaandalas',
    email: 'gentaandalas@unand.ac.id',
    followerCount: 1240,
  ),
  Ukm(
    id: 'ukm-02',
    name: 'UKM Seni (UKS)',
    description:
        'Wadah seni dengan divisi vokal, teater, musik, tari, seni rupa.',
    icon: Icons.palette_rounded,
    color: Color(0xFF8E24AA),
    category: 'Seni',
    contact: 'ukmseni@unand.ac.id',
    instagram: '@ukmseni.unand',
    email: 'ukmseni@unand.ac.id',
    website: 'https://ukmseni.unand.ac.id',
    followerCount: 980,
    hasOpenOprec: true,
  ),
  Ukm(
    id: 'ukm-03',
    name: 'FKI Rabbani',
    description: 'Dakwah Islam & kajian keagamaan kampus.',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF16A34A),
    category: 'Keagamaan',
    contact: 'fkrabbani@unand.ac.id',
    instagram: '@fkrabbani.unand',
    email: 'fkrabbani@unand.ac.id',
    followerCount: 1560,
  ),
  Ukm(
    id: 'ukm-04',
    name: 'UKM Olahraga (UKO)',
    description: 'Olahraga beragam: futsal, basket, voli, badminton, dll.',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFEA580C),
    category: 'Olahraga',
    contact: 'uko@unand.ac.id',
    instagram: '@uko.unand',
    email: 'uko@unand.ac.id',
    followerCount: 2100,
  ),
  Ukm(
    id: 'ukm-05',
    name: 'AIESEC',
    description: 'Peace and Fulfillment of Humankind\'s Potential.',
    icon: Icons.public_rounded,
    color: Color(0xFF0284C7),
    category: 'Kepemimpinan',
    contact: 'aiesec@unand.ac.id',
    instagram: '@aiesec.unand',
    email: 'aiesec@unand.ac.id',
    website: 'https://aiesec.org',
    logoUrl: 'assets/images/Logo_AIESEC.png',
    followerCount: 3200,
    hasOpenOprec: true,
    followedByMe: true,
  ),
  Ukm(
    id: 'ukm-06',
    name: 'MAPALA UNAND',
    description: 'Pencinta alam, panjat tebing & aktivitas alam liar.',
    icon: Icons.terrain_rounded,
    color: Color(0xFFB91C1C),
    category: 'Pencinta Alam',
    contact: 'mapala@unand.ac.id',
    instagram: '@mapala.unand',
    email: 'mapala@unand.ac.id',
    website: 'https://mapalaunand.org',
    followerCount: 870,
  ),
  Ukm(
    id: 'ukm-07',
    name: 'Neo Telemetri',
    description: 'IT, robotika, multimedia & teknologi informasi.',
    icon: Icons.computer_rounded,
    color: Color(0xFF1D4ED8),
    category: 'Teknologi',
    contact: 'neotelemetri@unand.ac.id',
    instagram: '@neotelemetri',
    email: 'neotelemetri@unand.ac.id',
    website: 'https://neotelemetri.com',
    followerCount: 2450,
    hasOpenOprec: true,
    followedByMe: true,
  ),
  Ukm(
    id: 'ukm-08',
    name: 'Pandekar',
    description: 'Bela diri silat & kesenian tradisional Minangkabau.',
    icon: Icons.sports_martial_arts_rounded,
    color: Color(0xFFF97316),
    category: 'Bela Diri',
    contact: 'pandekar@unand.ac.id',
    instagram: '@pandekar.unand',
    email: 'pandekar@unand.ac.id',
    followerCount: 640,
  ),
  Ukm(
    id: 'ukm-09',
    name: 'UKM PHP',
    description: 'Pengenalan hukum & politik, diskusi isu-isu aktual.',
    icon: Icons.gavel_rounded,
    color: Color(0xFF3949AB),
    category: 'Hukum & Politik',
    contact: 'ukmphp@unand.ac.id',
    instagram: '@ukmphp.unand',
    email: 'ukmphp@unand.ac.id',
    followerCount: 720,
  ),
  Ukm(
    id: 'ukm-10',
    name: 'KSR PMI Unit UNAND',
    description: 'Relawan kesehatan & bantuan bencana kampus.',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFE11D48),
    category: 'Kemanusiaan',
    contact: 'ksr@unand.ac.id',
    instagram: '@ksrpmi.unand',
    email: 'ksr@unand.ac.id',
    followerCount: 1100,
  ),
  Ukm(
    id: 'ukm-11',
    name: 'KOPMA',
    description: 'Koperasi mahasiswa, belajar wirausaha & manajemen bisnis.',
    icon: Icons.store_rounded,
    color: Color(0xFFD97706),
    category: 'Kewirausahaan',
    contact: 'kopma@unand.ac.id',
    instagram: '@kopma.unand',
    email: 'kopma@unand.ac.id',
    followerCount: 540,
  ),
  Ukm(
    id: 'ukm-12',
    name: 'Andalas Sinematografi',
    description: 'Produksi film, videografi & editing multimedia.',
    icon: Icons.videocam_rounded,
    color: Color(0xFF7C3AED),
    category: 'Sinematografi',
    contact: 'sinematografi@unand.ac.id',
    instagram: '@andalassinematografi',
    email: 'sinematografi@unand.ac.id',
    followerCount: 780,
    hasOpenOprec: true,
  ),
  Ukm(
    id: 'ukm-13',
    name: 'UKM Penalaran',
    description: 'Riset ilmiah, karya tulis & diskusi kritis.',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF4338CA),
    category: 'Penalaran',
    contact: 'penalaran@unand.ac.id',
    instagram: '@ukmpenalaran',
    email: 'penalaran@unand.ac.id',
    followerCount: 960,
  ),
  Ukm(
    id: 'ukm-14',
    name: 'UKM PIKA',
    description: 'Pengembangan ilmu Al-Qur\'an, tahsin & tilawah.',
    icon: Icons.mosque_rounded,
    color: Color(0xFF059669),
    category: 'Keagamaan',
    contact: 'ukmpika@unand.ac.id',
    instagram: '@ukmpika.unand',
    email: 'ukmpika@unand.ac.id',
    followerCount: 830,
  ),
  Ukm(
    id: 'ukm-15',
    name: 'PIKMAG',
    description: 'Konseling mahasiswa & layanan kesejahteraan kampus.',
    icon: Icons.support_agent_rounded,
    color: Color(0xFFE11D48),
    category: 'Konseling',
    contact: 'pikmag@unand.ac.id',
    instagram: '@pikmag.unand',
    email: 'pikmag@unand.ac.id',
    followerCount: 410,
  ),
  Ukm(
    id: 'ukm-16',
    name: 'HIPMI PT UNAND',
    description: 'Jaringan pengusaha muda & pengembangan wirausaha.',
    icon: Icons.business_center_rounded,
    color: Color(0xFFB45309),
    category: 'Kewirausahaan',
    contact: 'hipmi@unand.ac.id',
    instagram: '@hipmi.unand',
    email: 'hipmi@unand.ac.id',
    followerCount: 390,
  ),
  Ukm(
    id: 'ukm-17',
    name: 'Kosbema',
    description: 'Siaga bencana & penanggulangan bencana alam kampus.',
    icon: Icons.health_and_safety_rounded,
    color: Color(0xFF15803D),
    category: 'Kebencanaan',
    contact: 'kosbema@unand.ac.id',
    instagram: '@kosbema.unand',
    email: 'kosbema@unand.ac.id',
    followerCount: 360,
  ),
  Ukm(
    id: 'ukm-18',
    name: 'ADS (Andalas Debating Society)',
    description: 'Debat Bahasa Inggris & public speaking.',
    icon: Icons.record_voice_over_rounded,
    color: Color(0xFF4F46E5),
    category: 'Debat',
    contact: 'ads@unand.ac.id',
    instagram: '@ads.unand',
    email: 'ads@unand.ac.id',
    followerCount: 690,
  ),
  Ukm(
    id: 'ukm-19',
    name: 'Pramuka (Racana Swarnadwipa)',
    description:
        'Proses pendidikan di luar lingkungan melalui kegiatan yang beragam.',
    icon: Icons.explore_rounded,
    color: Color(0xFF8D6E63),
    category: 'Pramuka',
    contact: 'pramuka@unand.ac.id',
    instagram: '@racana.swarnadwipa',
    email: 'pramuka@unand.ac.id',
    followerCount: 1020,
  ),
  Ukm(
    id: 'ukm-20',
    name: 'Menwa (Resimen Mahasiswa)',
    description: 'Latihan disiplin militer & pengamanan kampus.',
    icon: Icons.military_tech_rounded,
    color: Color(0xFF1E3A8A),
    category: 'Bela Negara',
    contact: 'menwa@unand.ac.id',
    instagram: '@menwa.unand',
    email: 'menwa@unand.ac.id',
    followerCount: 750,
  ),
];

/// Urutan tampilan awal mengikuti desain Figma: AIESEC, Neo Telemetri, lalu
/// MAPALA. Data tetap 20 UKM; tiga kartu ini hanya dipindahkan ke depan.
const List<String> _featuredUkmIds = ['ukm-05', 'ukm-07', 'ukm-06'];

/// Daftar final yang dipakai aplikasi. Sejarah dibangun otomatis agar semua
/// profil punya section "Sejarah" tanpa mengulang teks panjang di setiap data.
final List<Ukm> kDummyUkmList = List<Ukm>.unmodifiable(
  [
    for (final id in _featuredUkmIds)
      _rawDummyUkmList.firstWhere((ukm) => ukm.id == id),
    ..._rawDummyUkmList.where((ukm) => !_featuredUkmIds.contains(ukm.id)),
  ].map((ukm) => ukm.copyWith(history: _buildHistory(ukm))),
);

/// ID yang dianggap sudah diikuti saat aplikasi pertama kali dibuka.
/// Setelah pengguna mengubah follow, nilai di SharedPreferences yang dipakai.
const Set<String> kInitialFollowedUkmIds = {'ukm-05', 'ukm-07'};

String _buildHistory(Ukm ukm) {
  final category = ukm.category?.toLowerCase() ?? 'kegiatan mahasiswa';
  return '${ukm.name} lahir dari kebutuhan mahasiswa Universitas Andalas '
      'untuk memiliki ruang belajar, berkarya, dan bertumbuh di bidang '
      '$category. Sejak awal berdiri, organisasi ini tumbuh bersama '
      'anggota-anggotanya melalui program kerja, pelatihan, dan kegiatan '
      'kolaboratif di lingkungan kampus. Hingga kini, ${ukm.name} terus '
      'membuka kesempatan bagi mahasiswa yang ingin mengembangkan minat, '
      'kemampuan, dan jejaring yang bermanfaat.';
}
