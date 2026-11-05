import 'package:flutter/material.dart';

import '../../../../models/ukm.dart';

/// "UKM UNAND" section on the Home Screen.
///
/// Displays a white rounded card matching the Figma design:
/// - Header: "UKM UNAND" + "Lihat Semua"
/// - Featured UKMs in blue rounded squares with white walk icon
/// - "UKM Lainnya" in a dark rounded square
/// - Responsive layout that flexes gracefully without overflow
class HomeUkmSection extends StatelessWidget {
  const HomeUkmSection({
    super.key,
    required this.featuredUkms,
    this.onSeeAllTap,
    this.onUkmTap,
    this.onMoreTap,
  });

  /// UKMs to display as squircle items.
  final List<Ukm> featuredUkms;

  /// Called when "Lihat Semua" is tapped.
  final VoidCallback? onSeeAllTap;

  /// Called when a specific UKM item is tapped.
  final void Function(Ukm ukm)? onUkmTap;

  /// Called when "UKM Lainnya" is tapped.
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFEFF2F6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Section Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'UKM UNAND',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF266E4E),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAllTap,
                  behavior: HitTestBehavior.opaque,
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── UKM items row with Expanded children for 100% responsiveness ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured UKMs (blue squircles with walking icon)
                ...featuredUkms.map(
                  (ukm) => Expanded(
                    child: _UkmSquircleItem(
                      icon: Icons.directions_walk_rounded,
                      label: _formatLabel(ukm.name),
                      backgroundColor: const Color(0xFF007AFF),
                      onTap: () => onUkmTap?.call(ukm),
                    ),
                  ),
                ),

                // "UKM Lainnya" item (black squircle)
                Expanded(
                  child: _UkmSquircleItem(
                    icon: Icons.phone_android_rounded,
                    label: 'UKM\nLainnya',
                    backgroundColor: const Color(0xFF111827),
                    onTap: onMoreTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(String name) {
    if (name.contains('AIESEC')) return 'AIESEC in\nUNAND';
    if (name.contains('Neo Telemetri')) return 'Neo\nTelemetri';
    if (name.contains('MAPALA')) return 'Mapala\n ';
    return name;
  }
}

/// A squircle UKM item with icon and 2-line label.
class _UkmSquircleItem extends StatelessWidget {
  const _UkmSquircleItem({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
