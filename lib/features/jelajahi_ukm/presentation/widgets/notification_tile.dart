import 'package:flutter/material.dart';

import '../../models/notification_item.dart';
import '../utils/formatters.dart';

/// Baris notifikasi untuk satu kejadian (mis. `new_post`).
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});

  final NotificationItem notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return Material(
      color: unread ? const Color(0xFFF1F8F3) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEFF2F0))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: unread
                      ? const Color(0xFFDCEFE2)
                      : const Color(0xFFF1F4F2),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _iconFor(notification.type),
                  size: 20,
                  color: unread
                      ? const Color(0xFF2C6E49)
                      : const Color(0xFF6B7A71),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                        color: const Color(0xFF122019),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF5B6B61),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatRelativeTime(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF8A978F),
                      ),
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C6E49),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.newPost:
        return Icons.article_rounded;
      case NotificationType.commentReply:
        return Icons.chat_bubble_outline_rounded;
      case NotificationType.registrationStatus:
        return Icons.assignment_turned_in_outlined;
      case NotificationType.unknown:
        return Icons.notifications_none_rounded;
    }
  }
}
