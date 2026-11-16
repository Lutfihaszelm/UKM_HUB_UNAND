import '../models/post.dart';

/// Dummy 12 postingan UKM untuk Modul 1.
///
/// Bentuk field mengikuti objek Post di kontrak API. Saat backend siap,
/// `FakePostRepository` tinggal diganti implementasi HTTP tanpa mengubah UI.
final List<Post> kDummyPostList = [
  Post(
    id: 'post-01',
    category: 'event',
    badge: 'Workshop',
    author: const PostAuthor(
      id: 'ukm-07',
      name: 'Neo Telemetri',
      isVerified: true,
    ),
    title: 'Workshop Flutter & Dart 2026',
    description: 'Workshop Flutter intensif dua hari untuk mahasiswa Unand. Kuota terbatas 40 orang.',
    content:
        'Neo Telemetri mengadakan workshop Flutter intensif selama dua hari. '
        'Peserta akan belajar state management, integrasi REST API, dan proses '
        'deployment aplikasi mobile.\n\n'
        'Workshop terbuka untuk seluruh mahasiswa Universitas Andalas. Kuota '
        'terbatas 40 orang dan pendaftaran ditutup setelah kuota terpenuhi. '
        'Peserta yang menyelesaikan seluruh sesi akan mendapatkan sertifikat.',
    location: 'Gedung PKM Universitas Andalas',
    tags: const ['#Flutter', '#Workshop', '#NeoTelemetri'],
    bannerUrl: 'assets/images/firetech neo.jpeg',
    likeCount: 128,
    commentCount: 5,
    publishedAt: DateTime(2026, 11, 13, 9, 0),
    attachments: const [
      PostAttachment(
        id: 'att-01',
        type: 'document',
        name: 'Panduan Workshop Flutter.pdf',
        sizeBytes: 245760,
      ),
    ],
  ),
  Post(
    id: 'post-02',
    category: 'oprec',
    badge: 'Open Recruitment',
    author: const PostAuthor(
      id: 'ukm-07',
      name: 'Neo Telemetri',
      isVerified: true,
    ),
    title: 'Open Recruitment Neo Telemetri 2026',
    description: 'Rekrutmen anggota baru periode 2026/2027 untuk divisi Programming, Multimedia, dan Networking.',
    content:
        'Hai mahasiswa Unand! Neo Telemetri membuka rekrutmen anggota baru '
        'untuk periode 2026/2027. Divisi yang tersedia: Programming, '
        'Multimedia, dan Networking.\n\n'
        'Pendaftaran dibuka hingga 15 November 2026. Seleksi terdiri dari '
        'tahap berkas dan wawancara. Informasi lengkap dapat dilihat pada '
        'booklet yang terlampir.',
    location: 'Sekretariat Neo Telemetri',
    tags: const ['#Oprec', '#NeoTelemetri', '#MahasiswaUnand'],
    bannerUrl: 'assets/images/hacker.jpg',
    likeCount: 95,
    commentCount: 12,
    publishedAt: DateTime(2026, 11, 10, 8, 30),
    attachments: const [
      PostAttachment(
        id: 'att-02',
        type: 'document',
        name: 'Booklet Oprec Neo Telemetri.pdf',
        sizeBytes: 1048576,
      ),
    ],
  ),
  Post(
    id: 'post-03',
    category: 'lomba',
    badge: 'Lomba Nasional',
    author: const PostAuthor(
      id: 'ukm-01',
      name: 'UKPM Genta Andalas',
      isVerified: true,
    ),
    title: 'Lomba Jurnalistik Nasional 2026',
    description: 'Delegasi UKPM Genta Andalas berangkat ke Jakarta untuk Lomba Jurnalistik Nasional.',
    content:
        'UKPM Genta Andalas mengirimkan delegasi ke Lomba Jurnalistik Nasional '
        'yang diselenggarakan di Jakarta. Tim akan mengikuti kategori liputan '
        'mendalam, fotografi jurnalistik, dan desain majalah.\n\n'
        'Mari dukung perwakilan Universitas Andalas di kompetisi ini. '
        'Pengumuman pemenang akan disampaikan melalui kanal resmi UKPM Genta '
        'Andalas.',
    location: 'Jakarta',
    tags: const ['#Jurnalistik', '#GentaAndalas', '#LombaNasional'],
    likeCount: 74,
    commentCount: 8,
    publishedAt: DateTime(2026, 11, 8, 10, 0),
  ),
  Post(
    id: 'post-04',
    category: 'event',
    badge: 'Turnamen',
    author: const PostAuthor(
      id: 'ukm-04',
      name: 'UKM Olahraga (UKO)',
      isVerified: true,
    ),
    title: 'Turnamen Futsal Antar Fakultas',
    description: 'Turnamen futsal antar fakultas dengan total hadiah Rp5.000.000 untuk juara 1-3.',
    content:
        'UKO menyelenggarakan turnamen futsal antar fakultas. Pendaftaran tim '
        'dibuka mulai 1 November 2026. Setiap fakultas dapat mengirimkan '
        'maksimal dua tim.\n\n'
        'Hadiah total Rp5.000.000 untuk juara 1-3. Pertandingan dilaksanakan '
        'di lapangan futsal kampus Limau Manis setiap akhir pekan.',
    location: 'Lapangan Futsal Limau Manis',
    tags: const ['#Futsal', '#UKO', '#TurnamenKampus'],
    likeCount: 156,
    commentCount: 23,
    publishedAt: DateTime(2026, 11, 6, 16, 0),
  ),
  Post(
    id: 'post-05',
    category: 'prestasi',
    badge: 'Prestasi',
    author: const PostAuthor(
      id: 'ukm-18',
      name: 'ADS (Andalas Debating Society)',
      isVerified: true,
    ),
    title: 'Juara 2 National University Debating Championship',
    description: 'Tim ADS meraih Juara 2 di NUDC 2026 yang digelar di Universitas Gadjah Mada.',
    content:
        'Tim ADS berhasil meraih Juara 2 di National University Debating '
        'Championship (NUDC) 2026 yang diselenggarakan di Universitas Gadjah '
        'Mada.\n\n'
        'Selamat kepada seluruh anggota tim dan pelatih yang telah berlatih '
        'keras. Prestasi ini menjadi langkah penting bagi pengembangan budaya '
        'debat di Universitas Andalas.',
    location: 'Universitas Gadjah Mada, Yogyakarta',
    tags: const ['#Debat', '#NUDC2026', '#PrestasiUnand'],
    likeCount: 210,
    commentCount: 31,
    publishedAt: DateTime(2026, 11, 4, 14, 0),
  ),
  Post(
    id: 'post-06',
    category: 'event',
    badge: 'Pentas Seni',
    author: const PostAuthor(
      id: 'ukm-02',
      name: 'UKM Seni (UKS)',
      isVerified: true,
    ),
    title: 'Pentas Seni Akhir Tahun 2026',
    description: 'Pertunjukan teater, tari, dan musik live dari mahasiswa Universitas Andalas.',
    content:
        'UKM Seni mengundang seluruh civitas akademika untuk hadir di Pentas '
        'Seni Akhir Tahun. Akan ada pertunjukan teater, tari, dan musik live '
        'dari divisi-divisi UKM Seni.\n\n'
        'Acara terbuka untuk umum dan tidak memungut biaya masuk. Mari '
        'apresiasi karya mahasiswa Universitas Andalas.',
    location: 'Auditorium Universitas Andalas',
    tags: const ['#Seni', '#PentasSeni', '#UKMSeni'],
    bannerUrl: 'assets/images/what next.jpg',
    likeCount: 89,
    commentCount: 7,
    publishedAt: DateTime(2026, 11, 2, 19, 0),
  ),
  Post(
    id: 'post-07',
    category: 'pengumuman',
    badge: 'Pengumuman',
    author: const PostAuthor(
      id: 'ukm-06',
      name: 'MAPALA UNAND',
      isVerified: true,
    ),
    title: 'Pendakian Gunung Marapi',
    description: 'Pendakian rutin 5-7 November. Peserta wajib mengikuti briefing pada 2 November.',
    content:
        'Pendakian rutin MAPALA ke Gunung Marapi dijadwalkan tanggal 5-7 '
        'November 2026. Peserta wajib mengikuti briefing pada 2 November di '
        'Sekretariat MAPALA.\n\n'
        'Perlengkapan standar pendakian wajib dibawa masing-masing peserta. '
        'Keputusan akhir mengenai keberangkatan akan menyesuaikan kondisi cuaca '
        'dan status jalur pendakian.',
    location: 'Gunung Marapi, Sumatera Barat',
    tags: const ['#Mapala', '#Pendakian', '#Marapi'],
    bannerUrl: 'assets/images/karhutla.jpg',
    likeCount: 62,
    commentCount: 14,
    publishedAt: DateTime(2026, 10, 31, 11, 0),
  ),
  Post(
    id: 'post-08',
    category: 'event',
    badge: 'Kajian',
    author: const PostAuthor(
      id: 'ukm-03',
      name: 'FKI Rabbani',
      isVerified: true,
    ),
    title: 'Kajian Rutin: Fiqih Muamalah',
    description: 'Kajian rutin bersama Ustadz Ahmad di Masjid Kampus, Jumat pukul 13.30 WIB.',
    content:
        'FKI Rabbani mengadakan kajian rutin dengan tema Fiqih Muamalah '
        'bersama Ustadz Ahmad. Kajian berlangsung di Masjid Kampus pada hari '
        'Jumat pukul 13.30 WIB.\n\n'
        'Kajian terbuka untuk seluruh mahasiswa. Peserta disarankan membawa '
        'Al-Qur\'an dan buku catatan.',
    location: 'Masjid Kampus Universitas Andalas',
    tags: const ['#Kajian', '#Rabbani', '#FiqihMuamalah'],
    likeCount: 45,
    commentCount: 3,
    publishedAt: DateTime(2026, 10, 29, 13, 30),
  ),
  Post(
    id: 'post-09',
    category: 'oprec',
    badge: 'Open Recruitment',
    author: const PostAuthor(
      id: 'ukm-12',
      name: 'Andalas Sinematografi',
      isVerified: true,
    ),
    title: 'Open Recruitment Divisi Videografi',
    description: 'Perekrutan khusus divisi Videografi untuk mahasiswa yang suka membuat konten video.',
    content:
        'Andalas Sinematografi membuka perekrutan khusus divisi Videografi. '
        'Kamu yang suka membuat konten video, menulis naskah, atau mengedit '
        'gambar bergerak, yuk gabung!\n\n'
        'Pendaftaran ditutup 10 November 2026. Portofolio tidak wajib, tetapi '
        'menjadi nilai tambah.',
    location: 'Sekretariat Andalas Sinematografi',
    tags: const ['#Oprec', '#Videografi', '#Sinematografi'],
    bannerUrl: 'assets/images/wowok.jpg',
    likeCount: 53,
    commentCount: 9,
    publishedAt: DateTime(2026, 10, 27, 9, 0),
  ),
  Post(
    id: 'post-10',
    category: 'event',
    badge: 'Sosial',
    author: const PostAuthor(
      id: 'ukm-10',
      name: 'KSR PMI Unit UNAND',
      isVerified: true,
    ),
    title: 'Donor Darah Massal Oktober 2026',
    description:
        'Donor darah massal bersama PMI Kota Padang di Gedung PKM lantai 1.',
    content:
        'KSR PMI Unit UNAND bekerja sama dengan PMI Kota Padang mengadakan '
        'donor darah massal. Kegiatan berlangsung di Gedung PKM lantai 1 pada '
        '28 Oktober 2026 pukul 08.00-14.00 WIB.\n\n'
        'Pendonor wajib membawa kartu identitas dan dalam kondisi sehat. '
        'Setiap pendonor mendapatkan paket makanan dan pemeriksaan kesehatan '
        'gratis.',
    location: 'Gedung PKM Lantai 1',
    tags: const ['#DonorDarah', '#KSRPMI', '#Sosial'],
    likeCount: 112,
    commentCount: 6,
    publishedAt: DateTime(2026, 10, 24, 8, 0),
  ),
  Post(
    id: 'post-11',
    category: 'event',
    badge: 'Festival Budaya',
    author: const PostAuthor(
      id: 'ukm-05',
      name: 'AIESEC',
      logoUrl: 'assets/images/Logo_AIESEC.png',
      isVerified: true,
    ),
    title: 'Global Village: Cultural Exchange Festival',
    description: 'Festival pertukaran budaya dengan mahasiswa asing, booth makanan, dan talkshow.',
    content:
        'AIESEC Unand menghadirkan Global Village, festival pertukaran budaya '
        'dengan mahasiswa asing. Ada booth makanan, pertunjukan seni, dan '
        'talkshow tentang pengalaman pertukaran pelajar.\n\n'
        'Acara ini terbuka untuk seluruh mahasiswa dan menjadi kesempatan '
        'memperluas wawasan internasional di lingkungan kampus.',
    location: 'Lapangan Rektorat Universitas Andalas',
    tags: const ['#GlobalVillage', '#AIESEC', '#CulturalExchange'],
    bannerUrl: 'assets/images/aiesec.png',
    likeCount: 187,
    commentCount: 19,
    publishedAt: DateTime(2026, 10, 21, 15, 0),
    attachments: const [
      PostAttachment(
        id: 'att-11',
        type: 'image',
        name: 'Poster Global Village.jpg',
        sizeBytes: 512000,
      ),
    ],
  ),
  Post(
    id: 'post-12',
    category: 'prestasi',
    badge: 'Prestasi Nasional',
    author: const PostAuthor(
      id: 'ukm-13',
      name: 'UKM Penalaran',
      isVerified: true,
    ),
    title: 'Tim Unand Raih Emas di PIMNAS 2026',
    description: 'Tim PKM dari UKM Penalaran meraih medali emas kategori PKM-KC di PIMNAS 2026.',
    content:
        'Tim PKM dari UKM Penalaran berhasil meraih medali emas di Pekan Ilmiah '
        'Mahasiswa Nasional (PIMNAS) 2026 untuk kategori PKM-KC.\n\n'
        'Prestasi ini merupakan hasil kerja keras tim, dosen pembimbing, dan '
        'dukungan Universitas Andalas. Semoga menjadi inspirasi bagi mahasiswa '
        'lain untuk terus berkarya.',
    location: 'PIMNAS 2026',
    tags: const ['#PIMNAS2026', '#PKM', '#PrestasiUnand'],
    bannerUrl: 'assets/images/Poster_JA.jpg',
    likeCount: 245,
    commentCount: 28,
    publishedAt: DateTime(2026, 10, 18, 10, 0),
  ),
];
