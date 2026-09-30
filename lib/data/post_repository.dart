import '../models/post.dart';
class PostRepository {
  static const List<Post> _posts = [
    Post(
      id: '1',
      title: 'Open Recruitment UKM Robotika 2026',
      subtitle: 'UKM Robotika • Open Recruitment',
      description:
          'UKM Robotika membuka pendaftaran anggota baru untuk periode '
          '2026/2027. Terbuka untuk seluruh mahasiswa aktif Universitas '
          'Andalas, tanpa syarat jurusan tertentu.',
    ),
    Post(
      id: '2',
      title: 'Juara 1 Lomba Debat Bahasa Inggris Nasional',
      subtitle: 'UKM Debat Bahasa Inggris • Prestasi',
      description:
          'Tim UKM Debat Bahasa Inggris Universitas Andalas berhasil '
          'meraih Juara 1 pada National University Debating Championship '
          '2026 yang diselenggarakan di Jakarta.',
    ),
    Post(
      id: '3',
      title: 'Konser Amal Peduli Kampus',
      subtitle: 'UKM Musik • Event',
      description:
          'UKM Musik mengadakan konser amal untuk penggalangan dana bagi '
          'korban bencana alam. Terbuka untuk umum, tiket dapat diperoleh '
          'secara gratis melalui pendaftaran di aplikasi.',
    ),
  ];

  /// Mengambil daftar postingan.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Post>> fetchPosts({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _posts;
  }
}
