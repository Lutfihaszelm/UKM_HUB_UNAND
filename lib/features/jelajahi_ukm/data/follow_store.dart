import 'package:shared_preferences/shared_preferences.dart';

import 'ukm_dummy_data.dart';

/// Penyimpanan sementara daftar UKM yang diikuti.
///
/// Nanti diganti endpoint follow/unfollow milik backend. Untuk sekarang
/// SharedPreferences dipakai agar state bertahan saat aplikasi ditutup.
class FollowStore {
  const FollowStore();

  static const String key = 'followed_ukm_ids';

  Future<Set<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(key);

      // Belum pernah menyimpan apa pun -> pakai contoh awal agar feed personal
      // dan notifikasi langsung bisa didemokan.
      if (stored == null) return {...kInitialFollowedUkmIds};
      return stored.toSet();
    } catch (_) {
      // SharedPreferences tidak tersedia (mis. unit test tanpa plugin).
      return {...kInitialFollowedUkmIds};
    }
  }

  Future<void> save(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, ids.toList()..sort());
    } catch (_) {
      // Diamkan: state tetap hidup di memori selama aplikasi berjalan.
    }
  }
}
