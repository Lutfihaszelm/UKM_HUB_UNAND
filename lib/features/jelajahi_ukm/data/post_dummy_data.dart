import '../../../models/post.dart';

/// Dummy posts for development. Each post references a UKM by id.
/// Categories: event, lomba, prestasi, oprec, pengumuman.
final List<Post> kDummyPostList = [
  Post(
    id: 'post-01',
    ukmId: 'ukm-07',
    ukmName: 'Neo Telemetri',
    title: 'Workshop Flutter & Dart 2026',
    content:
        'Neo Telemetri mengadakan workshop Flutter intensif selama 2 hari. '
        'Peserta akan belajar state management, REST API integration, dan deployment. '
        'Kuota terbatas 40 orang, daftar sekarang!',
    kategori: 'event',
    tanggal: DateTime(2026, 11, 13),
    likes: 128,
    comments: 5,
  ),
  Post(
    id: 'post-02',
    ukmId: 'ukm-07',
    ukmName: 'Neo Telemetri',
    title: 'Open Recruitment Neo Telemetri 2026',
    content:
        'Hai mahasiswa Unand! Neo Telemetri membuka rekrutmen anggota baru untuk periode '
        '2026/2027. Divisi yang tersedia: Programming, Multimedia, dan Networking. '
        'Pendaftaran dibuka hingga 15 November 2026.',
    kategori: 'oprec',
    tanggal: DateTime(2026, 10, 20),
    likes: 95,
    comments: 12,
  ),
  Post(
    id: 'post-03',
    ukmId: 'ukm-01',
    ukmName: 'UKPM Genta Andalas',
    title: 'Lomba Jurnalistik Nasional 2026',
    content:
        'UKPM Genta Andalas mengirimkan delegasi ke Lomba Jurnalistik Nasional '
        'yang diselenggarakan di Jakarta. Mari dukung tim kita!',
    kategori: 'lomba',
    tanggal: DateTime(2026, 10, 18),
    likes: 74,
    comments: 8,
  ),
  Post(
    id: 'post-04',
    ukmId: 'ukm-04',
    ukmName: 'UKM Olahraga (UKO)',
    title: 'Turnamen Futsal Antar Fakultas',
    content:
        'UKO menyelenggarakan turnamen futsal antar fakultas. Pendaftaran tim '
        'dibuka mulai 1 November. Hadiah total Rp5.000.000 untuk juara 1-3.',
    kategori: 'event',
    tanggal: DateTime(2026, 10, 15),
    likes: 156,
    comments: 23,
  ),
  Post(
    id: 'post-05',
    ukmId: 'ukm-18',
    ukmName: 'ADS (Andalas Debating Society)',
    title: 'Juara 2 National University Debating Championship',
    content:
        'Tim ADS berhasil meraih Juara 2 di NUDC 2026 yang diselenggarakan '
        'di Universitas Gadjah Mada. Selamat kepada seluruh anggota tim!',
    kategori: 'prestasi',
    tanggal: DateTime(2026, 10, 12),
    likes: 210,
    comments: 31,
  ),
  Post(
    id: 'post-06',
    ukmId: 'ukm-02',
    ukmName: 'UKM Seni (UKS)',
    title: 'Pentas Seni Akhir Tahun 2026',
    content:
        'UKM Seni mengundang seluruh civitas akademika untuk hadir di Pentas '
        'Seni Akhir Tahun. Akan ada pertunjukan teater, tari, dan musik live.',
    kategori: 'event',
    tanggal: DateTime(2026, 10, 10),
    likes: 89,
    comments: 7,
  ),
  Post(
    id: 'post-07',
    ukmId: 'ukm-06',
    ukmName: 'MAPALA UNAND',
    title: 'Pengumuman: Pendakian Gunung Marapi',
    content:
        'Pendakian rutin MAPALA ke Gunung Marapi dijadwalkan tanggal 5-7 November. '
        'Peserta wajib mengikuti briefing pada 2 November di Sekretariat.',
    kategori: 'pengumuman',
    tanggal: DateTime(2026, 10, 8),
    likes: 62,
    comments: 14,
  ),
  Post(
    id: 'post-08',
    ukmId: 'ukm-03',
    ukmName: 'FKI Rabbani',
    title: 'Kajian Rutin: Fiqih Muamalah',
    content:
        'FKI Rabbani mengadakan kajian rutin dengan tema Fiqih Muamalah '
        'bersama Ustadz Ahmad. Tempat: Masjid Kampus, Jumat pukul 13.30 WIB.',
    kategori: 'event',
    tanggal: DateTime(2026, 10, 5),
    likes: 45,
    comments: 3,
  ),
  Post(
    id: 'post-09',
    ukmId: 'ukm-12',
    ukmName: 'Andalas Sinematografi',
    title: 'Open Recruitment Divisi Videografi',
    content:
        'Andalas Sinematografi membuka perekrutan khusus divisi Videografi. '
        'Kamu yang suka bikin konten video, yuk gabung! Deadline: 30 Oktober.',
    kategori: 'oprec',
    tanggal: DateTime(2026, 10, 3),
    likes: 53,
    comments: 9,
  ),
  Post(
    id: 'post-10',
    ukmId: 'ukm-10',
    ukmName: 'KSR PMI Unit UNAND',
    title: 'Donor Darah Massal Oktober 2026',
    content:
        'KSR PMI Unit UNAND bekerja sama dengan PMI Kota Padang mengadakan '
        'donor darah massal. Lokasi: Gedung PKM Lt.1, tanggal 28 Oktober.',
    kategori: 'event',
    tanggal: DateTime(2026, 10, 1),
    likes: 112,
    comments: 6,
  ),
  Post(
    id: 'post-11',
    ukmId: 'ukm-05',
    ukmName: 'AIESEC',
    title: 'Global Village: Cultural Exchange Festival',
    content:
        'AIESEC Unand menghadirkan Global Village, festival pertukaran budaya '
        'dengan mahasiswa asing. Ada booth makanan, pertunjukan, dan talkshow.',
    kategori: 'event',
    tanggal: DateTime(2026, 9, 28),
    likes: 187,
    comments: 19,
  ),
  Post(
    id: 'post-12',
    ukmId: 'ukm-13',
    ukmName: 'UKM Penalaran',
    title: 'Tim Unand Raih Emas di PIMNAS 2026',
    content:
        'Tim PKM dari UKM Penalaran berhasil meraih medali emas di PIMNAS 2026 '
        'untuk kategori PKM-KC. Prestasi gemilang untuk Universitas Andalas!',
    kategori: 'prestasi',
    tanggal: DateTime(2026, 9, 25),
    likes: 245,
    comments: 28,
  ),
];
