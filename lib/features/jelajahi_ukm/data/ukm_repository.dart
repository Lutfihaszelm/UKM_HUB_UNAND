import '../models/ukm.dart';
import 'ukm_dummy_data.dart';

/// Kontrak sumber data UKM.
///
/// Implementasi sekarang memakai data dummy. Saat backend siap, buat
/// `ApiUkmRepository` dengan method yang sama dan ganti provider-nya saja.
abstract class UkmRepository {
  Future<List<Ukm>> fetchUkms({
    String? query,
    bool onlyFollowed = false,
    int page = 1,
    int limit = 50,
  });

  Future<Ukm> fetchUkmById(String id);

  /// `PUT /ukm/{id}/follow`.
  Future<FollowResult> follow(String id);

  /// `DELETE /ukm/{id}/follow`.
  Future<FollowResult> unfollow(String id);
}

/// Implementasi dummy dengan latensi kecil agar state loading terlihat.
class FakeUkmRepository implements UkmRepository {
  const FakeUkmRepository({this.delay = const Duration(milliseconds: 180)});

  final Duration delay;

  @override
  Future<List<Ukm>> fetchUkms({
    String? query,
    bool onlyFollowed = false,
    int page = 1,
    int limit = 50,
  }) async {
    await Future<void>.delayed(delay);
    final normalized = query?.trim().toLowerCase() ?? '';

    if (onlyFollowed) {
      return kDummyUkmList
          .where((ukm) => ukm.followedByMe)
          .where((ukm) => _matches(ukm, normalized))
          .toList(growable: false);
    }

    return kDummyUkmList
        .where((ukm) => _matches(ukm, normalized))
        .toList(growable: false);
  }

  @override
  Future<Ukm> fetchUkmById(String id) async {
    await Future<void>.delayed(delay);
    return kDummyUkmList.firstWhere(
      (ukm) => ukm.id == id,
      orElse: () => throw StateError('UKM dengan id $id tidak ditemukan.'),
    );
  }

  @override
  Future<FollowResult> follow(String id) async {
    await Future<void>.delayed(delay);
    final ukm = await fetchUkmById(id);
    return FollowResult(followed: true, followerCount: ukm.followerCount + 1);
  }

  @override
  Future<FollowResult> unfollow(String id) async {
    await Future<void>.delayed(delay);
    final ukm = await fetchUkmById(id);
    return FollowResult(
      followed: false,
      followerCount: ukm.followerCount > 0 ? ukm.followerCount : 0,
    );
  }

  bool _matches(Ukm ukm, String query) {
    if (query.isEmpty) return true;
    return ukm.name.toLowerCase().contains(query) ||
        ukm.description.toLowerCase().contains(query) ||
        (ukm.category?.toLowerCase().contains(query) ?? false);
  }
}
