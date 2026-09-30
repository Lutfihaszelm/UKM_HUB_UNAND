import '../models/item.dart';
/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
 // Ganti isi data dummy ini sesuai aplikasi kelompok
 static const List<Item> _items = [
 Item(
 id: '1',
 title: 'Judul item 1',
 subtitle: 'Keterangan singkat item 1',
 description: 'Deskripsi lengkap item 1.',
 ),
 Item(
 id: '2',
 title: 'Judul item 2',
 subtitle: 'Keterangan singkat item 2',
 description: 'Deskripsi lengkap item 2.',
 ),
 Item(
 id: '3',
 title: 'Judul item 3',
 subtitle: 'Keterangan singkat item 3',
 description: 'Deskripsi lengkap item 3.',
 ),
 ];
 /// Mengambil daftar item.
 /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
 Future<List<Item>> fetchItems({bool simulateError = false}) async {
 await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
 if (simulateError) {
 throw Exception('Gagal memuat data. Periksa koneksi internet.');
 }
 return _items;
 }
}