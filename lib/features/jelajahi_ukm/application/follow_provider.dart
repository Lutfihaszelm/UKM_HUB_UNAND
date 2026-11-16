import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/follow_store.dart';
import 'repository_providers.dart';

/// Menyimpan UKM yang diikuti pengguna.
///
/// Sementara persisten di SharedPreferences. Method [toggleFollow] memakai
/// pendekatan optimistic: UI berubah lebih dulu, lalu repository dipanggil.
/// Saat backend siap, ganti isi method ke endpoint follow/unfollow.
final followedUkmIdsProvider =
    AsyncNotifierProvider<FollowedUkmIdsNotifier, Set<String>>(
      FollowedUkmIdsNotifier.new,
    );

class FollowedUkmIdsNotifier extends AsyncNotifier<Set<String>> {
  FollowStore get _store => const FollowStore();

  @override
  Future<Set<String>> build() => _store.load();

  bool isFollowing(String ukmId) {
    return state.value?.contains(ukmId) ?? false;
  }

  Future<void> toggleFollow(String ukmId) async {
    final current = state.value ?? <String>{};
    final wasFollowing = current.contains(ukmId);

    final updated = Set<String>.from(current);
    if (wasFollowing) {
      updated.remove(ukmId);
    } else {
      updated.add(ukmId);
    }

    // Optimistic: badge dan tombol langsung berubah.
    state = AsyncData(updated);

    try {
      final repository = ref.read(ukmRepositoryProvider);
      if (wasFollowing) {
        await repository.unfollow(ukmId);
      } else {
        await repository.follow(ukmId);
      }
      await _store.save(updated);
    } catch (_) {
      // Kembalikan state bila repository gagal.
      state = AsyncData(current);
      rethrow;
    }
  }
}

/// Versi boolean untuk widget yang hanya butuh status satu UKM.
final isFollowingUkmProvider = Provider.family<bool, String>((ref, ukmId) {
  return ref.watch(followedUkmIdsProvider).value?.contains(ukmId) ?? false;
});

/// Jumlah pengikut yang ditampilkan setelah status follow lokal diterapkan.
///
/// `follower_count` dari API sudah memperhitungkan `followed_by_me` saat data
/// diambil. Ketika pengguna mengubah status di perangkat, angka itu perlu
/// disesuaikan satu langkah agar kartu daftar dan halaman detail konsisten.
int followerCountForDisplay({
  required int baseCount,
  required bool followedByMe,
  required bool following,
}) {
  if (followedByMe == following) return baseCount;
  final adjusted = following ? baseCount + 1 : baseCount - 1;
  return adjusted < 0 ? 0 : adjusted;
}
