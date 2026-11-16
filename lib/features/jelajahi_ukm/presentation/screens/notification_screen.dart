import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_routes.dart';
import '../../application/feed_provider.dart';
import '../../application/follow_provider.dart';
import '../../application/notification_provider.dart';
import '../../models/notification_item.dart';
import '../widgets/notification_tile.dart';

/// FR-13: Notifikasi in-app. Modul 1 menampilkan notifikasi `new_post` dari
/// UKM yang diikuti.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          if (unread > 0)
            IconButton(
              tooltip: 'Tandai semua dibaca',
              onPressed: () => _markAllRead(context, ref),
              icon: const Icon(Icons.done_all_rounded),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2C6E49),
        onRefresh: () async {
          ref.invalidate(notificationListProvider);
          await ref.read(notificationListProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (unread > 0)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 18,
                        color: Color(0xFF2C6E49),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$unread notifikasi belum dibaca',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C6E49),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _markAllRead(context, ref),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2C6E49),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Tandai semua',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ..._buildContent(context, ref, notificationsAsync),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<NotificationItem>> asyncItems,
  ) {
    final items = asyncItems.value;

    if (items == null) {
      if (asyncItems.hasError) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _NotificationState(
              icon: Icons.cloud_off_rounded,
              title: 'Gagal memuat notifikasi',
              message: 'Periksa koneksi lalu coba lagi.',
              actionLabel: 'Coba Lagi',
              onAction: () => ref.invalidate(notificationListProvider),
            ),
          ),
        ];
      }

      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (items.isEmpty) {
      final followed = ref.watch(followedUkmIdsProvider).value;
      final noFollowing = followed == null || followed.isEmpty;

      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _NotificationState(
            icon: Icons.notifications_none_rounded,
            title: 'Belum ada notifikasi',
            message: noFollowing
                ? 'Ikuti UKM terlebih dahulu agar kabar terbarunya muncul di sini.'
                : 'Postingan baru dari UKM yang kamu ikuti akan muncul di sini.',
            actionLabel: noFollowing ? 'Kembali' : null,
            onAction: noFollowing
                ? () => Navigator.of(context).maybePop()
                : null,
          ),
        ),
      ];
    }

    return [
      SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          final item = items[index];
          return NotificationTile(
            notification: item,
            onTap: () => _openNotification(context, ref, item),
          );
        },
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(notificationListProvider.notifier).markAllRead();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menandai notifikasi.')),
      );
    }
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
  ) async {
    try {
      await ref.read(notificationListProvider.notifier).markRead(item.id);
      final postId = item.postId ?? item.refId;
      if (postId == null) return;
      final post = await ref.read(postByIdProvider(postId).future);
      if (!context.mounted) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.ukmPostDetail,
        arguments: post,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan tidak ditemukan.')),
      );
    }
  }
}

class _NotificationState extends StatelessWidget {
  const _NotificationState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3EE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 31, color: const Color(0xFF2C6E49)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF122019),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF6B7A71),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
