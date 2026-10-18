import 'package:flutter/material.dart';

import '../../models/ukm.dart';

/// Organization card matching the reference design:
/// - Rounded white card with thin border (20px radius)
/// - Left-side pastel icon container (68x68px, 16px radius)
/// - Right-side bold organization title (17px) + naturally wrapped description (14px)
/// - Responsive height that expands with content naturally without overflow
class UkmCard extends StatelessWidget {
  const UkmCard({super.key, required this.ukm});

  final Ukm ukm;

  @override
  Widget build(BuildContext context) {
    final color = ukm.color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEFF2F6),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container (68x68, soft pastel background, crisp icon)
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(
              ukm.icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Text content (Title + Description)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ukm.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ukm.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
