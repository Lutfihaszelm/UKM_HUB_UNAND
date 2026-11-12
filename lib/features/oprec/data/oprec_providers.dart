import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oprec_post.dart';
import 'fake_oprec_repository.dart';
import 'oprec_repository.dart';

/// Satu instance repository untuk seluruh aplikasi, supaya data pendaftaran
/// tidak hilang saat pindah halaman. Nanti cukup ganti ke repository API.
final oprecRepositoryProvider = Provider<OprecRepository>(
    (ref) => FakeOprecRepository(posts: kDummyOprecPosts));

/// Postingan oprec dummy (sementara, sebelum terhubung ke API backend admin).
final List<OprecPost> kDummyOprecPosts = [
  OprecPost(
    id: 'oprec-aiesec-2026',
    ukmName: 'AIESEC in UNAND',
    logoUKM: 'assets/images/Logo_AIESEC.png',
    posterAsset: 'assets/images/Poster_JA.jpg',
    title: 'Join AIESEC 2026',
    description: 'Ayo Join AIESEC. '
        'Syarat: mahasiswa aktif Unand, melampirkan CV.',
    closeDate: DateTime.now().add(const Duration(days: 7)),
    requirements: [
      'Mahasiswa aktif Universitas Andalas',
      'Minimal semester 2',
      'Mampu berkomunikasi dalam bahasa Inggris',
      'Bersedia mengikuti seluruh tahap seleksi',
    ],
    requiredFiles: [
      RequiredFile(id: 'aiesec-foto', label: 'Pas Foto', accept: FileAccept.image),
      RequiredFile(id: 'aiesec-ktm', label: 'KTM', accept: FileAccept.image),
      RequiredFile(id: 'aiesec-cv', label: 'CV', accept: FileAccept.pdf),
    ],
    terms: [
      'Seluruh anggota wajib hadir tepat waktu dalam setiap agenda.',
      'Data yang dikirim harus benar dan dapat dipertanggungjawabkan.',
      'Keputusan panitia seleksi tidak dapat diganggu gugat.',
      'Anggota wajib mengikuti seluruh rangkaian kaderisasi resmi.',
    ],
  ),
  OprecPost(
    id: 'oprec-neo-telemetri-2026',
    ukmName: 'UKM Neo Telemetri',
    logoUKM: null,
    title: 'Open Recruitment Anggota Baru Neo Telemetri',
    description: 'Neo Telemetri membuka pendaftaran anggota baru divisi '
        'Programming, Multimedia, dan Jaringan. Syarat: mahasiswa aktif '
        'Unand, melampirkan CV atau portofolio.',
    closeDate: DateTime.now().add(const Duration(days: 10)),
    requirements: [
      'Mahasiswa aktif Universitas Andalas',
      'Tertarik di bidang Programming, Multimedia, atau Jaringan',
    ],
    requiredFiles: [
      RequiredFile(id: 'neo-ktm', label: 'KTM', accept: FileAccept.image),
      RequiredFile(
        id: 'neo-portofolio',
        label: 'CV atau Portofolio',
        accept: FileAccept.any,
      ),
      RequiredFile(
        id: 'neo-sertifikat',
        label: 'Dokumen Tambahan',
        accept: FileAccept.pdf,
        isRequired: false,
      ),
    ],
    terms: [
      'Anggota wajib mengikuti seluruh rangkaian kaderisasi resmi.',
    ],
  ),
];
