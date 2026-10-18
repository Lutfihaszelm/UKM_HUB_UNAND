import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oprec_post.dart';
import 'fake_oprec_repository.dart';
import 'oprec_repository.dart';

/// Satu instance repository untuk seluruh aplikasi, supaya data pendaftaran
/// tidak hilang saat pindah halaman. Nanti cukup ganti ke repository API.
final oprecRepositoryProvider =
    Provider<OprecRepository>((ref) => FakeOprecRepository());

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
  ),
];
