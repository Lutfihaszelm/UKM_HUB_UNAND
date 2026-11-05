import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/follow_provider.dart';
import '../../application/notification_provider.dart';
import '../../data/post_dummy_data.dart';
import '../widgets/notification_tile.dart';
import '../widgets/post_detail_bottom_sheet.dart';

/// FR-13: In-app Notification screen.
/// Displays updates/posts from followed UKMs with read/unread tracking.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);
    final readIds = ref.watch(readNotificationIdsProvider);
    final followedState = ref.watch(followedUkmIdsProvider);
    final followedCount = followedState.value?.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1E293B),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEFF2F6), height: 1),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref
                    .read(readNotificationIdsProvider.notifier)
                    .markAllRead(notifications.map((n) => n.id).toList());
              },
              child: const Text(
                'Tandai Dibaca',
                style: TextStyle(
                  color: Color(0xFF2E7D6F),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildContent(
            context,
            ref,
            notifications,
            readIds,
            followedCount,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> notifications,
    Set<String> readIds,
    int followedCount,
  ) {
    if (followedCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F7F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 36,
                  color: Color(0xFF2E7D6F),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum Ada Notifikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ikuti UKM favoritmu di menu Direktori untuk mendapatkan update postingan dan pengumuman terbaru.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 16),
              Text(
                'Semua Sudah Terbaca',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Belum ada update baru dari UKM yang kamu ikuti.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        final isRead = readIds.contains(item.id);
        return NotificationTile(
          notification: item,
          isRead: isRead,
          onTap: () {
            ref.read(readNotificationIdsProvider.notifier).markRead(item.id);
            final post = kDummyPostList
                .where((p) => p.id == item.postId)
                .firstOrNull;
            if (post != null) {
              showPostDetailBottomSheet(context, post);
            }
          },
        );
      },
    );
  }
}