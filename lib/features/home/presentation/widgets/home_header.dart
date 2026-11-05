import 'package:flutter/material.dart';

/// Top header for the Home Screen.
///
/// Features:
/// - Student profile avatar (white circle with icon)
/// - Greeting text: "Halo Lutfi," and subtitle "Siap menjelajahi UKM di UNAND?"
/// - Notification bell button on the right
/// - Fully responsive, prevents overflow on compact screens
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.studentName,
    this.onNotificationTap,
    this.badgeCount = 0,
  });

  final String studentName;
  final VoidCallback? onNotificationTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Color(0xFF266E4E),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),

          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Halo ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        TextSpan(
                          text: '$studentName,',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Siap menjelajahi UKM di UNAND?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Notification bell icon
          GestureDetector(
            onTap: onNotificationTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: badgeCount > 0
                  ? Center(
                      child: Badge.count(
                        count: badgeCount,
                        backgroundColor: const Color(0xFFEF4444),
                        textColor: Colors.white,
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF1E293B),
                          size: 24,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1E293B),
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
