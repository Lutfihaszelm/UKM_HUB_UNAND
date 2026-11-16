import '../models/notification_item.dart';
import 'post_dummy_data.dart';

/// Notifikasi `new_post` dummy yang diturunkan dari daftar postingan.
///
/// Di backend, notifikasi ini dibuat untuk setiap follower UKM saat admin
/// membuat postingan (A5). Untuk sekarang provider menyaring notifikasi
/// berdasarkan UKM yang diikuti di perangkat.
final List<NotificationItem> kDummyNotificationList =
    List<NotificationItem>.unmodifiable(
      kDummyPostList.map(
        (post) => NotificationItem(
          id: 'notif-${post.id}',
          type: NotificationType.newPost,
          title: '${post.author.name} memposting kabar baru',
          body: post.title,
          refId: post.id,
          postId: post.id,
          isRead: post.id == 'post-02',
          createdAt: post.publishedAt,
        ),
      ),
    );
