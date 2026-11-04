/// Model for an in-app notification (FR-13).
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.ukmId,
    required this.ukmName,
    required this.postId,
    required this.postTitle,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String ukmId;
  final String ukmName;

  /// The post that triggered this notification.
  final String postId;
  final String postTitle;

  /// Short notification message.
  final String message;

  final DateTime timestamp;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      ukmId: ukmId,
      ukmName: ukmName,
      postId: postId,
      postTitle: postTitle,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
