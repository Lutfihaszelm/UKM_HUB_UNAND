import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/notification_item.dart';
import '../data/post_dummy_data.dart';
import 'follow_provider.dart';

/// Generates notifications from posts whose UKM the user follows.
///
/// In a real app this would come from a server push / polling endpoint.
/// Current implementation: derives notifications from [kDummyPostList]
/// filtered by [followedUkmIdsProvider]. Only posts from followed UKMs
/// produce notifications - this is the realistic local mechanism
/// documented as a limitation (no realtime push without backend).
final notificationListProvider = Provider<List<NotificationItem>>((ref) {
  final followedIds = ref.watch(followedUkmIdsProvider).value ?? {};

  if (followedIds.isEmpty) return [];

  final relevantPosts =
      kDummyPostList.where((p) => followedIds.contains(p.ukmId)).toList()
        ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

  return relevantPosts.map((p) {
    return NotificationItem(
      id: 'notif-${p.id}',
      ukmId: p.ukmId,
      ukmName: p.ukmName,
      postId: p.id,
      postTitle: p.title,
      message: '${p.ukmName} memposting: "${p.title}"',
      timestamp: p.tanggal,
    );
  }).toList();
});

/// Tracks which notification IDs have been read (in-memory for now).
final readNotificationIdsProvider =
    NotifierProvider<ReadNotificationIdsNotifier, Set<String>>(
  ReadNotificationIdsNotifier.new,
);

class ReadNotificationIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void markRead(String notifId) {
    state = {...state, notifId};
  }

  void markAllRead(List<String> ids) {
    state = {...state, ...ids};
  }
}

/// Unread notification count for badge display.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider);
  final readIds = ref.watch(readNotificationIdsProvider);
  return notifications.where((n) => !readIds.contains(n.id)).length;
});