import 'package:flutter/material.dart';

import '../../../../models/ukm.dart';

/// Organization card matching the reference design:
/// - Rounded white card with thin border (20px radius)
/// - Left-side pastel icon container (68x68px, 16px radius)
/// - Right-side bold organization title (17px) + naturally wrapped description (14px)
/// - Follow indicator badge when followed
/// - Responsive height that expands with content naturally without overflow
class UkmCard extends StatelessWidget {
  const UkmCard({
    super.key,
    required this.ukm,
    this.onTap,
    this.isFollowing = false,
  });

  final Ukm ukm;
  final VoidCallback? onTap;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    final color = ukm.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
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

              // Text content (Title + Description + optional Following badge)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ukm.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (isFollowing) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Color(0xFF2E7D6F),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Diikuti',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E7D6F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
        ),
      ),
    );
  }
}