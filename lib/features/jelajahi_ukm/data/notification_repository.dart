import '../models/notification_item.dart';
import 'notification_dummy_data.dart';

/// Kontrak notifikasi. Endpoint asli: `GET /notifications` dan
/// `PATCH /notifications/{id}/read`.
abstract class NotificationRepository {
  Future<NotificationPage> fetchNotifications({
    DateTime? since,
    bool unreadOnly = false,
    int page = 1,
    int limit = 50,
  });

  Future<void> markRead(String id);

  Future<void> markAllRead();
}

/// Implementasi dummy yang mengingat notifikasi yang sudah dibaca.
///
/// Status baca disimpan di instance ini agar tetap bertahan saat daftar
/// di-refresh (provider di-invalidate). Saat backend siap, status baca
/// dikelola server lewat `PATCH /notifications/{id}/read`.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({this.delay = const Duration(milliseconds: 120)})
    : _readIds = {
        for (final item in kDummyNotificationList)
          if (item.isRead) item.id,
      };

  final Duration delay;
  final Set<String> _readIds;

  @override
  Future<NotificationPage> fetchNotifications({
    DateTime? since,
    bool unreadOnly = false,
    int page = 1,
    int limit = 50,
  }) async {
    await Future<void>.delayed(delay);

    final items =
        kDummyNotificationList
            .map((item) => item.copyWith(isRead: _readIds.contains(item.id)))
            .where((item) => since == null || item.createdAt.isAfter(since))
            .where((item) => !unreadOnly || !item.isRead)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return NotificationPage(
      items: items,
      unreadCount: items.where((item) => !item.isRead).length,
      serverTime: DateTime.now(),
    );
  }

  @override
  Future<void> markRead(String id) async {
    await Future<void>.delayed(delay);
    _readIds.add(id);
  }

  @override
  Future<void> markAllRead() async {
    await Future<void>.delayed(delay);
    _readIds.addAll(kDummyNotificationList.map((item) => item.id));
  }
}
