/// Tipe notifikasi sesuai kontrak API.
enum NotificationType {
  newPost('new_post'),
  commentReply('comment_reply'),
  registrationStatus('registration_status'),
  unknown('unknown');

  const NotificationType(this.value);

  final String value;

  static NotificationType fromValue(String? value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.unknown,
    );
  }
}

/// Notifikasi in-app (FR-13).
///
/// Modul 1 hanya menangani `new_post`; tipe lain tetap didukung oleh model
/// agar satu layar notifikasi bisa dipakai bersama modul lain nanti.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.refId,
    this.postId,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;

  /// ID objek yang memicu notifikasi (postingan untuk `new_post`).
  final String? refId;

  /// Postingan tujuan saat notifikasi diketuk.
  final String? postId;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      refId: refId,
      postId: postId,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] ?? '').toString(),
      type: NotificationType.fromValue(json['type'] as String?),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      refId: json['ref_id'] as String?,
      postId: json['post_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'body': body,
      'ref_id': refId,
      'post_id': postId,
      'is_read': isRead,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}

/// Halaman notifikasi sesuai respons `GET /notifications`.
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.unreadCount,
    required this.serverTime,
  });

  final List<NotificationItem> items;
  final int unreadCount;
  final DateTime serverTime;
}
