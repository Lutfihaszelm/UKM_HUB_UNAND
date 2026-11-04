import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key prefix for SharedPreferences storage.
const _kFollowKey = 'followed_ukm_ids';

/// Holds the set of UKM IDs that the current user follows.
/// Persisted via SharedPreferences so state survives app restarts.
final followedUkmIdsProvider =
    AsyncNotifierProvider<FollowedUkmIdsNotifier, Set<String>>(
  FollowedUkmIdsNotifier.new,
);

class FollowedUkmIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kFollowKey) ?? [];
    return list.toSet();
  }

  Future<void> toggleFollow(String ukmId) async {
    final current = state.value ?? {};
    final updated = Set<String>.from(current);
    if (updated.contains(ukmId)) {
      updated.remove(ukmId);
    } else {
      updated.add(ukmId);
    }
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFollowKey, updated.toList());
  }

  bool isFollowing(String ukmId) {
    return state.value?.contains(ukmId) ?? false;
  }
}
