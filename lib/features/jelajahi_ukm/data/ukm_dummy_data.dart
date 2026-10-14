import 'package:flutter/material.dart';

import '../../../models/ukm.dart';

/// Dummy dataset for the 20 organizations at Universitas Andalas.
/// Kept as a plain constant list — no backend or database needed for FR-01.
const List<Ukm> kDummyUkmList = [
  Ukm(
    name: 'UKPM Genta Andalas',
    description: 'Jurnalis kampus, nulis berita & liputan acara.',
    icon: Icons.newspaper_rounded,
    color: Color(0xFF1E88E5), // Jurnalistik: biru
  ),
  Ukm(
    name: 'UKM Seni (UKS)',
    description:
        'Wadah seni dengan divisi vokal, teater, musik, tari, seni rupa.',
    icon: Icons.palette_rounded,
    color: Color(0xFF8E24AA), // Seni: ungu
  ),
  Ukm(
    name: 'FKI Rabbani',
    description: 'Dakwah Islam & kajian keagamaan kampus.',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF16A34A), // Keislaman: hijau
  ),
  Ukm(
    name: 'UKM Olahraga (UKO)',
    description: 'Olahraga beragam: futsal, basket, voli, badminton, dll.',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFEA580C), // Olahraga: oranye
  ),
  Ukm(
    name: 'AIESEC',
    description: 'Kepemimpinan & pertukaran pelajar internasional.',
    icon: Icons.public_rounded,
    color: Color(0xFF0284C7), // Internasional / kepemimpinan: biru muda
  ),
  Ukm(
    name: 'MAPALA UNAND',
    description: 'Pencinta alam, panjat tebing & aktivitas alam liar.',
    icon: Icons.terrain_rounded,
    color: Color(0xFF2D6A4F), // Pencinta alam: hijau alam
  ),
  Ukm(
    name: 'Neo Telemetri',
    description: 'IT, robotika, multimedia & teknologi informasi.',
    icon: Icons.computer_rounded,
    color: Color(0xFF0D9488), // Teknologi: teal
  ),
  Ukm(
    name: 'Pandekar',
    description: 'Bela diri silat & kesenian tradisional Minangkabau.',
    icon: Icons.sports_martial_arts_rounded,
    color: Color(0xFFF97316), // Bela diri: oranye
  ),
  Ukm(
    name: 'UKM PHP',
    description: 'Pengenalan hukum & politik, diskusi isu-isu aktual.',
    icon: Icons.gavel_rounded,
    color: Color(0xFF3949AB), // Hukum & Politik: indigo
  ),
  Ukm(
    name: 'KSR PMI Unit UNAND',
    description: 'Relawan kesehatan & bantuan bencana kampus.',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFE11D48), // Kemanusiaan: merah
  ),
  Ukm(
    name: 'KOPMA',
    description: 'Koperasi mahasiswa, belajar wirausaha & manajemen bisnis.',
    icon: Icons.store_rounded,
    color: Color(0xFFD97706), // Kewirausahaan: amber
  ),
  Ukm(
    name: 'Andalas Sinematografi',
    description: 'Produksi film, videografi & editing multimedia.',
    icon: Icons.videocam_rounded,
    color: Color(0xFF7C3AED), // Sinematografi: ungu
  ),
  Ukm(
    name: 'UKM Penalaran',
    description: 'Riset ilmiah, karya tulis & diskusi kritis.',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF4338CA), // Penalaran: indigo
  ),
  Ukm(
    name: 'UKM PIKA',
    description: 'Pengembangan ilmu Al-Qur\'an, tahsin & tilawah.',
    icon: Icons.mosque_rounded,
    color: Color(0xFF059669), // Al-Qur'an: hijau
  ),
  Ukm(
    name: 'PIKMAG',
    description: 'Konseling mahasiswa & layanan kesejahteraan kampus.',
    icon: Icons.support_agent_rounded,
    color: Color(0xFFE11D48), // Kemanusiaan / kesehatan: merah
  ),
  Ukm(
    name: 'HIPMI PT UNAND',
    description: 'Jaringan pengusuda muda & pengembangan wirausaha.',
    icon: Icons.business_center_rounded,
    color: Color(0xFFB45309), // Kewirausahaan: amber
  ),
  Ukm(
    name: 'Kosbema',
    description: 'Siaga bencana & penanggulangan bencana alam kampus.',
    icon: Icons.health_and_safety_rounded,
    color: Color(0xFF15803D), // Kebencanaan: hijau alam
  ),
  Ukm(
    name: 'ADS (Andalas Debating Society)',
    description: 'Debat Bahasa Inggris & public speaking.',
    icon: Icons.record_voice_over_rounded,
    color: Color(0xFF4F46E5), // Debat: indigo
  ),
  Ukm(
    name: 'Pramuka (Racana Swarnadwipa)',
    description:
        'Proses pendidikan di luar lingkungan melalui kegiatan yang beragam.',
    icon: Icons.explore_rounded,
    color: Color(0xFF8D6E63), // Pramuka: warna bumi
  ),
  Ukm(
    name: 'Menwa (Resimen Mahasiswa)',
    description: 'Latihan disiplin militer & pengamanan kampus.',
    icon: Icons.military_tech_rounded,
    color: Color(0xFF1E3A8A), // Menwa: biru tua
  ),
];
