/// Model data untuk UKM (Unit Kegiatan Mahasiswa).
class Ukm {
  final String id;
  final String name;
  final String category;
  final String description;

  const Ukm({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });
}