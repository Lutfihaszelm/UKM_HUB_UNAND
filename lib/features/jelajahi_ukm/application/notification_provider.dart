import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item.dart';
import 'feed_provider.dart';
import 'follow_provider.dart';
import 'repository_providers.dart';

/// Notifikasi in-app (FR-13). Modul 1 hanya menampilkan `new_post`.
///
/// Backend hanya membuat notifikasi untuk follower UKM. Karena implementasi
/// sekarang masih dummy, penyaringan itu dilakukan di sini memakai daftar
/// UKM yang diikuti + post_id dari notifikasi.
final notificationListProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationItem>>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    final followed = await ref.watch(followedUkmIdsProvider.future);
    final page = await ref
        .watch(notificationRepositoryProvider)
        .fetchNotifications();
    final posts = await ref.watch(allPostsProvider.future);

    final ukmByPostId = {for (final post in posts) post.id: post.author.id};

    final items = page.items.where((item) {
      if (item.type != NotificationType.newPost) return false;
      final ukmId = ukmByPostId[item.postId];
      return ukmId != null && followed.contains(ukmId);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items;
  }

  Future<void> markRead(String id) async {
    final current = state.value ?? const <NotificationItem>[];
    final updated = current
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
    state = AsyncData(updated);

    try {
      await ref.read(notificationRepositoryProvider).markRead(id);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    final current = state.value ?? const <NotificationItem>[];
    final updated = current
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    state = AsyncData(updated);

    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

final unreadNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationListProvider).value ?? const [];
  return items.where((item) => !item.isRead).length;
});
