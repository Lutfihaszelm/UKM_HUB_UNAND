/// Status pendaftaran oprec. Sebelumnya berupa String bebas ('Menunggu'),
/// sekarang enum agar tidak ada salah ketik dan mudah dipakai untuk notifikasi.
enum RegistrationStatus {
  menunggu('Menunggu'),
  seleksi('Seleksi Berkas'),
  wawancara('Wawancara'),
  diterima('Diterima'),
  ditolak('Ditolak');

  final String label;
  const RegistrationStatus(this.label);
}

class Registration {
  final String id;
  final String postId;
  final String name;
  final String nim;
  final String motivation;
  final String fileName;
  final RegistrationStatus status;
  final DateTime createdAt;

  const Registration({
    required this.id,
    required this.postId,
    required this.name,
    required this.nim,
    required this.motivation,
    required this.fileName,
    required this.status,
    required this.createdAt,
  });
}
