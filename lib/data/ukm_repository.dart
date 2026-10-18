import '../models/ukm.dart';

/// Sumber data sementara (dummy) untuk daftar UKM.
class UkmRepository {
  static const List<Ukm> _items = [
    Ukm(
      id: 'ukm-1',
      name: 'UKM Neo Telemetri',
      category: 'Teknologi & Informasi',
      description: 'Unit Kegiatan Mahasiswa yang bergerak di bidang riset dan pengembangan teknologi informasi.',
    ),
    Ukm(
      id: 'ukm-2',
      name: 'UKM PHP (Pengenalan Hukum & Politik)',
      category: 'Penalaran',
      description: 'Unit Kegiatan Mahasiswa yang mewadahi mahasiswa Unand untuk berdiskusi, kajian, dan aksi terkait hukum serta politik.',
    ),
    Ukm(
      id: 'ukm-3',
      name: 'UKM Kesenian Universitas Andalas',
      category: 'Seni & Budaya',
      description: 'Wadah bagi mahasiswa yang memiliki minat dan bakat di berbagai bidang kesenian seperti tari, musik, teater, dan seni rupa.',
    ),
  ];

  /// Mengambil daftar UKM.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Ukm>> fetchUkms({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}